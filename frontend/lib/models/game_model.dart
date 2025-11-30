import 'package:heart_game/models/user_model.dart';

class GameQuestion {
  final String question; 
  final int solution;
  final String? imageBase64;

  GameQuestion({
    required this.question,
    required this.solution,
    this.imageBase64,
  });

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    return GameQuestion(
      question: json['question'] ?? '',
      solution: json['solution'] ?? 0,
      imageBase64: json['question'], // Store the original data
    );
  }

  // Helper method to check if it's a URL
  bool get isUrl => question.startsWith('http');

  // Helper method to get the URL if it is one
  String? get imageUrl => isUrl ? question : null;
}

class GameResponse {
  final bool success;
  final String message;
  final GameQuestion? game;

  GameResponse({required this.success, required this.message, this.game});

  factory GameResponse.fromJson(Map<String, dynamic> json) {
    return GameResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      game: json['game'] != null ? GameQuestion.fromJson(json['game']) : null,
    );
  }
}

class GameResult {
  final bool success;
  final String message;
  final bool correct;
  final int correctAnswer;

  GameResult({
    required this.success,
    required this.message,
    required this.correct,
    required this.correctAnswer,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      correct: json['correct'] ?? false,
      correctAnswer: json['correct_answer'] ?? 0,
    );
  }
}

class UserStats {
  final User user;
  final List<dynamic> recentGames;

  UserStats({required this.user, required this.recentGames});

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      user: User.fromJson(json['user']),
      recentGames: json['recent_games'] ?? [],
    );
  }
}
