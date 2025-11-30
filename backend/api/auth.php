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
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

// Main request handler
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);

    if ($input === null) {
        echo json_encode(["status" => "error", "message" => "Invalid JSON input"]);
        exit;
    }

    if (!isset($input['action'])) {
        echo json_encode(["status" => "error", "message" => "No action specified"]);
        exit;
    }

    // Handle login
    if ($input['action'] == 'login') {
        if (!isset($input['email']) || !isset($input['password'])) {
            echo json_encode(["status" => "error", "message" => "Missing email or password"]);
            exit;
        }

        $email = trim($input['email']);
        $password = $input['password'];

        try {
            $query = "SELECT id, username, email, password FROM users WHERE email = :email";
            $stmt = $db->prepare($query);
            $stmt->bindParam(":email", $email);
            $stmt->execute();

            if ($stmt->rowCount() == 1) {
                $row = $stmt->fetch(PDO::FETCH_ASSOC);

                if (password_verify($password, $row['password'])) {
                    // Generate token - MAKE SURE THIS LINE EXISTS
                    $token = "token_" . bin2hex(random_bytes(16));

                    // Update last login
                    $updateQuery = "UPDATE users SET last_login = NOW() WHERE id = :id";
                    $updateStmt = $db->prepare($updateQuery);
                    $updateStmt->bindParam(":id", $row['id']);
                    $updateStmt->execute();

                    // Return success response
                    echo json_encode([
                        "status" => "success",
                        "message" => "Login successful",
                        "token" => $token,
                        "user" => [
                            "id" => (int)$row['id'],
                            "username" => $row['username'],
                            "email" => $row['email']
                        ]
                    ]);
                    exit;
                }
            }

            echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
            exit;
        } catch (PDOException $exception) {
            http_response_code(500);
            echo json_encode(["status" => "error", "message" => "Login failed"]);
            exit;
        }
    }

    // Handle registration
    else if ($input['action'] == 'register') {
        if (!isset($input['username']) || !isset($input['email']) || !isset($input['password'])) {
            echo json_encode(["status" => "error", "message" => "Missing required fields"]);
            exit;
        }

        $username = trim($input['username']);
        $email = trim($input['email']);
        $password = $input['password'];

        try {
            // Check if user exists
            $checkQuery = "SELECT id FROM users WHERE email = :email OR username = :username";
            $checkStmt = $db->prepare($checkQuery);
            $checkStmt->bindParam(":email", $email);
            $checkStmt->bindParam(":username", $username);
            $checkStmt->execute();

            if ($checkStmt->rowCount() > 0) {
                echo json_encode(["status" => "error", "message" => "User already exists"]);
                exit;
            }

            // Create user
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
            $insertQuery = "INSERT INTO users (username, email, password) VALUES (:username, :email, :password)";
            $insertStmt = $db->prepare($insertQuery);
            $insertStmt->bindParam(":username", $username);
            $insertStmt->bindParam(":email", $email);
            $insertStmt->bindParam(":password", $hashedPassword);

            if ($insertStmt->execute()) {
                $userId = $db->lastInsertId();
                $token = "token_" . bin2hex(random_bytes(16));

                echo json_encode([
                    "status" => "success",
                    "message" => "User registered successfully",
                    "token" => $token,
                    "user" => [
                        "id" => (int)$userId,
                        "username" => $username,
                        "email" => $email
                    ]
                ]);
                exit;
            } else {
                echo json_encode(["status" => "error", "message" => "Registration failed"]);
                exit;
            }
        } catch (PDOException $exception) {
            http_response_code(500);
            echo json_encode(["status" => "error", "message" => "Registration failed"]);
            exit;
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid action"]);
        exit;
    }
} else {
    echo json_encode(["status" => "error", "message" => "Only POST requests allowed"]);
    exit;
}
