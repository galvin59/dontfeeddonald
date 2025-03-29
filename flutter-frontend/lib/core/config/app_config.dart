import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for application settings
class AppConfig {
  /// Returns the API base URL from environment variables based on build mode
  static String get apiBaseUrl {
    if (kReleaseMode) {
      return dotenv.env["API_BASE_URL_PROD"] ?? "https://api.example.com/api";
    } else if (kProfileMode) {
      return dotenv.env["API_BASE_URL_TEST"] ?? "http://test-api.example.com/api";
    } else {
      return dotenv.env["API_BASE_URL_DEV"] ?? "http://localhost:3001/api";
    }
  }

  /// API paths
  static const String brandSearchPath = "brands/public/search";
  static const String brandDetailsPath = "brands/public";
}
