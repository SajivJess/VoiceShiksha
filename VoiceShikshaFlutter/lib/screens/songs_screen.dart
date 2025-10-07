import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';

class SongsScreen extends StatelessWidget {
  const SongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final songs = [
      {
        'title': 'ABC Song',
        'subtitle': 'Learn your letters with melody',
        'emoji': '🎵',
        'color': const Color(0xFFFF6B6B),
      },
      {
        'title': 'Vowel Sounds',
        'subtitle': 'Practice Hindi vowels',
        'emoji': '🎤',
        'color': const Color(0xFF4ECDC4),
      },
      {
        'title': 'Rhyming Words',
        'subtitle': 'Fun rhymes to remember',
        'emoji': '🎭',
        'color': const Color(0xFFFFE66D),
      },
      {
        'title': 'Action Songs',
        'subtitle': 'Move and learn together',
        'emoji': '💃',
        'color': const Color(0xFFA8E6CF),
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
                        '🎵 Songs & Rhymes',
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
              
              // Songs List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: song['color'] as Color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                song['emoji'] as String,
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                          title: Text(
                            song['title'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            song['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.play_circle_fill,
                            color: Color(0xFF667EEA),
                            size: 40,
                          ),
                          onTap: () {
                            // TODO: Implement song playback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Playing ${song['title']}...'),
                                backgroundColor: song['color'] as Color,
                              ),
                            );
                          },
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
}