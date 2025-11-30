<?php
// Turn off ALL error displaying
error_reporting(0);
ini_set('display_errors', 0);

// Set CORS headers
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database configuration
$host = "localhost";
$dbname = "heart_game";
$username = "root";
$password = "";

try {
    $db = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

// Get user stats
if ($_SERVER['REQUEST_METHOD'] == 'GET' && isset($_GET['action']) && $_GET['action'] == 'user_stats') {

    try {
        // Get the first user for demo purposes
        $query = "SELECT id, username, email, total_games, games_won, games_lost, created_at FROM users ORDER BY id LIMIT 1";
        $stmt = $db->prepare($query);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            // Get recent games from game_sessions table if it exists
            $recentGames = [];
            try {
                $gamesQuery = "SELECT * FROM game_sessions ORDER BY created_at DESC LIMIT 5";
                $gamesStmt = $db->prepare($gamesQuery);
                $gamesStmt->execute();
                $recentGames = $gamesStmt->fetchAll(PDO::FETCH_ASSOC);
            } catch (Exception $e) {
                // If game_sessions table doesn't exist, use empty array
                $recentGames = [];
            }

            echo json_encode([
                "status" => "success",
                "user" => $user,
                "recent_games" => $recentGames
            ]);
        } else {
            // Return demo data if no users exist
            echo json_encode([
                "status" => "success",
                "user" => [
                    "id" => 1,
                    "username" => "Demo User",
                    "email" => "demo@example.com",
                    "total_games" => 15,
                    "games_won" => 10,
                    "games_lost" => 5,
                    "created_at" => "2024-01-01 00:00:00"
                ],
                "recent_games" => [
                    [
                        "id" => 1,
                        "user_answer" => 5,
                        "correct_answer" => 5,
                        "is_correct" => 1,
                        "created_at" => "2024-01-15 10:30:00"
                    ],
                    [
                        "id" => 2,
                        "user_answer" => 3,
                        "correct_answer" => 4,
                        "is_correct" => 0,
                        "created_at" => "2024-01-15 10:25:00"
                    ]
                ]
            ]);
        }
    } catch (PDOException $e) {
        echo json_encode(["status" => "error", "message" => "Failed to get stats: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request"]);
}
