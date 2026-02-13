import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import '../models/machine.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/machine_provider.dart';
import '../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final Machine machine;

  const PaymentScreen({
    Key? key,
    required this.machine,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentService _paymentService;
  bool _isProcessing = false;
  bool _paymentSuccess = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final success = await _paymentService.processPayment(5.00);

      if (!mounted) return;

      setState(() {
        _paymentSuccess = success;
        _isProcessing = false;
      });

      if (success) {
        // Create booking
        final currentUser = context.read<AuthProvider>().currentUser;
        if (currentUser != null) {
          final booking = Booking(
            id: const Uuid().v4(),
            userId: currentUser.matricId,
            machineId: widget.machine.id,
            startTime: DateTime.now(),
            estimatedDuration: const Duration(seconds: 10),
          );

          // Update machine status
          context.read<MachineProvider>().setMachineInUse(
            widget.machine.id,
            currentUser.matricId,
            const Duration(seconds: 10),
          );

          // Set active booking
          context.read<BookingProvider>().setActiveBooking(booking);

          // Show success dialog
          _showSuccessDialog();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: const Text('Payment processed. Your 45-minute wash cycle has started.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFF00BCD4),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                if (!_paymentSuccess) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_laundry_service,
                          size: 80,
                          color: const Color(0xFF00BCD4),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Wash Cycle Booking',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow('Machine:', widget.machine.name),
                              const SizedBox(height: 12),
                              _buildDetailRow('Duration:', '10 seconds'),
                              const SizedBox(height: 12),
                              _buildDetailRow('Price:', '\$5.00'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange[800]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You will receive a notification when your laundry is done.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF00BCD4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF00BCD4)),
                        ),
                      )
                          : const Text(
                        'Pay \$5.00',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Payment Successful!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your wash cycle has started. You will receive a notification when your laundry is done.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
