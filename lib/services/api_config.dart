class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  // You can also use this for automatic platform detection if needed:
  // static String get baseUrl {
  //   if (UniversalPlatform.isAndroid) return 'http://10.0.2.2:8080/api';
  //   return 'http://localhost:8080/api';
  // }
}
