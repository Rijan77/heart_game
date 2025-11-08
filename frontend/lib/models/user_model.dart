class User {
  final int id;
  final String username;
  final String email;
  final int totalGames;
  final int gamesWon;
  final int gamesLost;
  final DateTime? lastLogin;
  final DateTime? createdAt; // Add this field

  User({
    required this.id,
    required this.username,
    required this.email,
    this.totalGames = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.lastLogin,
    this.createdAt, // Add this parameter
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id']?.toString() ?? '0'),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      totalGames: int.parse(json['total_games']?.toString() ?? '0'),
      gamesWon: int.parse(json['games_won']?.toString() ?? '0'),
      gamesLost: int.parse(json['games_lost']?.toString() ?? '0'),
      lastLogin:
          json['last_login'] != null && json['last_login'].toString().isNotEmpty
          ? DateTime.parse(json['last_login'].toString())
          : null,
      createdAt:
          json['created_at'] != null && json['created_at'].toString().isNotEmpty
          ? DateTime.parse(json['created_at'].toString())
          : null, // Parse created_at
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'total_games': totalGames,
      'games_won': gamesWon,
      'games_lost': gamesLost,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(), // Include created_at
    };
  }

  double get winRate {
    if (totalGames == 0) return 0.0;
    return (gamesWon / totalGames) * 100;
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print('🟡 Parsing AuthResponse from JSON: $json');

    // Check both possible success indicators
    bool isSuccess = false;
    if (json['status'] == 'success') {
      isSuccess = true;
    } else if (json['success'] == true) {
      isSuccess = true;
    }

    return AuthResponse(
      success: isSuccess,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
