import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  // Toggle this for local vs production testing
  // Set to false for production (Render)
  static const bool useLocalBackend = false;

  // Render Production URL
  static const String _productionUrl = 'https://bus-ticketing-backend-1g2n.onrender.com/api';
  
  // Local Development URLs
  static const String _androidLocalUrl = 'http://10.0.2.2:8080/api';
  static const String _standardLocalUrl = 'http://localhost:8080/api';

  static String get baseUrl {
    if (!useLocalBackend) return _productionUrl;
    
    if (kIsWeb) {
      return _standardLocalUrl;
    }
    
    try {
      if (Platform.isAndroid) {
        return _androidLocalUrl;
      }
    } catch (e) {
      // Platform might not be available on all platforms
    }
    
    return _standardLocalUrl;
  }
}
