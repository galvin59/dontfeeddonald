import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  Future<void> ensureApiKeyIsSet() async {
    if (!await hasApiKey()) {
      print("[SecureStorage] API Key not found in secure storage, trying to fetch from dotenv environment...");
      // dotenv.load() should have been called in main(), merging .env and Platform.environment.
      // Now we just need to read from the initialized dotenv.
      String? envApiKey = dotenv.maybeGet(_apiKeyEnvName);

      if (envApiKey != null && envApiKey.isNotEmpty) {
        print("[SecureStorage] API Key found in dotenv environment ('$_apiKeyEnvName'), storing securely...");
        await saveApiKey(envApiKey);
      } else {
        print("[SecureStorage] FATAL: API Key not found in the loaded dotenv environment using key '$_apiKeyEnvName'! Ensure it's in .env (local) or Platform env (CI).");
        // This is likely the cause of the white screen in release.
        // Throw an exception to make the failure clear during startup.
        throw Exception("API Key configuration error: Variable '$_apiKeyEnvName' not found in loaded environment.");
      }
    } else {
       print("[SecureStorage] API Key already present in secure storage.");
    }
  }
}
