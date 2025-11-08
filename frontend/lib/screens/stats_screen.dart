import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';
import '../models/game_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  UserStats? _userStats;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      final stats = await ApiService.getUserStats();
      setState(() {
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Statistics', style: TextStyle(fontSize: 18.sp)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24.w),
            onPressed: _loadUserStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 64.w),
                  SizedBox(height: 16.h),
                  Text(
                    'Unable to load statistics',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      _error,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: _loadUserStats,
                    child: Text('Try Again', style: TextStyle(fontSize: 16.sp)),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Simple Stats Cards
                  Text(
                    'Game Statistics',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Stats in a simple grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    children: [
                      _buildSimpleStatCard(
                        'Total Games',
                        _userStats!.user.totalGames.toString(),
                        Icons.games,
                        Colors.blue,
                      ),
                      _buildSimpleStatCard(
                        'Games Won',
                        _userStats!.user.gamesWon.toString(),
                        Icons.emoji_events,
                        Colors.green,
                      ),
                      _buildSimpleStatCard(
                        'Games Lost',
                        _userStats!.user.gamesLost.toString(),
                        Icons.sentiment_dissatisfied,
                        Colors.red,
                      ),
                      _buildSimpleStatCard(
                        'Win Rate',
                        '${_userStats!.user.winRate.toStringAsFixed(1)}%',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Recent Games Section
                  Text(
                    'Recent Games',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildRecentGamesList(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
    );
  }

  Widget _buildSimpleStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24.w),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGamesList() {
    final recentGames = _userStats!.recentGames;

    if (recentGames.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Icon(Icons.history_toggle_off, color: Colors.grey, size: 48.w),
              SizedBox(height: 8.h),
              Text(
                'No recent games',
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                'Your game history will appear here',
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: recentGames.take(5).map((game) {
            final isCorrect = game['is_correct'] == 1;
            final userAnswer = game['user_answer'];
            final correctAnswer = game['correct_answer'];
            final date = DateTime.parse(game['created_at']);

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 16.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your answer: $userAnswer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.green : Colors.red,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          isCorrect
                              ? 'Correct! 🎉'
                              : 'Correct answer: $correctAnswer',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(date),
                        style: TextStyle(fontSize: 10.sp),
                      ),
                      Text(
                        _formatDate(date),
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
