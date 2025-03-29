import 'package:equatable/equatable.dart';

abstract class BrandSearchEvent extends Equatable {
  const BrandSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchBrands extends BrandSearchEvent {
  final String query;

  const SearchBrands(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends BrandSearchEvent {}
