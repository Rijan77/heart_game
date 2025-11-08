class AppConstants {
  static const String appName = 'Heart Game';
  static const String apiBaseUrl = 'http://192.168.1.100/heart_game/api';

  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Game constants
  static const List<int> possibleAnswers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String game = '/game';
  static const String profile = '/profile';
  static const String stats = '/stats';
}
