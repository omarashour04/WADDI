class EmailConfig {
  // Email service configuration
  static const String fromEmail = 'noreply@waddi.com';
  static const String fromName = 'WADDI Platform';
  
  // Email templates
  static const String confirmationSubject = '🎉 Booking Confirmed - {venueName}';
  static const String cancellationSubject = '❌ Booking Cancelled - {venueName}';
  static const String reminderSubject = '⏰ Booking Reminder - {venueName}';
  
  // Email content placeholders
  static const String userNamePlaceholder = '{userName}';
  static const String venueNamePlaceholder = '{venueName}';
  static const String bookingIdPlaceholder = '{bookingId}';
  static const String datePlaceholder = '{date}';
  static const String timePlaceholder = '{time}';
  static const String amountPlaceholder = '{amount}';
  
  // Email settings
  static const bool enableEmailNotifications = true;
  static const bool enableConfirmationEmails = true;
  static const bool enableCancellationEmails = true;
  static const bool enableReminderEmails = true;
  
  // Reminder settings (in hours before booking)
  static const int reminderHoursBeforeBooking = 24;
  
  // Email retry settings
  static const int maxEmailRetries = 3;
  static const Duration emailRetryDelay = Duration(seconds: 5);
} 