import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for application settings
class AppConfig {
  static const String _missingReleaseUrlError = "FATAL: API_BASE_URL not defined via --dart-define for release build!";
  static const String _missingDotEnvUrlError = "FATAL: API_BASE_URL not found in the loaded .env file for this build mode!";

  /// Returns the API base URL based on build mode
  static String get apiBaseUrl {
    if (kReleaseMode) {
      // In release, read directly from the compile-time define
      const url = String.fromEnvironment('API_BASE_URL');
      if (url.isEmpty) {
        print(_missingReleaseUrlError);
        throw Exception(_missingReleaseUrlError);
      }
      return url;
    } else {
      // In non-release (debug/profile) modes, require the key to be in .env
      try {
        // dotenv.get throws if the key is not found and no fallback is provided
        final url = dotenv.get('API_BASE_URL');
        // Optional: Add check for empty string, although dotenv.get usually ensures non-empty
        if (url.isEmpty) {
             print("$_missingDotEnvUrlError (Value was empty)");
             throw Exception("$_missingDotEnvUrlError (Value was empty)");
        }
        return url;
      } catch (e) {
        // Catch the error from dotenv.get if the key is missing
        print("$_missingDotEnvUrlError Error: $e");
        throw Exception("$_missingDotEnvUrlError Please ensure API_BASE_URL is set in your .env file.");
      }
    }
  }

  /// API paths
  static const String brandSearchPath = "brands/public/search";
  static const String brandDetailsPath = "brands/public";
}
