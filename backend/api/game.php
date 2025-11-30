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

// Simple response function
function sendJson($data)
{
    echo json_encode($data);
    exit;
}

// Main game logic
try {
    // Check if it's a GET request for new game
    if ($_SERVER['REQUEST_METHOD'] == 'GET' && isset($_GET['action']) && $_GET['action'] == 'new') {

        // Call the external Heart Game API
        $apiUrl = "http://marcconrad.com/uob/heart/api.php?out=json";
        $response = @file_get_contents($apiUrl);

        if ($response === FALSE) {
            // If external API fails, return mock data
            sendJson([
                "status" => "success",
                "game" => [
                    "question" => "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==",
                    "solution" => rand(1, 9)
                ],
                "note" => "Using mock data"
            ]);
        }

        // Return the actual game data
        $gameData = json_decode($response, true);
        sendJson([
            "status" => "success",
            "game" => $gameData
        ]);
    } else {
        sendJson([
            "status" => "error",
            "message" => "Invalid request. Use: ?action=new"
        ]);
    }
} catch (Exception $e) {
    sendJson([
        "status" => "error",
        "message" => "Server error: " . $e->getMessage()
    ]);
}
