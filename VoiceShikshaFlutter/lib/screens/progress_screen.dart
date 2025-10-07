import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';
import '../services/pronunciation_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = false;
  bool _isServerConnected = false;
  List<Map<String, dynamic>> _realProgressData = [];
  final PronunciationAnalysisService _analysisService = PronunciationAnalysisService();

  @override
  void initState() {
    super.initState();
    _checkServerAndLoadProgress();
  }

  Future<void> _checkServerAndLoadProgress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isConnected = await _analysisService.checkServerConnection();
      setState(() {
        _isServerConnected = isConnected;
      });

      if (isConnected) {
        // In a real implementation, you would fetch progress data from the server
        // For now, show empty state until real practice sessions create data
        setState(() {
          _realProgressData = [];
        });
        print('✅ Server connected - ready to track real progress');
      } else {
        print('❌ Server not connected - no progress data available');
      }
    } catch (e) {
      print('❌ Error loading progress: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAttempts = _realProgressData.isNotEmpty 
      ? _realProgressData.fold<int>(0, (sum, item) => sum + (item['attempts'] as int? ?? 0))
      : 0;
    final averageScore = _realProgressData.isNotEmpty 
      ? _realProgressData.fold<double>(0, (sum, item) => sum + (item['score'] as int? ?? 0)) / _realProgressData.length
      : 0.0;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: _isLoading 
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading your progress...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
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
                        '🏆 My Progress',
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
              
              // Progress Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Overall Stats
                        Container(
                          padding: const EdgeInsets.all(20),
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
                          child: Column(
                            children: [
                              const Text(
                                'Overall Performance',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667EEA),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Average Score',
                                      '${averageScore.toInt()}%',
                                      Icons.star,
                                      const Color(0xFFFFD700),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total Practice',
                                      '$totalAttempts times',
                                      Icons.mic,
                                      const Color(0xFF4ECDC4),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Letters Learned',
                                      '${_realProgressData.length}/10',
                                      Icons.school,
                                      const Color(0xFFFF6B6B),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Streak',
                                      '5 days',
                                      Icons.local_fire_department,
                                      const Color(0xFFFF8C00),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Letter Progress
                        Container(
                          padding: const EdgeInsets.all(20),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Letter Progress',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667EEA),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              if (_realProgressData.isEmpty)
                                _buildEmptyProgressState()
                              else
                                ..._realProgressData.map((data) => _buildLetterProgress(
                                  data['letter'] as String,
                                  data['score'] as int,
                                  data['attempts'] as int,
                                )),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Achievements
                        Container(
                          padding: const EdgeInsets.all(20),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Achievements',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667EEA),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              _buildAchievement('🌟', 'First Steps', 'Completed your first pronunciation'),
                              _buildAchievement('🎯', 'Perfect Score', 'Achieved 90+ score on any letter'),
                              _buildAchievement('🔥', 'On Fire', 'Practiced for 5 days in a row'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLetterProgress(String letter, int score, int attempts) {
    Color scoreColor = Colors.green;
    if (score < 70) {
      scoreColor = Colors.red;
    } else if (score < 85) scoreColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Letter
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Progress Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Best Score: $score%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '$attempts attempts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement(String emoji, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProgressState() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(
            _isServerConnected ? Icons.school : Icons.wifi_off,
            size: 48,
            color: _isServerConnected ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
          ),
          const SizedBox(height: 16),
          Text(
            _isServerConnected 
              ? 'Ready to Track Your Progress!'
              : 'Server Connection Required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isServerConnected ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isServerConnected
              ? 'Start practicing to see your real progress here!\nEvery practice session will be tracked.'
              : 'Please start the Flask server to track\nyour pronunciation progress.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_isServerConnected) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _checkServerAndLoadProgress,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}