import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../screens/payment_screen.dart';

class QRScanScreen extends StatefulWidget {
  final Machine machine;

  const QRScanScreen({
    Key? key,
    required this.machine,
  }) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _scanned = false;

  void _simulateQRScan() {
    setState(() => _scanned = true);

    // Simulate QR code read delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      // For demo, we'll directly navigate to payment
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            machine: widget.machine,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Machine QR Code'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_scanned) ...[
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.qr_code_2,
                      size: 200,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Point your camera at the QR code on the machine',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: _simulateQRScan,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Simulate QR Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00BCD4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Processing QR code...',
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
    );
  }
}
