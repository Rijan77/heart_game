import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/game_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  int _correctAnswer = 0;

  @override
  void initState() {
    super.initState();
    _loadNewGame();
  }

  Future<void> _loadNewGame() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    await gameProvider.fetchNewGame();
    if (mounted) {
      _resetGameState();
    }
  }

  void _resetGameState() {
    if (mounted) {
      setState(() {
        _selectedAnswer = null;
        _showResult = false;
        _isCorrect = false;
        _correctAnswer = 0;
      });
    }
  }

  Future<void> _submitAnswer(int answer) async {
    if (_showResult) return;

    setState(() {
      _selectedAnswer = answer;
    });

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final result = await gameProvider.submitAnswer(answer);

    setState(() {
      _showResult = true;
      _isCorrect = result;
      _correctAnswer = gameProvider.currentGame?.solution ?? 0;
    });

    // Auto-proceed to next question after delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      await _loadNewGame();
    }
  }

  Widget _buildHeartImage(String? imageData) {
    if (imageData == null || imageData.isEmpty) {
      return Icon(Icons.favorite, color: Colors.red, size: 120.w);
    }

    try {
      if (imageData.startsWith('http')) {
        return Image.network(
          imageData,
          width: 200.w,
          height: 200.h,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 200.w,
              height: 200.h,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.favorite, color: Colors.red, size: 120.w);
          },
        );
      } else {
        return Icon(Icons.favorite, color: Colors.red, size: 120.w);
      }
    } catch (e) {
      return Icon(Icons.favorite, color: Colors.red, size: 120.w);
    }
  }

  Widget _buildAnswerButton(int number) {
    final bool isSelected = _selectedAnswer == number;
    final bool isCorrectAnswer = _showResult && number == _correctAnswer;
    final bool isWrongAnswer = _showResult && isSelected && !_isCorrect;

    Color backgroundColor = Colors.grey[300]!;
    Color textColor = Colors.black;

    if (isSelected) {
      if (_showResult) {
        backgroundColor = _isCorrect ? Colors.green : Colors.red;
        textColor = Colors.white;
      } else {
        backgroundColor = Colors.blue;
        textColor = Colors.white;
      }
    } else if (isCorrectAnswer) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
    } else if (isWrongAnswer) {
      backgroundColor = Colors.red;
      textColor = Colors.white;
    }

    return Expanded(
      child: Container(
        margin: EdgeInsets.all(4.w),
        child: ElevatedButton(
          onPressed: () => _submitAnswer(number),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.w),
            ),
            elevation: 2,
          ),
          child: Text(
            number.toString(),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Game', style: TextStyle(fontSize: 18.sp)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24.w),
            onPressed: _loadNewGame,
          ),
        ],
      ),
      body: gameProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : gameProvider.currentGame == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load game',
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: _loadNewGame,
                    child: Text('Retry', style: TextStyle(fontSize: 16.sp)),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              // Wrap with SingleChildScrollView to prevent overflow
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    'How many hearts do you see?',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.h),
                  _buildHeartImage(gameProvider.currentGame!.question),
                  SizedBox(height: 40.h),

                  if (_showResult)
                    Text(
                      _isCorrect ? 'Correct! 🎉' : 'Wrong! 😞',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: _isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  if (_showResult && !_isCorrect)
                    Text(
                      'Correct answer: $_correctAnswer',
                      style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                    ),
                  SizedBox(height: 40.h),

                  // Answer grid 4x3 (including 0)
                  Column(
                    children: [
                      // Row 1: 1, 2, 3
                      SizedBox(
                        height: 70.h,
                        child: Row(
                          children: [
                            _buildAnswerButton(1),
                            _buildAnswerButton(2),
                            _buildAnswerButton(3),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // Row 2: 4, 5, 6
                      SizedBox(
                        height: 70.h,
                        child: Row(
                          children: [
                            _buildAnswerButton(4),
                            _buildAnswerButton(5),
                            _buildAnswerButton(6),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // Row 3: 7, 8, 9
                      SizedBox(
                        height: 70.h,
                        child: Row(
                          children: [
                            _buildAnswerButton(7),
                            _buildAnswerButton(8),
                            _buildAnswerButton(9),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // Row 4: 0 only, centered
                      SizedBox(
                        height: 70.h,
                        child: Row(
                          children: [
                            Spacer(),
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.all(4.w),
                                child: ElevatedButton(
                                  onPressed: () => _submitAnswer(0),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedAnswer == 0
                                        ? (_showResult
                                              ? (_isCorrect
                                                    ? Colors.green
                                                    : Colors.red)
                                              : Colors.blue)
                                        : Colors.grey[300],
                                    foregroundColor: _selectedAnswer == 0
                                        ? Colors.white
                                        : Colors.black,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 20.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.w),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Game statistics
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildGameStat(
                            'Score',
                            gameProvider.score.toString(),
                          ),
                          _buildGameStat(
                            'Games',
                            gameProvider.totalGames.toString(),
                          ),
                          _buildGameStat(
                            'Accuracy',
                            '${gameProvider.totalGames > 0 ? ((gameProvider.score / gameProvider.totalGames) * 100).toStringAsFixed(1) : '0'}%',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGameStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ],
    );
  }
}
