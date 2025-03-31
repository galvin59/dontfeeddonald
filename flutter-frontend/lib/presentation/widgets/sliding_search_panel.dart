import "dart:async";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:dont_feed_donald/core/routes/app_router.dart";
import "package:dont_feed_donald/data/models/brand_search_result.dart";
import "package:dont_feed_donald/domain/blocs/brand_search/brand_search_bloc.dart";
import "package:dont_feed_donald/domain/blocs/brand_search/brand_search_event.dart";
import "package:dont_feed_donald/domain/blocs/brand_search/brand_search_state.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class SlidingSearchPanel extends StatefulWidget {
  const SlidingSearchPanel({super.key});

  @override
  SlidingSearchPanelState createState() => SlidingSearchPanelState();
}

class SlidingSearchPanelState extends State<SlidingSearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous debounce timer
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Debounce for 750ms to wait for user to stop typing
    _debounce = Timer(const Duration(milliseconds: 750), () {
      final query = _searchController.text.trim();

      // Only search if query has 3 or more characters
      if (query.length > 2) {
        context.read<BrandSearchBloc>().add(SearchBrands(query));
      } else if (query.isEmpty) {
        // Clear the search results if query is empty
        context.read<BrandSearchBloc>().add(ClearSearch());
      } else {
        // For queries with 1-2 characters, show a waiting state without making API requests
        context.read<BrandSearchBloc>().add(SearchBrands(""));
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<BrandSearchBloc>().add(ClearSearch());
  }

  // Public method to request focus for the search field
  void requestSearchFocus() {
    // Short delay to ensure the panel is visible
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _navigateToBrandDetails(BrandSearchResult searchResult) {
    context.push(
      "${AppRouter.brandDetails}/${searchResult.id}",
      extra: searchResult,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 225),
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.brandNameHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                textInputAction: TextInputAction.search,
              ),
            ),

            // Search results area
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: BlocBuilder<BrandSearchBloc, BrandSearchState>(
                  builder: (context, state) {
                    final l10n = AppLocalizations.of(context)!;
                    if (state.status == BrandSearchStatus.initial) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: Text(l10n.enterBrandNamePrompt)),
                    );
                    }

                    if (state.status == BrandSearchStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == BrandSearchStatus.failure) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? l10n.searchError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                    }

                    if (state.brands.isEmpty) {
                      return Center(child: Text(l10n.noBrandsFound));
                    }

                    return ListView.builder(
                      itemCount: state.brands.length,
                      padding: EdgeInsets.zero, // Remove default padding
                      physics: const AlwaysScrollableScrollPhysics(), // Make it always scrollable
                      shrinkWrap: true, // Fit to content
                      itemBuilder: (context, index) {
                        final searchResult = state.brands[index];
                        return BrandListItem(
                          searchResult: searchResult,
                          onTap: () => _navigateToBrandDetails(searchResult),
                        );
                      },
                  );
                },
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandListItem extends StatelessWidget {
  final BrandSearchResult searchResult;
  final VoidCallback onTap;

  const BrandListItem({
    super.key,
    required this.searchResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 48,
        height: 48,
        child:
            searchResult.logoUrl != null
                ? CachedNetworkImage(
                  imageUrl: searchResult.logoUrl!,
                  placeholder:
                      (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.contain,
                )
                : const Icon(Icons.image_not_supported),
      ),
      title: Text(searchResult.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
