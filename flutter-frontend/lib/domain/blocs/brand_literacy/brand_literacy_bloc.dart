import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dont_feed_donald/data/repositories/brand_repository.dart';
import 'package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_event.dart';
import 'package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_state.dart';
import 'package:dont_feed_donald/domain/entities/brand_literacy.dart';

class BrandLiteracyBloc extends Bloc<BrandLiteracyEvent, BrandLiteracyState> {
  final BrandRepository _brandRepository;

  BrandLiteracyBloc({required BrandRepository brandRepository})
      : _brandRepository = brandRepository,
        super(const BrandLiteracyState()) {
    on<FetchBrandLiteracy>(_onFetchBrandLiteracy);
    on<ClearBrandLiteracy>(_onClearBrandLiteracy);
  }

  Future<void> _onFetchBrandLiteracy(
    FetchBrandLiteracy event,
    Emitter<BrandLiteracyState> emit,
  ) async {
    emit(state.copyWith(status: BrandLiteracyStatus.loading));
    
    try {
      developer.log('Fetching brand literacy details for ID: ${event.brandId}');
      final response = await _brandRepository.getBrandLiteracy(event.brandId);
      
      // Extract the brandLiteracy and score from the response
      final brandLiteracy = response['brandLiteracy'] as BrandLiteracy;
      final brandScore = response['score'] as int?;
      
      developer.log('Received brand literacy with score: $brandScore');
      
      emit(state.copyWith(
        status: BrandLiteracyStatus.loaded,
        brandLiteracy: brandLiteracy,
        brandScore: brandScore,
      ));
    } catch (e) {
      developer.log('Error fetching brand literacy: $e');
      emit(state.copyWith(
        status: BrandLiteracyStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearBrandLiteracy(
    ClearBrandLiteracy event,
    Emitter<BrandLiteracyState> emit,
  ) {
    emit(const BrandLiteracyState());
  }
}
