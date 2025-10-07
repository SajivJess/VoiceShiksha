import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/api_config.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioRecorder? _audioRecorder;
  AudioPlayer? _audioPlayer;
  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _isPlaying = false;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<void> _initializeRecorder() async {
    if (!_isInitialized) {
      _audioRecorder = AudioRecorder();
      _audioPlayer = AudioPlayer();
      _isInitialized = true;
      print('📱 Audio recorder and player initialized');
    }
  }

  Future<bool> checkPermissions() async {
    try {
      await _initializeRecorder();
      
      // For web, we'll rely on the browser's permission system
      if (kIsWeb) {
        return true; // Browser will prompt for permission when recording starts
      }
      
      // Request microphone permission explicitly
      final status = await Permission.microphone.request();
      print('🎤 Microphone permission status: $status');
      
      if (status != PermissionStatus.granted) {
        print('❌ Microphone permission denied');
        return false;
      }
      
      // Check if we have permission to record using the record package
      if (_audioRecorder != null) {
        final hasPermission = await _audioRecorder!.hasPermission();
        print('🎤 Recording permission: $hasPermission');
        return hasPermission;
      }
      
      return false;
    } catch (e) {
      print('❌ Permission check error: $e');
      return false;
    }
  }

  Future<String> _getRecordingPath(String fileName) async {
    if (kIsWeb) {
      // For web, we'll use a simple filename
      return '$fileName.wav';
    } else {
      final directory = await getTemporaryDirectory();
      return '${directory.path}/$fileName.wav';
    }
  }

  Future<bool> startRecording(String fileName) async {
    try {
      if (_isRecording) {
        await stopRecording();
      }

      await _initializeRecorder();

      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        throw Exception('Microphone permission not granted');
      }

      if (_audioRecorder == null) {
        throw Exception('Audio recorder not initialized');
      }

      _currentRecordingPath = await _getRecordingPath(fileName);
      
      await _audioRecorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          bitRate: 128000,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      print('🎤 Recording started: $_currentRecordingPath');
      return true;
    } catch (e) {
      print('❌ Error starting recording: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording || _audioRecorder == null) return null;

      final path = await _audioRecorder!.stop();
      _isRecording = false;
      
      print('🛑 Recording stopped: ${path ?? _currentRecordingPath}');
      return path ?? _currentRecordingPath;
    } catch (e) {
      print('❌ Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await stopRecording();
      }
      if (_isPlaying) {
        await stopPlaying();
      }
      if (_audioRecorder != null) {
        await _audioRecorder!.dispose();
        _audioRecorder = null;
      }
      if (_audioPlayer != null) {
        await _audioPlayer!.dispose();
        _audioPlayer = null;
      }
      _isInitialized = false;
      print('🧹 Audio recorder and player disposed');
    } catch (e) {
      print('❌ Error disposing audio services: $e');
    }
  }

  // Audio playback methods for learning
  Future<bool> playReferenceAudioFromServer(String targetLetter) async {
    try {
      await _initializeRecorder();
      
      if (_audioPlayer == null) {
        print('❌ Audio player not initialized');
        throw Exception('Audio player not initialized');
      }

      if (_isPlaying) {
        await stopPlaying();
      }

      // Get reference audio from backend server
      String audioUrl = '${ApiConfig.baseUrl}/audio/$targetLetter';
      print('🔊 Playing reference audio from server: $audioUrl for letter: $targetLetter');
      
      await _audioPlayer!.play(UrlSource(audioUrl));
      _isPlaying = true;
      
      // Listen for completion
      _audioPlayer!.onPlayerComplete.listen((_) {
        _isPlaying = false;
        print('🔇 Reference audio playback completed');
      });
      
      return true;
    } catch (e) {
      print('❌ Error playing reference audio from server: $e');
      return false;
    }
  }

  Future<bool> playAudioFromAssets(String assetPath) async {
    try {
      await _initializeRecorder();
      
      if (_audioPlayer == null) {
        print('❌ Audio player not initialized');
        throw Exception('Audio player not initialized');
      }

      if (_isPlaying) {
        await stopPlaying();
      }

      print('🔊 Attempting to play audio from assets: $assetPath');
      await _audioPlayer!.play(AssetSource(assetPath));
      _isPlaying = true;
      
      // Listen for completion
      _audioPlayer!.onPlayerComplete.listen((_) {
        _isPlaying = false;
        print('🔇 Audio playback completed');
      });
      
      print('✅ Audio playback started successfully');
      return true;
    } catch (e) {
      print('❌ Error playing audio from assets: $e');
      return false;
    }
  }

  Future<bool> playAudioFromFile(String filePath) async {
    try {
      await _initializeRecorder();
      
      if (_audioPlayer == null) {
        throw Exception('Audio player not initialized');
      }

      if (_isPlaying) {
        await stopPlaying();
      }

      print('🔊 Playing audio from file: $filePath');
      
      if (kIsWeb) {
        // For web, try to play as asset or URL
        await _audioPlayer!.play(UrlSource(filePath));
      } else {
        // For mobile, play from device storage
        await _audioPlayer!.play(DeviceFileSource(filePath));
      }
      
      _isPlaying = true;
      
      // Listen for completion
      _audioPlayer!.onPlayerComplete.listen((_) {
        _isPlaying = false;
        print('🔇 Audio playback completed');
      });
      
      return true;
    } catch (e) {
      print('❌ Error playing audio from file: $e');
      return false;
    }
  }

  Future<void> stopPlaying() async {
    try {
      if (_audioPlayer != null && _isPlaying) {
        await _audioPlayer!.stop();
        _isPlaying = false;
        print('🛑 Audio playback stopped');
      }
    } catch (e) {
      print('❌ Error stopping audio playback: $e');
    }
  }

  Future<bool> deleteRecording(String path) async {
    try {
      if (kIsWeb) {
        // For web, we can't directly delete files, but we can clear the reference
        return true;
      } else {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
        return false;
      }
    } catch (e) {
      print('Error deleting recording: $e');
      return false;
    }
  }
}