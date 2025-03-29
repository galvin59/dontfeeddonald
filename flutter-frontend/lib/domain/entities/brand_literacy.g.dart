// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_literacy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BrandLiteracyImpl _$$BrandLiteracyImplFromJson(Map<String, dynamic> json) =>
    _$BrandLiteracyImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      parentCompany: json['parentCompany'] as String?,
      brandOrigin: json['brandOrigin'] as String?,
      logoUrl: json['logoUrl'] as String?,
      similarBrandsEu: const SimilarBrandsConverter().fromJson(
        json['similarBrandsEu'],
      ),
      productFamily: json['productFamily'] as String?,
      totalEmployees: json['totalEmployees'] as String?,
      totalEmployeesSource: json['totalEmployeesSource'] as String?,
      employeesUS: json['employeesUS'] as String?,
      employeesUSSource: json['employeesUSSource'] as String?,
      economicImpact: json['economicImpact'] as String?,
      economicImpactSource: json['economicImpactSource'] as String?,
      factoryInFrance: json['factoryInFrance'] as bool?,
      factoryInFranceSource: json['factoryInFranceSource'] as String?,
      factoryInEU: json['factoryInEU'] as bool?,
      factoryInEUSource: json['factoryInEUSource'] as String?,
      frenchFarmer: json['frenchFarmer'] as bool?,
      frenchFarmerSource: json['frenchFarmerSource'] as String?,
      euFarmer: json['euFarmer'] as bool?,
      euFarmerSource: json['euFarmerSource'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      isEnabled: json['isEnabled'] as bool?,
      isError: json['isError'] as bool?,
    );

Map<String, dynamic> _$$BrandLiteracyImplToJson(_$BrandLiteracyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentCompany': instance.parentCompany,
      'brandOrigin': instance.brandOrigin,
      'logoUrl': instance.logoUrl,
      'similarBrandsEu': const SimilarBrandsConverter().toJson(
        instance.similarBrandsEu,
      ),
      'productFamily': instance.productFamily,
      'totalEmployees': instance.totalEmployees,
      'totalEmployeesSource': instance.totalEmployeesSource,
      'employeesUS': instance.employeesUS,
      'employeesUSSource': instance.employeesUSSource,
      'economicImpact': instance.economicImpact,
      'economicImpactSource': instance.economicImpactSource,
      'factoryInFrance': instance.factoryInFrance,
      'factoryInFranceSource': instance.factoryInFranceSource,
      'factoryInEU': instance.factoryInEU,
      'factoryInEUSource': instance.factoryInEUSource,
      'frenchFarmer': instance.frenchFarmer,
      'frenchFarmerSource': instance.frenchFarmerSource,
      'euFarmer': instance.euFarmer,
      'euFarmerSource': instance.euFarmerSource,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isEnabled': instance.isEnabled,
      'isError': instance.isError,
    };
