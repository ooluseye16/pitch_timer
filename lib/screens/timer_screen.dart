import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _isConfiguring = true;

  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _minutesController = TextEditingController(
    text: '5',
  );
  final TextEditingController _secondsController = TextEditingController(
    text: '0',
  );

  @override
  void initState() {
    super.initState();

    // Pulse animation for timer
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Scale animation for buttons
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Rotation animation for reset
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startTimer() {
    HapticFeedback.mediumImpact();

    if (_isConfiguring) {
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final seconds = int.tryParse(_secondsController.text) ?? 0;
      _totalSeconds = (minutes * 60) + seconds;

      if (_totalSeconds <= 0) return;

      setState(() {
        _remainingSeconds = _totalSeconds;
        _isConfiguring = false;
        _isRunning = true;
      });

      WakelockPlus.enable();
      _pulseController.repeat(reverse: true);
    } else {
      setState(() {
        _isRunning = true;
      });
      _pulseController.repeat(reverse: true);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });

        // Haptic feedback at critical moments
        if (_remainingSeconds == _totalSeconds ~/ 2 ||
            _remainingSeconds == _totalSeconds ~/ 4 ||
            _remainingSeconds == 10) {
          HapticFeedback.lightImpact();
        }
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        _pulseController.stop();
        WakelockPlus.disable();
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _pauseTimer() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    HapticFeedback.heavyImpact();
    _timer?.cancel();
    _pulseController.stop();
    _rotationController.forward(from: 0);

    setState(() {
      _isRunning = false;
      _isConfiguring = true;
      _remainingSeconds = 0;
      _totalSeconds = 0;
    });
    WakelockPlus.disable();
  }

  Color _getBackgroundColor() {
    if (_totalSeconds == 0) return const Color(0xFFF5F5F5);

    final percentage = _remainingSeconds / _totalSeconds;

    if (percentage > 0.5) {
      return const Color(0xFF66BB6A); // Green
    } else if (percentage > 0.25) {
      return const Color(0xFFFFA726); // Orange
    } else {
      return const Color(0xFFEF5350); // Red
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getBackgroundColor(),
            _getBackgroundColor().withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //   backgroundColor: Colors.white.withValues(alpha: 0.95),
        //   elevation: 0,
        //   title: const Text(
        //     'Pitch Timer',
        //     style: TextStyle(
        //       color: Colors.black,
        //       fontWeight: FontWeight.w600,
        //       letterSpacing: 0.5,
        //     ),
        //   ),
        // ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isConfiguring) ...[
                  _buildConfigurationUI(),
                ] else ...[
                  _buildTimerDisplay(),
                ],

                const SizedBox(height: 60),

                _buildControlButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationUI() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Set Timer Duration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeInput(_minutesController, 'Minutes'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildTimeInput(_secondsController, 'Seconds'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String label) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: '00',
              hintStyle: TextStyle(
                color: Colors.grey[300],
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Column(
        children: [
          // Circular progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    progress: _totalSeconds > 0
                        ? _remainingSeconds / _totalSeconds
                        : 0,
                    color: Colors.white,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRunning ? _pulseAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Progress percentage
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(
              begin: 0,
              end: _totalSeconds > 0
                  ? (_remainingSeconds / _totalSeconds * 100)
                  : 0,
            ),
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isConfiguring) ...[
          _buildAnimatedButton(
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            label: _isRunning ? 'Pause' : 'Resume',
            isPrimary: true,
          ),
          const SizedBox(width: 16),
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: child,
              );
            },
            child: _buildAnimatedButton(
              onPressed: _resetTimer,
              icon: Icons.refresh_rounded,
              label: 'Reset',
              isPrimary: false,
            ),
          ),
        ] else ...[
          _buildAnimatedButton(
            onPressed: _startTimer,
            icon: Icons.play_arrow_rounded,
            label: 'Start',
            isPrimary: true,
            isLarge: true,
          ),
        ],
      ],
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
    bool isLarge = false,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          borderRadius: BorderRadius.circular(isLarge ? 24 : 20),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isLarge ? 48 : 32,
                vertical: isLarge ? 20 : 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPrimary
                      ? [Colors.white, Colors.white.withValues(alpha: 0.9)]
                      : [Colors.black87, Colors.black],
                ),
                borderRadius: BorderRadius.circular(isLarge ? 24 : 20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isPrimary ? Colors.black : Colors.white,
                    size: isLarge ? 32 : 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isLarge ? 24 : 18,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
