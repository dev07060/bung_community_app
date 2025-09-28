// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Our Bung Play';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String channelsCollection = 'channels';
  static const String eventsCollection = 'events';
  static const String settlementsCollection = 'settlements';
  static const String rulesCollection = 'rules';
  static const String chatHistoryCollection = 'chatHistory';
  static const String notificationsCollection = 'notifications';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String eventImagesPath = 'event_images';
  static const String receiptImagesPath = 'receipt_images';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(minutes: 5);
}