class ApiConfig {
  // IMPORTANT: For "without same WiFi" and "permanent" access:
  // 1. Deploy your backend to Render.com
  // 2. Copy your Render URL (e.g., https://bus-app.onrender.com/api)
  // 3. Paste it below as the 'defaultValue'
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bus-ticketing-app.onrender.com/api', // Render Cloud URL
  );

  // You can also use this for automatic platform detection if needed:
  // static String get baseUrl {
  //   if (UniversalPlatform.isAndroid) return 'http://10.0.2.2:8080/api';
  //   return 'http://localhost:8080/api';
  // }
}
