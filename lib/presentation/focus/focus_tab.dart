import 'dart:async';
import 'package:flutter/material.dart';

class FocusTab extends StatefulWidget {
  const FocusTab({super.key});

  @override
  State<FocusTab> createState() => _FocusTabState();
}

class _FocusTabState extends State<FocusTab> {
  static const int focusMinutes = 25;
  static const int breakMinutes = 5;

  int _remainingSeconds = focusMinutes * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  Timer? _timer;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() {
            _isRunning = false;
            _isBreak = !_isBreak;
            _remainingSeconds = (_isBreak ? breakMinutes : focusMinutes) * 60;
          });
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _remainingSeconds = focusMinutes * 60;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWide = screenWidth > 600;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48.0 : 24.0,
            vertical: screenHeight < 600 ? 16.0 : 0.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isBreak ? 'Break Time' : 'Focus Time',
                style: TextStyle(
                  fontSize: isWide ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 32),
              _TimerDisplay(
                remainingSeconds: _remainingSeconds,
                totalSeconds: (_isBreak ? breakMinutes : focusMinutes) * 60,
                isBreak: _isBreak,
                isWide: isWide,
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 48),
              _TimerControls(
                isRunning: _isRunning,
                onToggle: _toggleTimer,
                onReset: _resetTimer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isBreak;
  final bool isWide;
  final double screenWidth;

  const _TimerDisplay({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isBreak,
    required this.isWide,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final minutesStr = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final secondsStr = (remainingSeconds % 60).toString().padLeft(2, '0');
    final progress = remainingSeconds / totalSeconds;
    final timerSize = isWide ? 300.0 : (screenWidth * 0.6).clamp(200.0, 280.0);
    final timerFontSize = isWide
        ? 72.0
        : (screenWidth * 0.12).clamp(48.0, 64.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: timerSize,
          height: timerSize,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: isWide ? 14 : 12,
            backgroundColor: Colors.grey.shade200,
            color: isBreak
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '$minutesStr:$secondsStr',
          style: TextStyle(
            fontSize: timerFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TimerControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  const _TimerControls({
    required this.isRunning,
    required this.onToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton.large(
          onPressed: onToggle,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          elevation: 0,
          child: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 36),
        ),
        const SizedBox(width: 24),
        FloatingActionButton(
          onPressed: onReset,
          backgroundColor: Colors.red.shade100,
          elevation: 0,
          child: const Icon(Icons.refresh, color: Colors.red),
        ),
      ],
    );
  }
}
