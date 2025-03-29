import "dart:async";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:dont_feed_donald/core/routes/app_router.dart";
import "package:dont_feed_donald/data/models/brand_search_result.dart";
import "package:dont_feed_donald/domain/blocs/brand_search/brand_search_bloc.dart";
import "package:dont_feed_donald/domain/blocs/brand_search/brand_search_event.dart";
import "package:dont_feed_donald/domain/blocs/brand_search/brand_search_state.dart";
import "package:cached_network_image/cached_network_image.dart";

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the BrandSearchBloc provided in main.dart
    return const _SearchPageContent();
  }
}

class _SearchPageContent extends StatefulWidget {
  const _SearchPageContent();

  @override
  State<_SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<_SearchPageContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Set focus to search field when the page is loaded, but don't show keyboard immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // First hide any active keyboard from previous screens
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      // Delay focus request slightly to allow the page to settle
      Future.delayed(const Duration(milliseconds: 300), () {
        // Only request focus if this widget is still mounted
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    });
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

    // Debounce for 500ms to wait for user to stop typing
    _debounce = Timer(const Duration(milliseconds: 500), () {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Rechercher une marque"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true, // Automatically focus on this field
              decoration: InputDecoration(
                hintText: "Nom de marque...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                        : null,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: BlocBuilder<BrandSearchBloc, BrandSearchState>(
              builder: (context, state) {
                if (state.status == BrandSearchStatus.initial) {
                  return const Center(
                    child: Text("Entrez le nom d'une marque pour commencer"),
                  );
                }

                if (state.status == BrandSearchStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == BrandSearchStatus.failure) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? "Une erreur est survenue",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }

                if (state.brands.isEmpty) {
                  return const Center(child: Text("Aucune marque trouvée"));
                }

                return ListView.builder(
                  itemCount: state.brands.length,
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
        ],
      ),
    );
  }

  void _navigateToBrandDetails(BrandSearchResult searchResult) {
    context.push(
      "${AppRouter.brandDetails}/${searchResult.id}",
      extra: searchResult,
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
        child: searchResult.logoUrl != null
          ? CachedNetworkImage(
              imageUrl: searchResult.logoUrl!,
              placeholder: (context, url) => const CircularProgressIndicator(),
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
