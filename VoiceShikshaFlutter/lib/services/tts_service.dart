import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();

      // Configure TTS for accessibility (slow, clear speech)
      await _setupTTSSettings();
      
      // Set up event listeners
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        if (kDebugMode) print('🔊 TTS Started');
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        if (kDebugMode) print('✅ TTS Completed');
      });

      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        if (kDebugMode) print('❌ TTS Error: $message');
      });

      // Test TTS availability
      await _testTTSAvailability();

      _isInitialized = true;
      if (kDebugMode) print('🎤 TTS Service initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ TTS Service initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Test TTS availability and debug audio issues
  Future<void> _testTTSAvailability() async {
    try {
      if (kDebugMode) print('🔍 Testing TTS availability...');
      
      // Check if TTS is available
      bool isAvailable = await _flutterTts.isLanguageAvailable('en-US');
      if (kDebugMode) print('🌐 TTS available for en-US: $isAvailable');
      
      // Get platform info
      if (kIsWeb) {
        if (kDebugMode) print('🌍 Running on Web - TTS may have limitations');
        // For web, we need to ensure user interaction first
        await _flutterTts.awaitSpeakCompletion(true);
      } else {
        if (kDebugMode) print('📱 Running on Mobile/Desktop');
      }
      
      // Test simple speech
      if (kDebugMode) print('🎤 Testing simple TTS...');
      await _flutterTts.speak('Test');
      
    } catch (e) {
      if (kDebugMode) print('⚠️ TTS test failed: $e');
    }
  }

  Future<void> _setupTTSSettings() async {
    try {
      // Set language to Hindi (with English fallback)
      List<dynamic> languages = await _flutterTts.getLanguages;
      if (kDebugMode) print('📋 Available languages: $languages');
      
      // Try different Hindi language codes
      bool hindiSet = false;
      List<String> hindiCodes = ['hi-IN', 'hi', 'hn-IN', 'hindi'];
      
      for (String code in hindiCodes) {
        if (languages.contains(code)) {
          await _flutterTts.setLanguage(code);
          hindiSet = true;
          if (kDebugMode) print('🇮🇳 Language set to Hindi: $code');
          break;
        }
      }
      
      if (!hindiSet && languages.contains('en-US')) {
        await _flutterTts.setLanguage('en-US');
        if (kDebugMode) print('🇺🇸 Language set to English (Hindi not available)');
      }

      // Configure for clear, educational speech
      await _flutterTts.setSpeechRate(0.3); // Slow for learning (0.0 to 1.0)
      await _flutterTts.setPitch(1.0); // Natural pitch for clarity
      await _flutterTts.setVolume(1.0); // Maximum volume

      if (kDebugMode) {
        print('🔧 TTS Settings for Hindi Learning:');
        print('   - Default Speech Rate: 0.3 (slow for accessibility)');
        print('   - Pitch: 1.0 (natural and clear)');
        print('   - Volume: 1.0 (maximum)');
        print('   - Pattern: Normal(0.5) → Medium(0.35) → Very Slow(0.2)');
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Error setting up TTS: $e');
    }
  }

  /// Speak a Hindi letter with 3 repetitions at different speeds for disabled students
  Future<void> speakLetter({
    required String character,
    required String pronunciation,
    String? hint,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (!_isInitialized) {
        if (kDebugMode) print('❌ TTS not initialized, cannot speak');
        return;
      }

      // Stop any current speech
      await stop();

      // Use the actual Hindi character for pronunciation
      String hindiText = character; // Use the Hindi character directly

      if (kDebugMode) {
        print('🗣️ Speaking Hindi letter: $character');
        print('   Hindi pronunciation: $hindiText');
        print('   Pattern: Normal → Medium → Very Slow');
      }

      // For web, we might need to use a simpler approach
      if (kIsWeb) {
        await _speakForWeb(hindiText);
      } else {
        await _speakWithMultipleSpeeds(hindiText);
      }

      if (kDebugMode) print('✅ Completed Hindi pronunciation for: $hindiText');
    } catch (e) {
      if (kDebugMode) print('❌ Error speaking letter: $e');
    }
  }

  /// Web-optimized speech (simpler approach)
  Future<void> _speakForWeb(String text) async {
    try {
      // On web, speak 3 times with delays but don't change speed as much
      await _flutterTts.setSpeechRate(0.6); // Slightly slower than normal
      
      for (int i = 0; i < 3; i++) {
        if (kDebugMode) print('🔊 Web speech repetition ${i + 1}/3');
        await _flutterTts.speak(text);
        await Future.delayed(const Duration(milliseconds: 1000)); // Longer delay for web
      }
    } catch (e) {
      if (kDebugMode) print('❌ Web speech error: $e');
    }
  }

  /// Mobile/Desktop optimized speech with variable speeds
  Future<void> _speakWithMultipleSpeeds(String text) async {
    try {
      // First repetition - Normal speed (0.5)
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(text);
      await _waitForCompletion();
      
      // Brief pause between repetitions
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Second repetition - Medium speed (0.35)
      await _flutterTts.setSpeechRate(0.35);
      await _flutterTts.speak(text);
      await _waitForCompletion();
      
      // Brief pause between repetitions
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Third repetition - Very slow speed (0.2)
      await _flutterTts.setSpeechRate(0.2);
      await _flutterTts.speak(text);
      await _waitForCompletion();
      
      // Reset to default slow speed
      await _flutterTts.setSpeechRate(0.3);
    } catch (e) {
      if (kDebugMode) print('❌ Multi-speed speech error: $e');
    }
  }

  /// Wait for TTS to complete speaking
  Future<void> _waitForCompletion() async {
    // Wait for speech to start
    int attempts = 0;
    while (!_isSpeaking && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    // Wait for speech to complete
    while (_isSpeaking) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Create optimized text for clear pronunciation
  String _createClearPronunciation(String character, String pronunciation, String? hint) {
    // For Hindi letters, we'll speak both the character name and pronunciation
    String text = 'The letter is $character. ';
    text += 'It sounds like $pronunciation. ';
    
    // Add breathing pause
    text += ' ... ';
    
    // Repeat pronunciation for better learning
    text += 'Say $pronunciation. ';
    
    // Add hint if available
    if (hint != null && hint.isNotEmpty) {
      // Extract the key part of the hint (like "Apple" from 'Say "A" like in "Apple"')
      String simplifiedHint = _extractHintWord(hint);
      if (simplifiedHint.isNotEmpty) {
        text += 'Like in $simplifiedHint.';
      }
    }
    
    return text;
  }

  /// Extract the key word from hint text
  String _extractHintWord(String hint) {
    // Look for words in quotes like "Apple"
    RegExp quotePattern = RegExp(r'"([^"]+)"');
    Match? match = quotePattern.firstMatch(hint);
    if (match != null && match.groupCount > 0) {
      return match.group(1) ?? '';
    }
    
    // Fallback: look for common words after "like in"
    if (hint.toLowerCase().contains('like in')) {
      List<String> parts = hint.toLowerCase().split('like in');
      if (parts.length > 1) {
        String lastPart = parts.last.trim();
        // Remove quotes and extra characters
        lastPart = lastPart.replaceAll('"', '').replaceAll("'", '').trim();
        return lastPart.split(' ').first; // Get first word
      }
    }
    
    return '';
  }

  /// Speak just the pronunciation once at normal speed (for quick feedback)
  Future<void> speakPronunciationOnly(String pronunciation) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (!_isInitialized) {
        if (kDebugMode) print('❌ TTS not initialized, cannot speak quick pronunciation');
        return;
      }

      await stop();
      
      // Use Hindi character directly for pronunciation
      String hindiText = pronunciation;
      
      if (kDebugMode) print('🔊 Quick Hindi pronunciation: $hindiText');
      
      // Normal speed for quick pronunciation
      await _flutterTts.setSpeechRate(0.6); // Slightly slower for clarity
      await _flutterTts.speak(hindiText);
      
      // Reset to default slow speed
      await _flutterTts.setSpeechRate(0.3);
      
    } catch (e) {
      if (kDebugMode) print('❌ Error speaking quick pronunciation: $e');
    }
  }

  /// Adjust speech rate for different accessibility needs
  Future<void> setSpeechRate(double rate) async {
    try {
      // Clamp rate between 0.1 (very slow) and 1.0 (normal)
      double clampedRate = rate.clamp(0.1, 1.0);
      await _flutterTts.setSpeechRate(clampedRate);
      if (kDebugMode) print('⚡ Speech rate set to: $clampedRate');
    } catch (e) {
      if (kDebugMode) print('❌ Error setting speech rate: $e');
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      if (kDebugMode) print('❌ Error stopping TTS: $e');
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      if (kDebugMode) print('❌ Error pausing TTS: $e');
    }
  }

  /// Get available languages for debugging
  Future<List<String>> getAvailableLanguages() async {
    try {
      if (!_isInitialized) await initialize();
      List<dynamic> languages = await _flutterTts.getLanguages;
      return languages.cast<String>();
    } catch (e) {
      if (kDebugMode) print('❌ Error getting languages: $e');
      return [];
    }
  }

  /// Dispose of TTS resources
  Future<void> dispose() async {
    try {
      await stop();
      // Note: FlutterTts doesn't have a dispose method
      _isInitialized = false;
      if (kDebugMode) print('🔄 TTS Service disposed');
    } catch (e) {
      if (kDebugMode) print('❌ Error disposing TTS: $e');
    }
  }
}