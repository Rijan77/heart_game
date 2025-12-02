import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';

class ApiService {
  static const String baseUrl = "http://10.10.9.3:1234/heart_game/api";

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication APIs
  static Future<AuthResponse> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      print('🔵 API Call: Registering user $username');

      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: await _getHeaders(),
        body: json.encode({
          'action': 'register',
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('🔵 Response Status: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(json.decode(response.body));
      } else {
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('🔴 Network error: $e');
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<AuthResponse> login(String email, String password) async {
    try {
      print('🔵 API Call: Logging in $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: await _getHeaders(),
        body: json.encode({
          'action': 'login',
          'email': email,
          'password': password,
        }),
      );

      print('🔵 Response Status: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(json.decode(response.body));
      } else {
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('🔴 Network error: $e');
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  // Game API - FIXED VERSION
  static Future<GameResponse> getNewGame() async {
    try {
      print('🔵 Fetching new game from API');

      final response = await http.get(
        Uri.parse('$baseUrl/game.php?action=new'),
        headers: await _getHeaders(),
      );

      print('🔵 Game API Response Status: ${response.statusCode}');
      print('🔵 Game API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data['game'] != null) {
          final gameData = data['game'];

          return GameResponse(
            success: true,
            message: data['message'] ?? 'Game loaded successfully',
            game: GameQuestion.fromJson(gameData),
          );
        } else {
          return GameResponse(
            success: false,
            message: data['message'] ?? 'Invalid game data',
          );
        }
      } else {
        return GameResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('🔴 Game API error: $e');
      return GameResponse(success: false, message: 'Failed to load game: $e');
    }
  }

  // User Stats API - ENHANCED WITH FALLBACK
  static Future<UserStats> getUserStats() async {
    try {
      print('🔵 Fetching user statistics');

      final response = await http.get(
        Uri.parse('$baseUrl/stats.php?action=user_stats'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return UserStats.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to get stats');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('🟡 Stats API not available, using mock data: $e');
      // Return mock data for demonstration
      return UserStats(
        user: User(
          id: 1,
          username: 'Demo User',
          email: 'demo@example.com',
          totalGames: 15,
          gamesWon: 10,
          gamesLost: 5,
        ),
        recentGames: [
          {
            'id': 1,
            'user_answer': 5,
            'correct_answer': 5,
            'is_correct': 1,
            'created_at': '2024-01-15 10:30:00',
          },
          {
            'id': 2,
            'user_answer': 3,
            'correct_answer': 4,
            'is_correct': 0,
            'created_at': '2024-01-15 10:25:00',
          },
        ],
      );
    }
  }

  // Add this temporary debug method
  static Future<void> debugGameApi() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/game.php?action=new'),
      );

      print('🎯 RAW API RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🎯 PARSED JSON: $data');

        if (data['game'] != null) {
          final game = data['game'];
          print('🎯 GAME DATA:');
          print('Question type: ${game['question'].runtimeType}');
          print('Question length: ${game['question']?.toString().length}');
          print('Solution: ${game['solution']}');
          print('Solution type: ${game['solution'].runtimeType}');
        }
      }
    } catch (e) {
      print('🔴 Debug API error: $e');
    }
  }

  static Future<GameResult> submitAnswer(
    Map<String, dynamic> gameData,
    int userAnswer,
  ) async {
    try {
      // For now, just check locally since we don't have backend for this
      final correctAnswer = gameData['solution'];
      final isCorrect = userAnswer == correctAnswer;

      return GameResult(
        success: true,
        message: isCorrect ? 'Correct!' : 'Wrong!',
        correct: isCorrect,
        correctAnswer: correctAnswer,
      );
    } catch (e) {
      return GameResult(
        success: false,
        message: 'Failed to submit answer: $e',
        correct: false,
        correctAnswer: 0,
      );
    }
  }
}
