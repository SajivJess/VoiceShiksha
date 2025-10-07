class AnalysisResult {
  final bool success;
  final String feedback;
  final double score;
  final String level;
  final String? message;
  final Map<String, dynamic>? detailedFeedback;
  final String targetLetter;
  final double dtw_similarity;
  final double feature_similarity;
  final double correlation;
  final double rmse_similarity;
  final String pitch_level;
  final String stability;
  
  // Voice characteristics
  final double? meanPitch;
  final double? pitchRange;
  final double? jitter;
  final double? shimmer;

  const AnalysisResult({
    required this.success,
    required this.feedback,
    required this.score,
    required this.level,
    required this.targetLetter,
    required this.dtw_similarity,
    required this.feature_similarity,
    required this.correlation,
    required this.rmse_similarity,
    required this.pitch_level,
    required this.stability,
    this.message,
    this.detailedFeedback,
    this.meanPitch,
    this.pitchRange,
    this.jitter,
    this.shimmer,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json, {String target = ''}) {
    final detailedFeedback = json['detailed_feedback'] ?? {};
    final similarities = detailedFeedback['similarities'] ?? {};
    final voiceCharacteristics = detailedFeedback['voice_characteristics'] ?? {};
    
    return AnalysisResult(
      success: json['success'] ?? false,
      feedback: json['feedback'] ?? 'No feedback available',
      score: (json['score'] ?? 0.0).toDouble(),
      level: json['level'] ?? 'Unknown',
      targetLetter: target,
      dtw_similarity: (similarities['dtw_similarity'] ?? 0).toDouble(),
      feature_similarity: (similarities['feature_similarity'] ?? 0).toDouble(),
      correlation: (similarities['correlation'] ?? 0).toDouble(),
      rmse_similarity: (similarities['rmse_similarity'] ?? 0).toDouble(),
      pitch_level: detailedFeedback['pitch_level'] ?? '',
      stability: detailedFeedback['stability'] ?? '',
      message: json['message'],
      detailedFeedback: json['detailed_feedback'],
      meanPitch: voiceCharacteristics['mean_pitch']?.toDouble(),
      pitchRange: voiceCharacteristics['pitch_range']?.toDouble(),
      jitter: voiceCharacteristics['jitter']?.toDouble(),
      shimmer: voiceCharacteristics['shimmer']?.toDouble(),
    );
  }

  AnalysisResult copyWith({
    bool? success,
    String? feedback,
    double? score,
    String? level,
    String? message,
    Map<String, dynamic>? detailedFeedback,
    String? targetLetter,
    double? dtw_similarity,
    double? feature_similarity,
    double? correlation,
    double? rmse_similarity,
    String? pitch_level,
    String? stability,
    double? meanPitch,
    double? pitchRange,
    double? jitter,
    double? shimmer,
  }) {
    return AnalysisResult(
      success: success ?? this.success,
      feedback: feedback ?? this.feedback,
      score: score ?? this.score,
      level: level ?? this.level,
      message: message ?? this.message,
      detailedFeedback: detailedFeedback ?? this.detailedFeedback,
      targetLetter: targetLetter ?? this.targetLetter,
      dtw_similarity: dtw_similarity ?? this.dtw_similarity,
      feature_similarity: feature_similarity ?? this.feature_similarity,
      correlation: correlation ?? this.correlation,
      rmse_similarity: rmse_similarity ?? this.rmse_similarity,
      pitch_level: pitch_level ?? this.pitch_level,
      stability: stability ?? this.stability,
      meanPitch: meanPitch ?? this.meanPitch,
      pitchRange: pitchRange ?? this.pitchRange,
      jitter: jitter ?? this.jitter,
      shimmer: shimmer ?? this.shimmer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'feedback': feedback,
      'score': score,
      'level': level,
      'target': targetLetter,
      'message': message,
      'detailed_feedback': detailedFeedback,
    };
  }
}

class PronunciationFeedback {
  final double compositeScore;
  final String overall;
  final String level;
  final String? pitchLevel;
  final String? stability;
  final Map<String, dynamic>? detailedAnalysis;

  const PronunciationFeedback({
    required this.compositeScore,
    required this.overall,
    required this.level,
    this.pitchLevel,
    this.stability,
    this.detailedAnalysis,
  });

  factory PronunciationFeedback.fromJson(Map<String, dynamic> json) {
    return PronunciationFeedback(
      compositeScore: (json['composite_score'] ?? 0.0).toDouble(),
      overall: json['overall'] ?? '',
      level: json['level'] ?? 'Unknown',
      pitchLevel: json['pitch_level'],
      stability: json['stability'],
      detailedAnalysis: json['detailed_analysis'],
    );
  }
}