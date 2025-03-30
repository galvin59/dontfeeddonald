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
      productFamily: json['productFamily'] as String?,
      usEmployees: json['usEmployees'] as bool?,
      usEmployeesSource: json['usEmployeesSource'] as String?,
      euEmployees: json['euEmployees'] as bool?,
      euEmployeesSource: json['euEmployeesSource'] as String?,
      usFactory: json['usFactory'] as bool?,
      usFactorySource: json['usFactorySource'] as String?,
      euFactory: json['euFactory'] as bool?,
      euFactorySource: json['euFactorySource'] as String?,
      usSupplier: json['usSupplier'] as bool?,
      usSupplierSource: json['usSupplierSource'] as String?,
      euSupplier: json['euSupplier'] as bool?,
      euSupplierSource: json['euSupplierSource'] as String?,
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
      score: (json['score'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$BrandLiteracyImplToJson(_$BrandLiteracyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentCompany': instance.parentCompany,
      'brandOrigin': instance.brandOrigin,
      'logoUrl': instance.logoUrl,
      'productFamily': instance.productFamily,
      'usEmployees': instance.usEmployees,
      'usEmployeesSource': instance.usEmployeesSource,
      'euEmployees': instance.euEmployees,
      'euEmployeesSource': instance.euEmployeesSource,
      'usFactory': instance.usFactory,
      'usFactorySource': instance.usFactorySource,
      'euFactory': instance.euFactory,
      'euFactorySource': instance.euFactorySource,
      'usSupplier': instance.usSupplier,
      'usSupplierSource': instance.usSupplierSource,
      'euSupplier': instance.euSupplier,
      'euSupplierSource': instance.euSupplierSource,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isEnabled': instance.isEnabled,
      'isError': instance.isError,
      'score': instance.score,
    };
