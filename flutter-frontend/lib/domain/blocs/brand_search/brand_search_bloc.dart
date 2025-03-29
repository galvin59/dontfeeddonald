import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dont_feed_donald/data/repositories/brand_repository.dart';
import 'package:dont_feed_donald/domain/blocs/brand_search/brand_search_event.dart';
import 'package:dont_feed_donald/domain/blocs/brand_search/brand_search_state.dart';

class BrandSearchBloc extends Bloc<BrandSearchEvent, BrandSearchState> {
  final BrandRepository _brandRepository;
  
  BrandSearchBloc({BrandRepository? brandRepository}) 
      : _brandRepository = brandRepository ?? BrandRepository(),
        super(const BrandSearchState()) {
    on<SearchBrands>(_onSearchBrands);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchBrands(
    SearchBrands event,
    Emitter<BrandSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        status: BrandSearchStatus.initial,
        brands: [],
        searchQuery: '',
      ));
      return;
    }

    emit(state.copyWith(
      status: BrandSearchStatus.loading,
      searchQuery: event.query,
    ));

    try {
      // Get brands from the repository
      final searchResults = await _brandRepository.searchBrands(event.query);
      
      // Use search results directly
      emit(state.copyWith(
        status: BrandSearchStatus.success,
        brands: searchResults,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BrandSearchStatus.failure,
        errorMessage: 'Failed to search brands: ${e.toString()}',
      ));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<BrandSearchState> emit,
  ) {
    emit(const BrandSearchState());
  }
  
  /// Initialize the repository when the bloc is created
  Future<void> initialize() async {
    await _brandRepository.initialize();
  }
}
