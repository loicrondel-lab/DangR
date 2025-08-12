class AppConfig {
  // MapLibre GL
  static const String mapLibreToken = 'YOUR_MAPLIBRE_TOKEN';
  static const String mapLibreStyle = 'https://api.maptiler.com/maps/streets/style.json?key=$mapLibreToken';
  
  // Supabase
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String supabaseServiceRoleKey = 'YOUR_SUPABASE_SERVICE_ROLE_KEY';
  
  // Firebase
  static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID';
  static const String firebaseMessagingSenderId = 'YOUR_FIREBASE_SENDER_ID';
  
  // Sentry
  static const String sentryDsn = 'YOUR_SENTRY_DSN';
  
  // API Endpoints
  static const String apiBaseUrl = supabaseUrl;
  static const String hazardsEndpoint = '/rest/v1/hazards';
  static const String usersEndpoint = '/rest/v1/users';
  static const String votesEndpoint = '/rest/v1/votes';
  
  // App Settings
  static const String appName = 'DangR';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Restez informé des dangers autour de vous';
  
  // Map Settings
  static const double defaultZoom = 14.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 10.0;
  static const double defaultRadius = 5000.0; // 5km
  
  // Location Settings
  static const int locationUpdateInterval = 10000; // 10 seconds
  static const double locationAccuracy = 10.0; // 10 meters
  static const int geofenceRadius = 100; // 100 meters
  
  // Notification Settings
  static const String notificationChannelId = 'dangr_channel';
  static const String notificationChannelName = 'DangR Notifications';
  static const String notificationChannelDescription = 'Notifications pour les incidents et alertes';
  
  // Cache Settings
  static const int maxCacheAge = 30; // days
  static const int maxCacheSize = 100; // MB
  
  // Performance Settings
  static const int maxHazardsPerRequest = 100;
  static const int maxPhotosPerHazard = 5;
  static const int maxDescriptionLength = 500;
  
  // Security Settings
  static const int maxRequestsPerMinute = 60;
  static const int maxReportsPerHour = 10;
  static const int minPasswordLength = 6;
  
  // Feature Flags
  static const bool enableAnonymousAuth = true;
  static const bool enablePhotoUpload = true;
  static const bool enableRealTimeUpdates = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Development Settings
  static const bool isDevelopment = true;
  static const bool enableDebugLogs = true;
  static const bool enableMockData = false;
  
  // URLs
  static const String privacyPolicyUrl = 'https://dangr.app/privacy';
  static const String termsOfServiceUrl = 'https://dangr.app/terms';
  static const String supportUrl = 'https://dangr.app/support';
  static const String websiteUrl = 'https://dangr.app';
  
  // Social Media
  static const String twitterUrl = 'https://twitter.com/dangr_app';
  static const String facebookUrl = 'https://facebook.com/dangr_app';
  static const String instagramUrl = 'https://instagram.com/dangr_app';
  
  // Contact
  static const String contactEmail = 'contact@dangr.app';
  static const String supportEmail = 'support@dangr.app';
  
  // Legal
  static const String companyName = 'DangR SAS';
  static const String companyAddress = '123 Rue de la Paix, 75001 Paris, France';
  static const String companySiret = '12345678901234';
  
  // Colors (for reference)
  static const int primaryOrangeHex = 0xFFFF5722;
  static const int backgroundLightHex = 0xFFF5F5F5;
  static const int textPrimaryDarkHex = 0xFF212121;
  static const int textSecondaryHex = 0xFF757575;
  static const int successHex = 0xFF4CAF50;
  static const int warningHex = 0xFFFF9800;
  static const int errorHex = 0xFFF44336;
  static const int infoHex = 0xFF2196F3;
}
