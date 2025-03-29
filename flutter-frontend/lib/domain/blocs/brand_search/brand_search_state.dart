import 'package:equatable/equatable.dart';
import 'package:dont_feed_donald/data/models/brand_search_result.dart';

enum BrandSearchStatus { initial, loading, success, failure }

class BrandSearchState extends Equatable {
  final BrandSearchStatus status;
  final List<BrandSearchResult> brands;
  final String searchQuery;
  final String? errorMessage;

  const BrandSearchState({
    this.status = BrandSearchStatus.initial,
    this.brands = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  BrandSearchState copyWith({
    BrandSearchStatus? status,
    List<BrandSearchResult>? brands,
    String? searchQuery,
    String? errorMessage,
  }) {
    return BrandSearchState(
      status: status ?? this.status,
      brands: brands ?? this.brands,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, brands, searchQuery, errorMessage];
}
