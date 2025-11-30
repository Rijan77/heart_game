<?php
// Test the auth API directly
$test_data = json_encode([
    'action' => 'login',
    'email' => 'rijanacharya73@gmail.com',
    'password' => 'Rijan321'
]);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://localhost:1234/heart_game/api/auth.php");
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $test_data);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $http_code\n";
echo "Response: $response\n";

// Check for any HTML in response
if (strpos($response, '<') !== false) {
    echo "ERROR: Response contains HTML!\n";
}
