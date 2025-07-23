import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymobPaymentService {
  final String backendBaseUrl;
  PaymobPaymentService({required this.backendBaseUrl});

  Future<String?> initiatePayment({
    required String bookingId,
    required double amount,
    required String userEmail,
  }) async {
    final url = Uri.parse('$backendBaseUrl/initiatePaymobPayment');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bookingId': bookingId,
        'amount': amount,
        'userEmail': userEmail,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['paymentUrl'] as String?;
    } else {
      return null;
    }
  }
} 