<?php
include_once 'config.php';

class Auth
{
    public function register($data)
    {
        global $db;

        $username = $data['username'];
        $email = $data['email'];
        $password = password_hash($data['password'], PASSWORD_DEFAULT);

        try {
            $query = "INSERT INTO users SET username=:username, email=:email, password=:password, created_at=NOW()";
            $stmt = $db->prepare($query);

            $stmt->bindParam(":username", $username);
            $stmt->bindParam(":email", $email);
            $stmt->bindParam(":password", $password);

            if ($stmt->execute()) {
                $user_id = $db->lastInsertId();
                $token = $this->generateToken($user_id);

                return [
                    "status" => "success",
                    "message" => "User registered successfully",
                    "token" => $token,
                    "user" => [
                        "id" => $user_id,
                        "username" => $username,
                        "email" => $email
                    ]
                ];
            }
        } catch (PDOException $exception) {
            return ["status" => "error", "message" => "Registration failed: " . $exception->getMessage()];
        }
    }

    public function login($data)
    {
        global $db;

        $email = $data['email'];
        $password = $data['password'];

        try {
            $query = "SELECT id, username, email, password FROM users WHERE email = :email";
            $stmt = $db->prepare($query);
            $stmt->bindParam(":email", $email);
            $stmt->execute();

            if ($stmt->rowCount() == 1) {
                $row = $stmt->fetch(PDO::FETCH_ASSOC);

                if (password_verify($password, $row['password'])) {
                    $token = $this->generateToken($row['id']);

                    // Update last login
                    $updateQuery = "UPDATE users SET last_login = NOW() WHERE id = :id";
                    $updateStmt = $db->prepare($updateQuery);
                    $updateStmt->bindParam(":id", $row['id']);
                    $updateStmt->execute();

                    return [
                        "status" => "success",
                        "message" => "Login successful",
                        "token" => $token,
                        "user" => [
                            "id" => $row['id'],
                            "username" => $row['username'],
                            "email" => $row['email']
                        ]
                    ];
                }
            }

            return ["status" => "error", "message" => "Invalid credentials"];
        } catch (PDOException $exception) {
            return ["status" => "error", "message" => "Login failed: " . $exception->getMessage()];
        }
    }

    private function generateToken($user_id)
    {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload = json_encode([
            'user_id' => $user_id,
            'iat' => time(),
            'exp' => time() + (60 * 60 * 24) // 24 hours
        ]);

        $base64Header = base64_encode($header);
        $base64Payload = base64_encode($payload);

        $signature = hash_hmac('sha256', $base64Header . "." . $base64Payload, JWT_SECRET, true);
        $base64Signature = base64_encode($signature);

        return $base64Header . "." . $base64Payload . "." . $base64Signature;
    }

    public static function verifyToken($token)
    {
        $tokenParts = explode('.', $token);
        if (count($tokenParts) != 3) return false;

        list($base64Header, $base64Payload, $base64Signature) = $tokenParts;

        $signature = base64_decode($base64Signature);
        $expectedSignature = hash_hmac('sha256', $base64Header . "." . $base64Payload, JWT_SECRET, true);

        if (hash_equals($signature, $expectedSignature)) {
            $payload = json_decode(base64_decode($base64Payload), true);
            if ($payload['exp'] > time()) {
                return $payload['user_id'];
            }
        }

        return false;
    }
}

// Handle requests
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $auth = new Auth();
    $input = json_decode(file_get_contents("php://input"), true);

    if (isset($input['action'])) {
        switch ($input['action']) {
            case 'register':
                echo json_encode($auth->register($input));
                break;
            case 'login':
                echo json_encode($auth->login($input));
                break;
            default:
                echo json_encode(["status" => "error", "message" => "Invalid action"]);
        }
    }
}
