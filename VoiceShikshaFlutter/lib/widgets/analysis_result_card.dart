import 'package:flutter/material.dart';
import '../models/analysis_result.dart';

class AnalysisResultCard extends StatelessWidget {
  final AnalysisResult result;
  final VoidCallback? onRetry;

  const AnalysisResultCard({
    super.key,
    required this.result,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(result.score),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildScoreSection(),
              const SizedBox(height: 20),
              _buildFeedbackSection(),
              const SizedBox(height: 20),
              _buildDetailedMetrics(),
              const SizedBox(height: 20),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getScoreIcon(result.score),
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pronunciation Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Target: ${result.targetLetter.toUpperCase()}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${result.score.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'SCORE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  result.level.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'LEVEL',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'AI Feedback',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.feedback,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics() {
    final metrics = [
      {'label': 'DTW Similarity', 'value': result.dtw_similarity, 'icon': Icons.timeline},
      {'label': 'Feature Match', 'value': result.feature_similarity, 'icon': Icons.equalizer},
      {'label': 'Correlation', 'value': result.correlation * 100, 'icon': Icons.sync},
      {'label': 'RMSE Score', 'value': result.rmse_similarity, 'icon': Icons.precision_manufacturing},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Analysis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...metrics.map((metric) => _buildMetricRow(
          metric['label'] as String,
          metric['value'] as double,
          metric['icon'] as IconData,
        )),
      ],
    );
  }

  Widget _buildMetricRow(String label, double value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ),
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (value / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${value.toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.mic),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _getGradientColors(result.score)[0],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDetailedAnalysis(context),
            icon: const Icon(Icons.analytics),
            label: const Text('View Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDetailedAnalysis(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DetailedAnalysisDialog(result: result),
    );
  }

  List<Color> _getGradientColors(double score) {
    if (score >= 85) {
      return [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]; // Green
    } else if (score >= 70) {
      return [const Color(0xFF2196F3), const Color(0xFF42A5F5)]; // Blue
    } else if (score >= 50) {
      return [const Color(0xFFFF9800), const Color(0xFFFFB74D)]; // Orange
    } else {
      return [const Color(0xFFF44336), const Color(0xFFEF5350)]; // Red
    }
  }

  IconData _getScoreIcon(double score) {
    if (score >= 85) {
      return Icons.celebration;
    } else if (score >= 70) {
      return Icons.thumb_up;
    } else if (score >= 50) {
      return Icons.trending_up;
    } else {
      return Icons.school;
    }
  }
}

class DetailedAnalysisDialog extends StatelessWidget {
  final AnalysisResult result;

  const DetailedAnalysisDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detailed Analysis'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Target Letter', result.targetLetter.toUpperCase()),
            _buildDetailRow('Overall Score', '${result.score.toInt()}/100'),
            _buildDetailRow('Performance Level', result.level),
            const Divider(),
            const Text('Technical Metrics:', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildDetailRow('DTW Similarity', '${result.dtw_similarity.toInt()}%'),
            _buildDetailRow('Feature Similarity', '${result.feature_similarity.toInt()}%'),
            _buildDetailRow('Correlation Score', '${(result.correlation * 100).toInt()}%'),
            _buildDetailRow('RMSE Similarity', '${result.rmse_similarity.toInt()}%'),
            const Divider(),
            const Text('Specific Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (result.pitch_level.isNotEmpty) 
              Text('• ${result.pitch_level}', style: const TextStyle(fontSize: 14)),
            if (result.stability.isNotEmpty)
              Text('• ${result.stability}', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}