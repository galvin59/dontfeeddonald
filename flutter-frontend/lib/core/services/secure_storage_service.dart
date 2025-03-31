import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // For kReleaseMode and String.fromEnvironment

/// Service to securely store sensitive data like API keys
class SecureStorageService {
  final FlutterSecureStorage _storage;
  
  // Keys used in secure storage
  static const String _apiKeyKey = "brand_api_key";
  // Environment variable name expected from .env or Platform.environment
  static const String _apiKeyEnvName = "API_KEY";
  
  // Singleton instance
  static final SecureStorageService _instance = SecureStorageService._internal();
  
  // Factory constructor to return the singleton instance
  factory SecureStorageService() => _instance;
  
  // Private constructor for singleton
  SecureStorageService._internal() 
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );
  
  /// Saves the API key securely
  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }
  
  /// Retrieves the API key
  Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }
  
  /// Checks if the API key exists
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
  
  /// Deletes the API key
  Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }
  
  /// Loads the API key from the initialized dotenv environment if it's not already in secure storage
  /// If not found, attempts to load it:
  ///  - In Release mode: Reads from the compile-time environment variable 'API_KEY' (set via --dart-define).
  ///  - In Non-Release mode: Reads from the loaded dotenv environment ('API_KEY').
  /// Stores the key securely if found and not already present.
  /// Throws an exception if the key cannot be found in the expected location for the current mode.
  Future<void> ensureApiKeyIsSet() async {
    if (!await hasApiKey()) {
      print("[SecureStorage] API Key not found in secure storage, trying to fetch...");
      String? envApiKey;

      if (kReleaseMode) {
        // In release builds, prioritize the compile-time variable set via --dart-define
        print("[SecureStorage] Running in RELEASE mode, checking compile-time define '$_apiKeyEnvName'...");
        const apiKeyFromDefine = String.fromEnvironment(_apiKeyEnvName);
        if (apiKeyFromDefine.isNotEmpty) {
          envApiKey = apiKeyFromDefine;
          print("[SecureStorage] API Key found via compile-time define.");
        } else {
          print("[SecureStorage] WARNING: Compile-time define '$_apiKeyEnvName' is empty or not set in RELEASE mode!");
          // Optional: Fallback to dotenv even in release? Or just fail?
          // For now, we assume --dart-define is the primary source in release.
        }
      } else {
        // In non-release (debug/profile) builds, use dotenv
        print("[SecureStorage] Running in NON-RELEASE mode, checking dotenv environment '$_apiKeyEnvName'...");
        // dotenv.load() should have been called in main()
        envApiKey = dotenv.maybeGet(_apiKeyEnvName);
        if (envApiKey != null && envApiKey.isNotEmpty) {
             print("[SecureStorage] API Key found via dotenv.");
        } else {
             print("[SecureStorage] WARNING: API Key not found via dotenv in NON-RELEASE mode!");
        }
      }

      if (envApiKey != null && envApiKey.isNotEmpty) {
        print("[SecureStorage] API Key found ('$_apiKeyEnvName'), storing securely...");
        await saveApiKey(envApiKey);
      } else {
        // If key is still null/empty after checking the appropriate source
        String errorMessage = kReleaseMode
            ? "FATAL: API Key not found via compile-time define '$_apiKeyEnvName'. Ensure --dart-define=API_KEY=... is set correctly in the CI build command for RELEASE."
            : "FATAL: API Key not found via dotenv key '$_apiKeyEnvName'. Ensure it's in your .env file for NON-RELEASE.";
        print("[SecureStorage] $errorMessage");
        throw Exception(errorMessage); 
      }
    } else {
       print("[SecureStorage] API Key already present in secure storage.");
    }
  }
}
