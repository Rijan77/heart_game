import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/game_model.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  GameQuestion? _currentGame;
  bool _isLoading = false;
  String _error = '';
  int _score = 0;
  int _totalGames = 0;

  GameQuestion? get currentGame => _currentGame;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get score => _score;
  int get totalGames => _totalGames;

  Future<void> fetchNewGame() async {
    _isLoading = true;
    _error = '';

    try {
      final response = await ApiService.getNewGame();

      // Use microtask to avoid build phase issues
      Future.microtask(() {
        if (response.success && response.game != null) {
          _currentGame = response.game;
          _isLoading = false;
          notifyListeners();
        } else {
          _error = response.message;
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      Future.microtask(() {
        _error = 'Failed to fetch game: $e';
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<bool> submitAnswer(int userAnswer) async {
    if (_currentGame == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final gameData = {
        'question': _currentGame!.question,
        'solution': _currentGame!.solution,
      };

      final result = await ApiService.submitAnswer(gameData, userAnswer);

      Future.microtask(() {
        _isLoading = false;
        _totalGames++;

        if (result.correct) {
          _score++;
        }

        notifyListeners();
      });

      return result.correct;
    } catch (e) {
      Future.microtask(() {
        _error = 'Failed to submit answer: $e';
        _isLoading = false;
        notifyListeners();
      });
      return false;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void resetGame() {
    _currentGame = null;
    _score = 0;
    _totalGames = 0;
    _error = '';
    notifyListeners();
  }
}
