import 'package:intl/intl.dart';

// Date formatting utilities
String formatDate(DateTime date) {
  final formatter = DateFormat('yyyy-MM-dd HH:mm');
  return formatter.format(date);
} 