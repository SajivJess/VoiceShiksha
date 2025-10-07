import 'package:flutter/material.dart';
import 'speak_screen.dart';
import 'learn_screen.dart';
import 'songs_screen.dart';
import 'games_screen.dart';
import 'simple_progress_screen.dart';
import 'analysis_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFB6C1), // Light pink
              Color(0xFFFFB3E6), // Medium pink
              Color(0xFFFFC0CB), // Pink
              Color(0xFFFFE4E1), // Misty rose
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Fun Header with Animated Character
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Animated Character
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1500),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: const Text(
                              '🦋',
                              style: TextStyle(fontSize: 50),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Title
                      const Text(
                        'Voice Shiksha',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63), // Pink accent
                          letterSpacing: 1,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'Learn to speak with your magical voice! 🪄',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7B8794),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Fun Activity Cards
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Row 1: Main Activities
                        Row(
                          children: [
                            Expanded(
                              child: _buildActivityCard(
                                '🎤',
                                'Speak & Learn',
                                'Practice letters with your voice!',
                                const Color(0xFFFF6B9D),
                                () => _navigateToScreen(context, const SpeakScreen()),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildActivityCard(
                                '📚',
                                'Learn ABC',
                                'Discover magical letters!',
                                const Color(0xFF4ECDC4),
                                () => _navigateToScreen(context, const LearnScreen()),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Row 2: Fun Activities
                        Row(
                          children: [
                            Expanded(
                              child: _buildActivityCard(
                                '🎵',
                                'Fun Songs',
                                'Sing along with letters!',
                                const Color(0xFFFFE66D),
                                () => _navigateToScreen(context, const SongsScreen()),
                                textColor: const Color(0xFF2D3436),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildActivityCard(
                                '🎮',
                                'Play Games',
                                'Learning games & puzzles!',
                                const Color(0xFFB8A9FF),
                                () => _navigateToScreen(context, const GamesScreen()),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Row 3: Progress & Analysis
                        Row(
                          children: [
                            Expanded(
                              child: _buildActivityCard(
                                '🏆',
                                'My Stars',
                                'See your amazing progress!',
                                const Color(0xFFFF8A65),
                                () => _navigateToScreen(context, const SimpleProgressScreen()),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildActivityCard(
                                '🤖',
                                'Magic Helper',
                                'AI friend helps you learn!',
                                const Color(0xFF64B5F6),
                                () => _navigateToScreen(context, const AnalysisDashboardScreen()),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Encouragement Message
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3), width: 2),
                          ),
                          child: const Row(
                            children: [
                              Text('🌟', style: TextStyle(fontSize: 24)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You are doing great! Keep practicing and have fun! 🎉',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFE91E63),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    String emoji, 
    String title, 
    String subtitle, 
    Color backgroundColor,
    VoidCallback onPressed,
    {Color textColor = Colors.white}
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji with bounce animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.7 + (0.3 * value),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 8),
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}