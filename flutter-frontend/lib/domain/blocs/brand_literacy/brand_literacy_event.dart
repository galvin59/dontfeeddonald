import 'package:equatable/equatable.dart';

abstract class BrandLiteracyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchBrandLiteracy extends BrandLiteracyEvent {
  final String brandId;

  FetchBrandLiteracy({required this.brandId});

  @override
  List<Object?> get props => [brandId];
}

class ClearBrandLiteracy extends BrandLiteracyEvent {}
