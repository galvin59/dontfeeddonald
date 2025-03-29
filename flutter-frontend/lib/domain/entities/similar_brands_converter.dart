import 'package:json_annotation/json_annotation.dart';

/// A custom converter for handling similarBrandsEu field that can be either a String or a List<String>
class SimilarBrandsConverter implements JsonConverter<List<String>?, dynamic> {
  const SimilarBrandsConverter();

  @override
  List<String>? fromJson(dynamic json) {
    if (json == null) {
      return null;
    }

    // If it's already a list, convert each element to String
    if (json is List) {
      return json.map((e) => e.toString()).toList();
    }

    // If it's a string, split by commas and trim each item
    if (json is String) {
      if (json.isEmpty) {
        return [];
      }
      return json.split(',').map((e) => e.trim()).toList();
    }

    // Default fallback
    return [];
  }

  @override
  dynamic toJson(List<String>? object) {
    if (object == null) {
      return null;
    }
    return object;
  }
}
