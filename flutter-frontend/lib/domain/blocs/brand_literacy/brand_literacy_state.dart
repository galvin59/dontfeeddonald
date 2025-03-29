import 'package:dont_feed_donald/domain/entities/brand_literacy.dart';
import 'package:equatable/equatable.dart';

enum BrandLiteracyStatus { initial, loading, loaded, error }

class BrandLiteracyState extends Equatable {
  final BrandLiteracyStatus status;
  final BrandLiteracy? brandLiteracy;
  final int? brandScore;
  final String? errorMessage;

  const BrandLiteracyState({
    this.status = BrandLiteracyStatus.initial,
    this.brandLiteracy,
    this.brandScore,
    this.errorMessage,
  });

  BrandLiteracyState copyWith({
    BrandLiteracyStatus? status,
    BrandLiteracy? brandLiteracy,
    int? brandScore,
    String? errorMessage,
  }) {
    return BrandLiteracyState(
      status: status ?? this.status,
      brandLiteracy: brandLiteracy ?? this.brandLiteracy,
      brandScore: brandScore ?? this.brandScore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, brandLiteracy, brandScore, errorMessage];
}
