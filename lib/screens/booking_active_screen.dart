import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../providers/machine_provider.dart';
import '../services/notification_service.dart';
import '../widgets/countdown_timer.dart';

class BookingActiveScreen extends StatefulWidget {
  final Booking booking;
  final String machineName;

  const BookingActiveScreen({
    Key? key,
    required this.booking,
    required this.machineName,
  }) : super(key: key);

  @override
  State<BookingActiveScreen> createState() => _BookingActiveScreenState();
}

class _BookingActiveScreenState extends State<BookingActiveScreen> {
  late Timer _updateTimer;
  bool _notificationShown = false;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});

      // Check if wash is complete
      if (widget.booking.timeRemaining == 0 && !_notificationShown) {
        _notificationShown = true;
        NotificationService().showWashCompleteNotification(widget.booking.machineId);
        _showCompletionDialog();
      }

      // Show notification 5 minutes before completion
      if (widget.booking.timeRemaining == 300 && widget.booking.timeRemaining != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('5 minutes remaining!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Wash Complete!'),
        content: const Text('Your laundry is ready. Please collect it from the machine.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.read<BookingProvider>().clearBooking(); // Clear booking
              context.read<MachineProvider>().setMachineFree(widget.booking.machineId); // Free machine
              // No need to pop - the UI will rebuild automatically via Consumer
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Active Booking'),
          backgroundColor: const Color(0xFF00BCD4),
          automaticallyImplyLeading: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                Text(
                  'Machine: ${widget.machineName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(204), // 80% opacity
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CountdownTimer(
                    secondsRemaining: widget.booking.timeRemaining ?? 0,
                    showLabel: true,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[800]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You will be notified when your laundry is ready.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
