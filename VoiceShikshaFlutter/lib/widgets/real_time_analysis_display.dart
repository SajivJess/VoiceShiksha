import 'package:flutter/material.dart';
import 'dart:math' as math;

class RealTimeAnalysisDisplay extends StatefulWidget {
  final bool isAnalyzing;
  final Map<String, dynamic>? analysisData;

  const RealTimeAnalysisDisplay({
    super.key,
    required this.isAnalyzing,
    this.analysisData,
  });

  @override
  State<RealTimeAnalysisDisplay> createState() => _RealTimeAnalysisDisplayState();
}

class _RealTimeAnalysisDisplayState extends State<RealTimeAnalysisDisplay>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isAnalyzing) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(RealTimeAnalysisDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isAnalyzing && !oldWidget.isAnalyzing) {
      _startAnimations();
    } else if (!widget.isAnalyzing && oldWidget.isAnalyzing) {
      _stopAnimations();
    }
  }

  void _startAnimations() {
    _waveController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _waveController.stop();
    _pulseController.stop();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnalyzing && widget.analysisData == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: widget.isAnalyzing ? _buildAnalyzingView() : _buildResultsView(),
    );
  }

  Widget _buildAnalyzingView() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            '🧠 AI Analysis in Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Animated Visualization
          SizedBox(
            height: 100,
            child: AnimatedBuilder(
              animation: Listenable.merge([_waveAnimation, _pulseAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  painter: WaveformPainter(
                    wavePhase: _waveAnimation.value,
                    amplitude: _pulseAnimation.value,
                  ),
                  size: const Size(double.infinity, 100),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Analysis Steps
          Column(
            children: [
              _buildAnalysisStep('Extracting pitch features...', 0, true),
              _buildAnalysisStep('Comparing with reference data...', 1, widget.isAnalyzing),
              _buildAnalysisStep('Calculating similarity metrics...', 2, widget.isAnalyzing),
              _buildAnalysisStep('Generating feedback...', 3, widget.isAnalyzing),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisStep(String text, int step, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300 + (step * 100)),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isActive ? Colors.purple : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: isActive
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? Colors.purple[800] : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    if (widget.analysisData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.purple[800],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Real-time Analysis Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Metrics Grid
          SizedBox(
            height: 140, // Fixed height to prevent constraint issues
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMetricCard(
                  'Pitch Accuracy',
                  '${widget.analysisData!['pitch_accuracy'] ?? 75}%',
                  Icons.graphic_eq,
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Voice Stability',
                  '${widget.analysisData!['stability'] ?? 82}%',
                  Icons.multiline_chart,
                  Colors.green,
                ),
                _buildMetricCard(
                  'Pronunciation',
                  '${widget.analysisData!['pronunciation'] ?? 78}%',
                  Icons.record_voice_over,
                  Colors.orange,
                ),
                _buildMetricCard(
                  'Overall Score',
                  '${widget.analysisData!['overall_score'] ?? 80}%',
                  Icons.stars,
                  Colors.purple,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Live feedback
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.analysisData!['feedback'] ?? 'Good pronunciation! Keep practicing.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double wavePhase;
  final double amplitude;

  WaveformPainter({
    required this.wavePhase,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final path = Path();

    // Draw multiple waveforms
    for (int i = 0; i < 3; i++) {
      final frequency = 0.02 * (i + 1);
      final phaseOffset = wavePhase + (i * math.pi / 4);
      final waveAmplitude = (20 + i * 5) * amplitude;

      path.reset();
      
      for (double x = 0; x <= size.width; x += 2) {
        final y = centerY + 
          math.sin(x * frequency + phaseOffset) * waveAmplitude +
          math.sin(x * frequency * 2 + phaseOffset) * (waveAmplitude * 0.3);
        
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      paint.color = Colors.purple.withOpacity(0.6 - i * 0.15);
      canvas.drawPath(path, paint);
    }

    // Draw center line
    paint.color = Colors.purple.withOpacity(0.3);
    paint.strokeWidth = 1;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}