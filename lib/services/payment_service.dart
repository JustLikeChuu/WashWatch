class PaymentService {
  Future<bool> processPayment(double amount) async {
    // Simulate payment processing with 2 second delay
    await Future.delayed(const Duration(seconds: 2));
    return true; // Always succeed for hackathon demo
  }
}
