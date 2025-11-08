<?php
include_once 'config.php';

class Game
{
    private $api_url = "http://marcconrad.com/uob/heart/api.php";

    public function getNewGame()
    {
        try {
            // Call external API
            $response = file_get_contents($this->api_url . "?out=json");
            $game_data = json_decode($response, true);

            if ($game_data && isset($game_data['question'])) {
                // Store game session if user is authenticated
                if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
                    $token = str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION']);
                    $user_id = Auth::verifyToken($token);

                    if ($user_id) {
                        $this->storeGameSession($user_id, $game_data);
                    }
                }

                return [
                    "status" => "success",
                    "game" => $game_data
                ];
            } else {
                return ["status" => "error", "message" => "Failed to fetch game data"];
            }
        } catch (Exception $e) {
            return ["status" => "error", "message" => "API call failed: " . $e->getMessage()];
        }
    }

    public function submitAnswer($user_id, $game_data, $user_answer)
    {
        global $db;

        try {
            $correct_answer = $game_data['solution'];
            $is_correct = ($user_answer == $correct_answer);

            $query = "INSERT INTO game_sessions 
                     SET user_id=:user_id, question_data=:question_data, 
                         user_answer=:user_answer, correct_answer=:correct_answer,
                         is_correct=:is_correct, created_at=NOW()";

            $stmt = $db->prepare($query);
            $stmt->bindParam(":user_id", $user_id);
            $stmt->bindParam(":question_data", json_encode($game_data));
            $stmt->bindParam(":user_answer", $user_answer);
            $stmt->bindParam(":correct_answer", $correct_answer);
            $stmt->bindParam(":is_correct", $is_correct);

            if ($stmt->execute()) {
                // Update user stats
                $this->updateUserStats($user_id, $is_correct);

                return [
                    "status" => "success",
                    "correct" => $is_correct,
                    "correct_answer" => $correct_answer
                ];
            }
        } catch (PDOException $e) {
            return ["status" => "error", "message" => "Failed to save answer: " . $e->getMessage()];
        }
    }

    private function storeGameSession($user_id, $game_data)
    {
        global $db;

        $query = "INSERT INTO game_sessions 
                 SET user_id=:user_id, question_data=:question_data, created_at=NOW()";

        $stmt = $db->prepare($query);
        $stmt->bindParam(":user_id", $user_id);
        $stmt->bindParam(":question_data", json_encode($game_data));
        $stmt->execute();
    }

    private function updateUserStats($user_id, $is_correct)
    {
        global $db;

        $field = $is_correct ? "games_won" : "games_lost";
        $query = "UPDATE users SET $field = $field + 1, total_games = total_games + 1 WHERE id = :user_id";

        $stmt = $db->prepare($query);
        $stmt->bindParam(":user_id", $user_id);
        $stmt->execute();
    }

    public function getUserStats($user_id)
    {
        global $db;

        try {
            $query = "SELECT username, email, total_games, games_won, games_lost, created_at, last_login 
                     FROM users WHERE id = :user_id";
            $stmt = $db->prepare($query);
            $stmt->bindParam(":user_id", $user_id);
            $stmt->execute();

            if ($stmt->rowCount() == 1) {
                $user = $stmt->fetch(PDO::FETCH_ASSOC);

                // Get recent games
                $gamesQuery = "SELECT * FROM game_sessions 
                              WHERE user_id = :user_id 
                              ORDER BY created_at DESC 
                              LIMIT 10";
                $gamesStmt = $db->prepare($gamesQuery);
                $gamesStmt->bindParam(":user_id", $user_id);
                $gamesStmt->execute();

                $recent_games = $gamesStmt->fetchAll(PDO::FETCH_ASSOC);

                return [
                    "status" => "success",
                    "user" => $user,
                    "recent_games" => $recent_games
                ];
            }
        } catch (PDOException $e) {
            return ["status" => "error", "message" => "Failed to get stats: " . $e->getMessage()];
        }
    }
}

// Handle requests
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $game = new Game();

    if (isset($_GET['action'])) {
        switch ($_GET['action']) {
            case 'new':
                echo json_encode($game->getNewGame());
                break;
            case 'stats':
                if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
                    $token = str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION']);
                    $user_id = Auth::verifyToken($token);
                    if ($user_id) {
                        echo json_encode($game->getUserStats($user_id));
                    } else {
                        echo json_encode(["status" => "error", "message" => "Invalid token"]);
                    }
                }
                break;
        }
    }
} elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $game = new Game();
    $input = json_decode(file_get_contents("php://input"), true);

    if (isset($input['action']) && $input['action'] == 'submit' && isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $token = str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION']);
        $user_id = Auth::verifyToken($token);

        if ($user_id && isset($input['game_data']) && isset($input['user_answer'])) {
            echo json_encode($game->submitAnswer($user_id, $input['game_data'], $input['user_answer']));
        } else {
            echo json_encode(["status" => "error", "message" => "Invalid request"]);
        }
    }
}
