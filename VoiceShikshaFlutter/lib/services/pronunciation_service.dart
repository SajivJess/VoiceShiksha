import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/analysis_result.dart';
import '../config/api_config.dart';

class PronunciationAnalysisService {
  static String get baseUrl => ApiConfig.baseUrl;
  final Dio _dio = Dio();

  PronunciationAnalysisService() {
    // Configure Dio for better debugging - increased timeouts for CREPE analysis
    _dio.options.connectTimeout = const Duration(seconds: 60);  // Increased for CREPE initialization
    _dio.options.receiveTimeout = const Duration(seconds: 60); // Increased for CREPE processing
    _dio.options.sendTimeout = const Duration(seconds: 60);    // Increased for large audio files
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false, // Don't log large file uploads
        responseBody: true,
        logPrint: (obj) => print('API: $obj'),
      ));
    }
  }

  Future<AnalysisResult> analyzePronunciation({
    required String audioFilePath,
    required String targetLetter,
  }) async {
    try {
      print('🎤 Starting REAL-TIME pronunciation analysis for: $targetLetter');
      print('📁 Audio file path: $audioFilePath');
      
      // First check if server is reachable
      final serverReachable = await checkServerConnection();
      if (!serverReachable) {
        print('❌ Flask server not available at $baseUrl');
        return AnalysisResult(
          success: false,
          feedback: 'Cannot connect to analysis server. Please ensure the Flask server is running on ${ApiConfig.baseUrl}',
          score: 0.0,
          level: 'Connection Error',
          targetLetter: targetLetter,
          dtw_similarity: 0.0,
          feature_similarity: 0.0,
          correlation: 0.0,
          rmse_similarity: 0.0,
          pitch_level: 'Server connection failed',
          stability: 'Server connection failed',
          message: '🔌 Server Offline: Start the Flask server and try again.',
        );
      }

      MultipartFile? audioFile;
      
      if (kIsWeb) {
        print('🌐 Web platform detected - checking for audio data');
        // For web, we'll try to send the audio data if available
        try {
          final file = File(audioFilePath);
          final bytes = await file.readAsBytes();
          audioFile = MultipartFile.fromBytes(bytes, filename: '$targetLetter.wav');
          print('📦 Web audio data prepared: ${bytes.length} bytes');
        } catch (e) {
          print('❌ Cannot read audio file on web: $e');
          return AnalysisResult(
            success: false,
            feedback: 'Cannot access audio recording on web platform. Please try on mobile app.',
            score: 0.0,
            level: 'Platform Error',
            targetLetter: targetLetter,
            dtw_similarity: 0.0,
            feature_similarity: 0.0,
            correlation: 0.0,
            rmse_similarity: 0.0,
            pitch_level: 'Web platform limitation',
            stability: 'Web platform limitation',
            message: '🌐 Web Limitation: Audio analysis requires mobile app.',
          );
        }
      } else {
        // For mobile/desktop platforms
        final file = File(audioFilePath);
        if (!await file.exists()) {
          print('❌ Audio file not found at: $audioFilePath');
          return AnalysisResult(
            success: false,
            feedback: 'Audio recording failed. Please try recording again.',
            score: 0.0,
            level: 'Recording Error',
            targetLetter: targetLetter,
            dtw_similarity: 0.0,
            feature_similarity: 0.0,
            correlation: 0.0,
            rmse_similarity: 0.0,
            pitch_level: 'No audio file found',
            stability: 'No audio file found',
            message: '🎙️ Recording Failed: Please try recording again.',
          );
        }
        
        final fileSize = await file.length();
        print('📦 Audio file size: $fileSize bytes');
        
        if (fileSize < 1000) {
          print('⚠️ Audio file too small: $fileSize bytes');
          return AnalysisResult(
            success: false,
            feedback: 'Audio recording too short. Please speak for at least 2 seconds.',
            score: 0.0,
            level: 'Recording Error',
            targetLetter: targetLetter,
            dtw_similarity: 0.0,
            feature_similarity: 0.0,
            correlation: 0.0,
            rmse_similarity: 0.0,
            pitch_level: 'Audio too short',
            stability: 'Audio too short',
            message: '⏱️ Recording Too Short: Please speak for longer.',
          );
        }
        
        audioFile = await MultipartFile.fromFile(
          audioFilePath,
          filename: '$targetLetter.wav',
        );
      }

      final formData = FormData.fromMap({
        'audio': audioFile,
        'target': targetLetter,
      });

      print('🚀 Sending REAL-TIME request to: $baseUrl/analyze_pronunciation');
      print('⏱️ Note: CREPE analysis may take 20-30 seconds for accurate results...');
      
      final response = await _dio.post(
        '$baseUrl/analyze_pronunciation',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          receiveTimeout: const Duration(seconds: 60), // Extended for CREPE processing
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      print('✅ Server response status: ${response.statusCode}');
      print('📊 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final result = AnalysisResult.fromJson(response.data, target: targetLetter);
        print('🎯 REAL-TIME analysis completed successfully!');
        return result.copyWith(message: '🔥 Live Analysis: Real-time server processing completed!');
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ Network error during real-time analysis: ${e.type} - ${e.message}');
      return AnalysisResult(
        success: false,
        feedback: 'Network error: ${e.message ?? "Connection failed"}. Please check your internet connection.',
        score: 0.0,
        level: 'Network Error',
        targetLetter: targetLetter,
        dtw_similarity: 0.0,
        feature_similarity: 0.0,
        correlation: 0.0,
        rmse_similarity: 0.0,
        pitch_level: 'Network connection failed',
        stability: 'Network connection failed',
        message: '📡 Network Error: ${e.type.toString()}',
      );
    } catch (e) {
      print('❌ Unexpected error during real-time analysis: $e');
      return AnalysisResult(
        success: false,
        feedback: 'Analysis failed due to unexpected error. Please try again.',
        score: 0.0,
        level: 'System Error',
        targetLetter: targetLetter,
        dtw_similarity: 0.0,
        feature_similarity: 0.0,
        correlation: 0.0,
        rmse_similarity: 0.0,
        pitch_level: 'System error occurred',
        stability: 'System error occurred',
        message: '⚠️ System Error: Unexpected failure occurred.',
      );
    }
  }

  Future<bool> checkServerConnection() async {
    try {
      print('🔍 Checking server connection at: $baseUrl');
      
      final response = await _dio.get(
        '$baseUrl/',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      
      final isConnected = response.statusCode == 200;
      print(isConnected ? '✅ Server is reachable' : '❌ Server returned ${response.statusCode}');
      return isConnected;
    } catch (e) {
      print('❌ Server connection failed: $e');
      return false;
    }
  }
}