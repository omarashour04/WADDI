// Route definitions
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String profile = '/profile';
  static const String venues = '/venues';
  static const String rooms = '/venues/:venueId/rooms';
  static const String users = '/users';
  static const String bookings = '/bookings/:userId';
  static const String reviews = '/reviews/:venueId';
  static const String support = '/support/:userId';
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminVenues = '/admin/venues';
  static const String adminBookings = '/admin/bookings';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminContent = '/admin/content';
  static const String adminNotifications = '/admin/notifications';
} 