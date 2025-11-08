<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database connection
include_once '../includes/database.php';
include_once '../includes/functions.php';

$database = new Database();
$db = $database->getConnection();

// JWT Secret Key
define('JWT_SECRET', 'your_secret_key_here');
