import 'package:freezed_annotation/freezed_annotation.dart';

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
    String? productFamily,
    bool? usEmployees,
    String? usEmployeesSource,
    bool? euEmployees,
    String? euEmployeesSource,
    bool? usFactory,
    String? usFactorySource,
    bool? euFactory,
    String? euFactorySource,
    bool? usSupplier,
    String? usSupplierSource,
    bool? euSupplier,
    String? euSupplierSource,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEnabled,
    bool? isError,
    int? score,
  }) = _BrandLiteracy;

  factory BrandLiteracy.fromJson(Map<String, dynamic> json) =>
      _$BrandLiteracyFromJson(json);
}
