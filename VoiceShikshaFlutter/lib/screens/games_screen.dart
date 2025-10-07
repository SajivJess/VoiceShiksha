import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {
        'title': 'Sound Match',
        'subtitle': 'Match the sound to the letter',
        'emoji': '🎯',
        'color': const Color(0xFFFF6B6B),
        'difficulty': 'Easy',
      },
      {
        'title': 'Voice Echo',
        'subtitle': 'Repeat what you hear',
        'emoji': '🔊',
        'color': const Color(0xFF4ECDC4),
        'difficulty': 'Medium',
      },
      {
        'title': 'Speed Speak',
        'subtitle': 'Say letters as fast as you can',
        'emoji': '⚡',
        'color': const Color(0xFFFFE66D),
        'difficulty': 'Hard',
      },
      {
        'title': 'Memory Game',
        'subtitle': 'Remember the sequence',
        'emoji': '🧠',
        'color': const Color(0xFFA8E6CF),
        'difficulty': 'Medium',
      },
      {
        'title': 'Pronunciation Quiz',
        'subtitle': 'Test your speaking skills',
        'emoji': '📝',
        'color': const Color(0xFFDDA0DD),
        'difficulty': 'Hard',
      },
    ];

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                    ),
                    const Expanded(
                      child: Text(
                        '🎮 Voice Games',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Games Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return GestureDetector(
                        onTap: () {
                          // TODO: Navigate to specific game
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Starting ${game['title']}...'),
                              backgroundColor: game['color'] as Color,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Game Icon
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: game['color'] as Color,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      game['emoji'] as String,
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Game Title
                                Text(
                                  game['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Game Subtitle
                                Text(
                                  game['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Difficulty Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(game['difficulty'] as String).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getDifficultyColor(game['difficulty'] as String).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    game['difficulty'] as String,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getDifficultyColor(game['difficulty'] as String),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}