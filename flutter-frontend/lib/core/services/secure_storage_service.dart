import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service to securely store sensitive data like API keys
class SecureStorageService {
  final FlutterSecureStorage _storage;
  
  // Keys used in secure storage
  static const String _apiKeyKey = "brand_api_key";
  
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
  
  /// Convenience method to ensure API key is set
  /// Loads the API key from .env file if it's not already in secure storage
  Future<void> ensureApiKeyIsSet() async {
    if (!await hasApiKey()) {
      // Get API key from .env file
      final apiKey = dotenv.env["API_KEY"];
      
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API key not found in .env file. Please ensure you have set up your .env file correctly.");
      }
      
      await saveApiKey(apiKey);
    }
  }
}
