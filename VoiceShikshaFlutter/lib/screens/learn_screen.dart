import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/letter.dart';
import '../widgets/animated_background.dart';
import '../services/tts_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _currentIndex = 0;
  final TTSService _ttsService = TTSService();
  bool _isSpeaking = false;

  Letter get currentLetter => LetterData.hindiVowels[_currentIndex];

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _initializeTTS() async {
    await _ttsService.initialize();
  }

  void _nextLetter() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % LetterData.hindiVowels.length;
    });
    _stopSpeaking(); // Stop any current speech when changing letters
  }

  void _previousLetter() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + LetterData.hindiVowels.length) % LetterData.hindiVowels.length;
    });
    _stopSpeaking(); // Stop any current speech when changing letters
  }

  /// Speak the current letter clearly and slowly for accessibility
  Future<void> _speakLetter() async {
    try {
      setState(() {
        _isSpeaking = true;
      });

      print('🔧 DEBUG: Starting TTS for letter: ${currentLetter.character}');

      await _ttsService.speakLetter(
        character: currentLetter.character,
        pronunciation: currentLetter.pronunciation,
        hint: currentLetter.hint,
      );

      // Wait a bit for the TTS to update its state
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isSpeaking = _ttsService.isSpeaking;
      });
    } catch (e) {
      print('🔧 DEBUG: TTS Error: $e');
      setState(() {
        _isSpeaking = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing pronunciation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Test TTS with simple English text
  Future<void> _testTTS() async {
    try {
      print('🔧 DEBUG: Testing simple TTS...');
      await _ttsService.speakPronunciationOnly('Hello');
    } catch (e) {
      print('🔧 DEBUG: Simple TTS test failed: $e');
    }
  }

  /// Stop any current speech
  Future<void> _stopSpeaking() async {
    await _ttsService.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  /// Practice the letter (navigate to practice screen)
  void _practiceThisLetter() {
    _stopSpeaking();
    // Navigate to the practice/speak screen
    Navigator.pushNamed(context, '/speak');
  }

  @override
  Widget build(BuildContext context) {
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
                        '📖 Learn ABC',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Letter Card
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Character Display
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Text(
                                    currentLetter.character,
                                    style: const TextStyle(
                                      fontSize: 100,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Pronunciation
                              Text(
                                currentLetter.pronunciation,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667EEA),
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Quick pronunciation button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    // Quick pronunciation using Hindi character directly
                                    await _ttsService.speakPronunciationOnly(currentLetter.character);
                                  },
                                  icon: const Icon(
                                    Icons.volume_up,
                                    color: Color(0xFF667EEA),
                                    size: 28,
                                  ),
                                  tooltip: 'Quick Hindi pronunciation',
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Hint
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  currentLetter.hint,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _previousLetter,
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFF667EEA),
                              ),
                              iconSize: 30,
                            ),
                          ),
                          
                          // Progress Indicator
                          Column(
                            children: [
                              Text(
                                '${_currentIndex + 1} / ${LetterData.hindiVowels.length}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 120,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (_currentIndex + 1) / LetterData.hindiVowels.length,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Next Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _nextLetter,
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF667EEA),
                              ),
                              iconSize: 30,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Listen Button - For clear pronunciation
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isSpeaking 
                                ? [const Color(0xFF4CAF50), const Color(0xFF81C784)] // Green when speaking
                                : [const Color(0xFF2196F3), const Color(0xFF64B5F6)], // Blue when not speaking
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: _isSpeaking ? _stopSpeaking : _speakLetter,
                          borderRadius: BorderRadius.circular(25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSpeaking ? Icons.stop : Icons.volume_up,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isSpeaking ? '🔊 रुकें (Stop)' : '🔊 हिंदी उच्चारण सुनें (Listen)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Practice Button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6F61), Color(0xFFFF9A9E)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: _practiceThisLetter,
                          borderRadius: BorderRadius.circular(25),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                '🎤 Practice This Letter',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Debug TTS Test Button (only in debug mode)
                      if (kDebugMode) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            onTap: _testTTS,
                            borderRadius: BorderRadius.circular(20),
                            child: const Text(
                              '🔧 Test TTS (Debug)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}