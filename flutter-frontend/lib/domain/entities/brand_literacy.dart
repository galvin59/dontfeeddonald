import 'package:freezed_annotation/freezed_annotation.dart';
import 'similar_brands_converter.dart';

part 'brand_literacy.freezed.dart';
part 'brand_literacy.g.dart';

@freezed
class BrandLiteracy with _$BrandLiteracy {
  const factory BrandLiteracy({
    required String id,
    required String name,
    String? parentCompany,
    String? brandOrigin,
    String? logoUrl,
    @SimilarBrandsConverter()
    List<String>? similarBrandsEu,
    String? productFamily,
    String? totalEmployees,
    String? totalEmployeesSource,
    String? employeesUS,
    String? employeesUSSource,
    String? economicImpact,
    String? economicImpactSource,
    bool? factoryInFrance,
    String? factoryInFranceSource,
    bool? factoryInEU,
    String? factoryInEUSource,
    bool? frenchFarmer,
    String? frenchFarmerSource,
    bool? euFarmer,
    String? euFarmerSource,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEnabled,
    bool? isError,
  }) = _BrandLiteracy;

  factory BrandLiteracy.fromJson(Map<String, dynamic> json) => _$BrandLiteracyFromJson(json);
}
