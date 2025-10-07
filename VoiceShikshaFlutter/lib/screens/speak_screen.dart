import 'package:flutter/material.dart';
import '../models/letter.dart';
import '../services/audio_service.dart';
import '../services/pronunciation_service.dart';
import '../models/analysis_result.dart';
import '../config/api_config.dart';

class SpeakScreen extends StatefulWidget {
  const SpeakScreen({super.key});

  @override
  State<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends State<SpeakScreen> with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  final PronunciationAnalysisService _analysisService = PronunciationAnalysisService();
  
  int _currentLetterIndex = 0;
  bool _isRecording = false;
  bool _isAnalyzing = false;
  AnalysisResult? _lastResult;
  String? _errorMessage;
  
  late AnimationController _pulseController;
  late AnimationController _feedbackController;
  
  Letter get currentLetter => LetterData.hindiVowels[_currentLetterIndex];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _checkServerConnection();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _feedbackController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await _analysisService.checkServerConnection();
    if (!isConnected) {
      setState(() {
  _errorMessage = 'Cannot connect to server. Please ensure the Flask server is running on ${ApiConfig.baseUrl}';
      });
    }
  }

  Future<void> _playCorrectPronunciation() async {
    try {
      print('🎵 Listen button tapped for letter: ${currentLetter.character}');
      
      if (_audioService.isPlaying) {
        print('🛑 Stopping current playback');
        await _audioService.stopPlaying();
        setState(() {});
        return;
      }

      print('🔊 Attempting to play reference audio from server for: ${currentLetter.character}');
      
      // Try to play from server first (preferred method)
      bool success = await _audioService.playReferenceAudioFromServer(currentLetter.character);
      
      if (!success) {
        print('⚠️ Server audio failed, trying assets fallback');
        // Fallback: try to play from assets
        String assetPath = 'audio/${currentLetter.audioFile}';
        print('🔍 Trying asset path: $assetPath');
        success = await _audioService.playAudioFromAssets(assetPath);
        
        if (!success) {
          // Try with .mpeg extension since we copied .mpeg files
          String mpegAssetPath = 'audio/${currentLetter.pronunciation}.mpeg';
          print('🔍 Trying MPEG asset path: $mpegAssetPath');
          success = await _audioService.playAudioFromAssets(mpegAssetPath);
        }
      }
      
      if (!success) {
        print('❌ Both server and assets audio failed');
        setState(() {
          _errorMessage = 'Reference audio not available for ${currentLetter.character}';
        });
        // Clear error after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _errorMessage = null;
            });
          }
        });
      } else {
        print('✅ Audio playback started successfully');
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      print('❌ Error in _playCorrectPronunciation: $e');
      setState(() {
        _errorMessage = 'Error playing audio: $e';
      });
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _errorMessage = null;
      _lastResult = null;
    });

    final success = await _audioService.startRecording(currentLetter.pronunciation);
    if (success) {
      setState(() {
        _isRecording = true;
      });
      _pulseController.repeat();
    } else {
      setState(() {
        _errorMessage = 'Failed to start recording. Please check microphone permissions.';
      });
    }
  }

  Future<void> _stopRecording() async {
    _pulseController.stop();
    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    try {
      final audioPath = await _audioService.stopRecording();
      if (audioPath != null) {
        final result = await _analysisService.analyzePronunciation(
          audioFilePath: audioPath, 
          targetLetter: currentLetter.character,
        );
        setState(() {
          _lastResult = result;
          _isAnalyzing = false;
        });
        _feedbackController.forward();
      } else {
        setState(() {
          _errorMessage = 'Failed to save audio recording.';
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Analysis failed: $e';
        _isAnalyzing = false;
      });
    }
  }

  void _nextLetter() {
    setState(() {
      _currentLetterIndex = (_currentLetterIndex + 1) % LetterData.hindiVowels.length;
      _lastResult = null;
      _errorMessage = null;
    });
    _feedbackController.reset();
  }

  void _previousLetter() {
    setState(() {
      _currentLetterIndex = _currentLetterIndex > 0 
          ? _currentLetterIndex - 1 
          : LetterData.hindiVowels.length - 1;
      _lastResult = null;
      _errorMessage = null;
    });
    _feedbackController.reset();
  }

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
                          Text('🎤', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 8),
                          Text(
                            'Voice Practice',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
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
              
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Fun Letter Card
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 10),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated character for encouragement
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 1000),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (0.2 * value),
                                    child: Text(
                                      _isRecording ? '🎙️' : '🦋',
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Letter display
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B9D),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B9D).withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    currentLetter.character,
                                    style: const TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Pronunciation guide
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ECDC4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Say: "${currentLetter.pronunciation}"',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Listen button for learning
                              GestureDetector(
                                onTap: _playCorrectPronunciation,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [const Color(0xFF6C63FF), const Color(0xFF4834DF)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _audioService.isPlaying ? Icons.stop : Icons.volume_up,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _audioService.isPlaying ? 'Stop' : 'Listen',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Letter navigation
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildChildFriendlyNavButton(
                                    Icons.arrow_back_ios,
                                    'Previous',
                                    const Color(0xFFFFE66D),
                                    _previousLetter,
                                  ),
                                  Text(
                                    '${_currentLetterIndex + 1} / ${LetterData.hindiVowels.length}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7B8794),
                                    ),
                                  ),
                                  _buildChildFriendlyNavButton(
                                    Icons.arrow_forward_ios,
                                    'Next',
                                    const Color(0xFFB8A9FF),
                                    _nextLetter,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Recording Section
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _isAnalyzing 
                              ? _buildChildFriendlyAnalyzingState()
                              : (_lastResult != null 
                                  ? _buildChildFriendlyResultCard(_lastResult!)
                                  : _buildChildFriendlyRecordingInterface()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildFriendlyNavButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildFriendlyRecordingInterface() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isRecording ? 'Great! Keep speaking...' : 'Ready to practice?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A90E2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildChildFriendlyRecordingButton(),
            
            const SizedBox(height: 20),
            
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildFriendlyRecordingButton() {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? 1.0 + (_pulseController.value * 0.1) : 1.0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isRecording 
                    ? [const Color(0xFFFF6B9D), const Color(0xFFFF1744)]
                    : [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? const Color(0xFFFF6B9D) : const Color(0xFF4ECDC4)).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChildFriendlyResultCard(AnalysisResult result) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score and emoji with comprehensive feedback
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  result.score >= 85 ? '🌟' : result.score >= 70 ? '👍' : result.score >= 50 ? '💪' : '🎯',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 Score: ${result.score.toStringAsFixed(1)}/100',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: result.score >= 70 ? Colors.green : result.score >= 50 ? Colors.orange : Colors.red,
                      ),
                    ),
                    Text(
                      result.level,
                      style: TextStyle(
                        fontSize: 14,
                        color: result.score >= 70 ? Colors.green.shade600 : result.score >= 50 ? Colors.orange.shade600 : Colors.red.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Main feedback
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📝 Feedback:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.feedback,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7B8794),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (result.pitch_level.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '🔊 ${result.pitch_level}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7B8794),
                      ),
                    ),
                  ],
                  if (result.stability.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '📈 ${result.stability}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7B8794),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // View Details button for analysis dashboard
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/analysis', arguments: result);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text(
                    'Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                
                // Try again button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _lastResult = null;
                      _errorMessage = null;
                    });
                    _feedbackController.reset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildFriendlyAnalyzingState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: const Text('🔄', style: TextStyle(fontSize: 30)),
              );
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Your magic helper is listening...',
            style: TextStyle(
              color: Color(0xFF4A90E2),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}