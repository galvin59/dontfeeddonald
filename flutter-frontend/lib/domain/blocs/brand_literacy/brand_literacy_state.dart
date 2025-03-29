import 'package:dont_feed_donald/domain/entities/brand_literacy.dart';
import 'package:equatable/equatable.dart';

enum BrandLiteracyStatus { initial, loading, loaded, error }

class BrandLiteracyState extends Equatable {
  final BrandLiteracyStatus status;
  final BrandLiteracy? brandLiteracy;
  final String? errorMessage;

  const BrandLiteracyState({
    this.status = BrandLiteracyStatus.initial,
    this.brandLiteracy,
    this.errorMessage,
  });

  BrandLiteracyState copyWith({
    BrandLiteracyStatus? status,
    BrandLiteracy? brandLiteracy,
    String? errorMessage,
  }) {
    return BrandLiteracyState(
      status: status ?? this.status,
      brandLiteracy: brandLiteracy ?? this.brandLiteracy,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, brandLiteracy, errorMessage];
}
