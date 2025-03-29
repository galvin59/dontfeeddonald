import 'package:dont_feed_donald/data/models/brand_search_result.dart';
import 'package:dont_feed_donald/data/services/brand_api_service.dart';

/// Repository class for brand-related operations
class BrandRepository {
  final BrandApiService _apiService;

  BrandRepository({BrandApiService? apiService})
      : _apiService = apiService ?? BrandApiService();

  /// Initialize the repository
  Future<void> initialize() async {
    await _apiService.initialize();
  }

  /// Search for brands matching the query
  Future<List<BrandSearchResult>> searchBrands(String query) async {
    return await _apiService.searchBrands(query);
  }
  
  /// Get detailed brand literacy information for a brand
  /// Returns a map containing the BrandLiteracy object and the computed score
  Future<Map<String, dynamic>> getBrandLiteracy(String brandId) async {
    return await _apiService.getBrandLiteracy(brandId);
  }
}
