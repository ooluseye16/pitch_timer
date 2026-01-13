import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _isConfiguring = true;

  final TextEditingController _minutesController = TextEditingController(
    text: '5',
  );
  final TextEditingController _secondsController = TextEditingController(
    text: '0',
  );

  @override
  void dispose() {
    _timer?.cancel();
    _minutesController.dispose();
    _secondsController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startTimer() {
    if (_isConfiguring) {
      // Parse input and start timer
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
    } else {
      // Resume timer
      setState(() {
        _isRunning = true;
      });
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        WakelockPlus.disable();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isConfiguring = true;
      _remainingSeconds = 0;
      _totalSeconds = 0;
    });
    WakelockPlus.disable();
  }

  Color _getBackgroundColor() {
    if (_totalSeconds == 0) return Colors.grey[100]!;

    final percentage = _remainingSeconds / _totalSeconds;

    if (percentage > 0.5) {
      // Green zone (100% - 50%)
      return Colors.green[400]!;
    } else if (percentage > 0.25) {
      // Yellow zone (50% - 25%)
      return Colors.yellow[600]!;
    } else {
      // Red zone (25% - 0%)
      return Colors.red[400]!;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pitch Timer',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isConfiguring) ...[
                // Configuration UI
                const Text(
                  'Set Timer Duration',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Minutes input
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Seconds input
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _secondsController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Seconds',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Timer display
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],

              const SizedBox(height: 60),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isConfiguring) ...[
                    // Pause/Resume button
                    ElevatedButton(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isRunning ? 'Pause' : 'Resume',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Reset button
                    ElevatedButton(
                      onPressed: _resetTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Start button
                    ElevatedButton(
                      onPressed: _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
