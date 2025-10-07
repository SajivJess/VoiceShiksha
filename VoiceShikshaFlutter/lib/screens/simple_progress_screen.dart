import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../services/pronunciation_service.dart';

class SimpleProgressScreen extends StatefulWidget {
  const SimpleProgressScreen({super.key});

  @override
  State<SimpleProgressScreen> createState() => _SimpleProgressScreenState();
}

class _SimpleProgressScreenState extends State<SimpleProgressScreen> {
  List<AnalysisResult> _trainingHistory = [];
  bool _isLoading = false;
  bool _isServerConnected = false;
  final PronunciationAnalysisService _analysisService = PronunciationAnalysisService();

  @override
  void initState() {
    super.initState();
    _checkServerAndLoadData();
  }

  Future<void> _checkServerAndLoadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if server is connected
      final isConnected = await _analysisService.checkServerConnection();
      setState(() {
        _isServerConnected = isConnected;
      });

      if (isConnected) {
        print('✅ Server connected - real-time data available');
        // In a real implementation, you would load actual training history from the server
        // For now, we'll show empty state and require real usage to build history
        setState(() {
          _trainingHistory = [];
        });
      } else {
        print('❌ Server not connected - no training data available');
        setState(() {
          _trainingHistory = [];
        });
      }
    } catch (e) {
      print('❌ Error checking server: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addRealTrainingResult(AnalysisResult result) {
    setState(() {
      _trainingHistory.insert(0, result);
      // Keep only the most recent 20 results
      if (_trainingHistory.length > 20) {
        _trainingHistory = _trainingHistory.take(20).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final averageScore = _trainingHistory.isNotEmpty 
      ? _trainingHistory.map((e) => e.score).reduce((a, b) => a + b) / _trainingHistory.length
      : 0.0;
    
    final bestScore = _trainingHistory.isNotEmpty 
      ? _trainingHistory.map((e) => e.score).reduce((a, b) => a > b ? a : b)
      : 0.0;

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
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🏆', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 8),
                          Text(
                            'My Stars & Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Fun Stats Overview
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.pink.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE91E63).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '✨ Your Amazing Journey ✨',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFunStatColumn('🎯', 'Best Score', '${bestScore.toInt()}%', const Color(0xFF4CAF50)),
                        _buildFunStatColumn('📊', 'Average', '${averageScore.toInt()}%', const Color(0xFF2196F3)),
                        _buildFunStatColumn('🎤', 'Practice Sessions', '${_trainingHistory.length}', const Color(0xFFFF9800)),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Progress List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.pink.shade50],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _trainingHistory.isEmpty 
                    ? _buildChildFriendlyEmptyState()
                    : _buildChildFriendlyProgressList(),
                ),
              ),
              
              // Practice More Button
              Container(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.mic, size: 24),
                    label: const Text(
                      'Practice More!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

  Widget _buildFunStatColumn(String emoji, String title, String value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7B8794),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildChildFriendlyEmptyState() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
            ),
            SizedBox(height: 20),
            Text(
              'Checking server connection...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated character based on server status
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Text(
                    _isServerConnected ? '🌱' : '🔌', 
                    style: const TextStyle(fontSize: 60)
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            Text(
              _isServerConnected 
                ? 'Your Learning Garden'
                : 'Server Connection Needed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isServerConnected ? const Color(0xFF4A90E2) : const Color(0xFFFF9800),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              _isServerConnected
                ? 'Start practicing to grow your real analysis stars!\nEvery practice session uses real AI analysis! 🔥'
                : 'Please start the Flask server to begin\nreal-time pronunciation analysis! �',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF7B8794),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (!_isServerConnected) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _checkServerAndLoadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChildFriendlyProgressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _trainingHistory.length,
      itemBuilder: (context, index) {
        final session = _trainingHistory[index];
        return _buildChildFriendlySessionCard(session, index);
      },
    );
  }

  Widget _buildChildFriendlySessionCard(AnalysisResult session, int index) {
    final achievementEmoji = session.score >= 85 ? '🌟' : session.score >= 70 ? '⭐' : '💫';
    final achievementText = session.score >= 85 ? 'Superstar!' : session.score >= 70 ? 'Great Job!' : 'Keep Going!';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, _getScoreColor(session.score).withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getScoreColor(session.score).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(session.score).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Achievement badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getScoreColor(session.score),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getScoreColor(session.score).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievementEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  '${session.score.toInt()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Session details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Letter: ${session.targetLetter}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(session.score),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      achievementText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getScoreColor(session.score),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 2),
                
                // Analysis type indicator
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: session.message?.contains('Real Backend') ?? false 
                            ? Colors.green.withOpacity(0.1) 
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: session.message?.contains('Real Backend') ?? false 
                              ? Colors.green.withOpacity(0.3) 
                              : Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        session.message ?? '🤖 Analysis',
                        style: TextStyle(
                          fontSize: 8,
                          color: session.message?.contains('Real Backend') ?? false 
                              ? Colors.green[700] 
                              : Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  session.feedback,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7B8794),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Session ${index + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF7B8794),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}