import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:dont_feed_donald/core/config/app_config.dart';
import 'package:dont_feed_donald/core/services/secure_storage_service.dart';
import 'package:dont_feed_donald/data/models/brand_search_result.dart';
import 'package:dont_feed_donald/domain/entities/brand_literacy.dart';

/// Service to interact with the brand API
class BrandApiService {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  
  BrandApiService({Dio? dio}) 
      : _dio = dio ?? Dio(),
        _secureStorage = SecureStorageService();

  /// Initialize the service
  Future<void> initialize() async {
    // Ensure API key is set
    await _secureStorage.ensureApiKeyIsSet();
    
    // Configure Dio to log all requests and responses during development
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Search for brands based on a query string
  /// Returns a list of BrandSearchResult objects
  Future<List<BrandSearchResult>> searchBrands(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    try {
      // Get the API key from secure storage
      final apiKey = await _secureStorage.getApiKey();
      if (apiKey == null) {
        throw Exception("API key not found");
      }

      // Format the query - trim whitespace
      String formattedQuery = query.trim();
      
      // Create the full request URL for the Node.js API
      final url = "${AppConfig.apiBaseUrl}/api/brands/lookup";
      
      // Make the API request
      final response = await _dio.get(
        url,
        queryParameters: {'query': formattedQuery},
        options: Options(
          headers: {
            'X-API-Key': apiKey,
            'Accept': 'application/json',
          },
        ),
      );
      

      // Process the response
      if (response.statusCode == 200) {
        // Convert the response data to a list of BrandSearchResult objects
        final List<dynamic> data = response.data;
        
        // Convert to BrandSearchResult objects
        final results = data.map((item) => BrandSearchResult.fromJson(item)).toList();
        
        return results;
      } else {
        throw Exception('Failed to search brands: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Enhanced error logging for API debugging
      developer.log("=== DioException Details ===");
      developer.log("Message: ${e.message}");
      developer.log("Request URL: ${e.requestOptions.uri}");
      developer.log("Method: ${e.requestOptions.method}");
      developer.log("Headers: ${e.requestOptions.headers}");
      developer.log("Query Parameters: ${e.requestOptions.queryParameters}");
      developer.log("Response Status: ${e.response?.statusCode}");
      developer.log("Response Data: ${e.response?.data}");
      
      // Let's try to provide a specific error message to help debug
      String errorMsg = 'Error searching brands';
      if (e.response?.statusCode == 404) {
        errorMsg += ': Endpoint not found (404). The API route might be incorrect or the server is unavailable.';
      } else if (e.response?.statusCode == 403) {
        errorMsg += ': Access forbidden (403). Check if the API key is valid.';
      } else if (e.response?.statusCode == 401) {
        errorMsg += ': Unauthorized (401). The API key might be invalid or expired.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg += ': Connection timeout. The server might be down or unreachable.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg += ': Connection error. Check your network connection and server status.';
      } else {
        errorMsg += ': ${e.message}';
      }
      
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error searching brands: $e');
    }
  }
  
  /// Fetch brand literacy details for a specific brand
  /// Returns a BrandLiteracy object with all available information
  /// and a computed score from the backend
  Future<Map<String, dynamic>> getBrandLiteracy(String brandId) async {
    try {
      // Get the API key from secure storage
      final apiKey = await _secureStorage.getApiKey();
      if (apiKey == null) {
        throw Exception("API key not found");
      }
      
      // Use the Node.js API endpoint for getting brand by ID
      final url = "${AppConfig.apiBaseUrl}/api/brands/$brandId";
      
      // Make the API request
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'X-API-Key': apiKey,
            'Accept': 'application/json',
          },
        ),
      );
      

      // Process the response
      if (response.statusCode == 200) {
        // Convert the response data to a BrandLiteracy object
        final data = response.data;
        
        // Extract the score from the response
        final int? score = data['score'] as int?;
        
        // Remove the score from the data before converting to BrandLiteracy
        if (data.containsKey('score')) {
          data.remove('score');
        }
        
        // Convert to BrandLiteracy object and return with score
        return {
          'brandLiteracy': BrandLiteracy.fromJson(data),
          'score': score,
        };
      } else {
        throw Exception('Failed to fetch brand literacy: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Enhanced error logging for API debugging
      developer.log("=== DioException Details ===");
      developer.log("Message: ${e.message}");
      developer.log("Request URL: ${e.requestOptions.uri}");
      developer.log("Method: ${e.requestOptions.method}");
      developer.log("Headers: ${e.requestOptions.headers}");
      developer.log("Query Parameters: ${e.requestOptions.queryParameters}");
      developer.log("Response Status: ${e.response?.statusCode}");
      developer.log("Response Data: ${e.response?.data}");
      
      String errorMsg = 'Error fetching brand literacy';
      if (e.response?.statusCode == 404) {
        errorMsg += ': Brand not found (404).';
      } else if (e.response?.statusCode == 403) {
        errorMsg += ': Access forbidden (403). Check if the API key is valid.';
      } else if (e.response?.statusCode == 401) {
        errorMsg += ': Unauthorized (401). The API key might be invalid or expired.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg += ': Connection timeout. The server might be down or unreachable.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg += ': Connection error. Check your network connection and server status.';
      } else {
        errorMsg += ': ${e.message}';
      }
      
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error fetching brand literacy: $e');
    }
  }
}
