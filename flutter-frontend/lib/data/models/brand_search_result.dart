import 'package:json_annotation/json_annotation.dart';

part 'brand_search_result.g.dart';

/// Model representing a brand search result from the API
@JsonSerializable()
class BrandSearchResult {
  final String id;
  final String name;
  final String? logoUrl;

  BrandSearchResult({required this.id, required this.name, this.logoUrl});

  factory BrandSearchResult.fromJson(Map<String, dynamic> json) =>
      _$BrandSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$BrandSearchResultToJson(this);
}
