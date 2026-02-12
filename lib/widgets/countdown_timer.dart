import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int secondsRemaining;
  final VoidCallback? onComplete;
  final bool showLabel;

  const CountdownTimer({
    Key? key,
    required this.secondsRemaining,
    this.onComplete,
    this.showLabel = true,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> with TickerProviderStateMixin {
  late AnimationController _controller;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.secondsRemaining;
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secondsRemaining != widget.secondsRemaining) {
      _remainingSeconds = widget.secondsRemaining;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getColor() {
    if (_remainingSeconds > 600) return Colors.teal; // > 10 mins
    if (_remainingSeconds > 300) return Colors.orange; // > 5 mins
    return Colors.red; // <= 5 mins
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showLabel)
          Text(
            'Time Remaining',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getColor().withAlpha(51), // 20% opacity
            border: Border.all(
              color: _getColor(),
              width: 3,
            ),
          ),
          child: Text(
            _formatTime(_remainingSeconds),
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: _getColor(),
              fontFamily: 'Courier',
            ),
          ),
        ),
      ],
    );
  }
}
