import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:dont_feed_donald/data/models/brand_search_result.dart";
import "package:dont_feed_donald/data/repositories/brand_repository.dart";
import "package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_bloc.dart";
import "package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_event.dart";
import "package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_state.dart";
import "package:dont_feed_donald/domain/entities/brand_literacy.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:google_fonts/google_fonts.dart";
import "package:go_router/go_router.dart";
import "package:dont_feed_donald/core/routes/app_router.dart";

class BrandDetailsPage extends StatefulWidget {
  final BrandSearchResult searchResult;

  const BrandDetailsPage({super.key, required this.searchResult});

  @override
  State<BrandDetailsPage> createState() => _BrandDetailsPageState();
}

class _BrandDetailsPageState extends State<BrandDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _scoreAnimation;
  int _displayScore = 0;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animationController.addListener(() {
      setState(() {
        _displayScore = _scoreAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAndStartAnimation(int finalScore) {
    // Create a sequence animation: 0 -> 10 -> 5 -> finalScore
    final tween = TweenSequence<int>([
      // First animate to 10 (33% of total animation time)
      TweenSequenceItem<int>(tween: IntTween(begin: 0, end: 10), weight: 33),
      // Then animate to 5 (33% of total animation time)
      TweenSequenceItem<int>(tween: IntTween(begin: 10, end: 5), weight: 33),
      // Finally animate to the actual score (34% of total animation time)
      TweenSequenceItem<int>(
        tween: IntTween(begin: 5, end: finalScore),
        weight: 34,
      ),
    ]);

    _scoreAnimation = tween.animate(_animationController);
    _animationController.forward(from: 0.0);
    _animationStarted = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              BrandLiteracyBloc(brandRepository: BrandRepository())
                ..add(FetchBrandLiteracy(brandId: widget.searchResult.id)),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRouter.home),
          ),
          title: Text(widget.searchResult.name),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<BrandLiteracyBloc, BrandLiteracyState>(
            builder: (context, state) {
              switch (state.status) {
                case BrandLiteracyStatus.initial:
                case BrandLiteracyStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case BrandLiteracyStatus.loaded:
                  // Extract data safely from the loaded state
                  final BrandLiteracy? brandLiteracy = state.brandLiteracy;
                  final int? finalScore = state.brandScore;

                  // Only proceed if data is valid
                  if (brandLiteracy != null && finalScore != null) {
                    // Calculate final score note using the non-null finalScore
                    final l10n = AppLocalizations.of(context)!;
                    final scoreNoteKey = _getScoreNoteKey(finalScore);
                    final finalScoreNote = _getLocalizedString(
                      l10n,
                      scoreNoteKey,
                    );

                    // Start animation if not already started, using non-null finalScore
                    if (!_animationStarted) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        _setupAndStartAnimation(finalScore);
                      });
                    }

                    // Build the UI with the final note and animated gauge
                    return _buildBrandLiteracyDetails(
                      context,
                      brandLiteracy, // Pass non-nullable brandLiteracy
                      _animationStarted
                          ? _displayScore
                          : finalScore, // Animated score for gauge
                      finalScoreNote, // Final note for text
                    );
                  } else {
                    // Handle case where loaded state might have null data (fallback)
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)?.errorLoadingData ??
                            "Error loading data",
                      ),
                    );
                  }
                case BrandLiteracyStatus.error:
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.errorMessage}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<BrandLiteracyBloc>().add(
                              FetchBrandLiteracy(
                                brandId: widget.searchResult.id,
                              ),
                            );
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLiteracyDetails(
    BuildContext context,
    BrandLiteracy
    brandLiteracy, // Should be non-null when called from loaded state
    int animatedScore, // Score for gauge animation
    String finalScoreNote, // Pre-calculated note based on final score
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(
          flex: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      // Use null check for safety, though it should be non-null here
                      imageUrl: brandLiteracy.logoUrl ?? "",
                      width: 40,
                      height: 40,
                      placeholder:
                          (context, url) => const SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) =>
                              Container(), // Empty container on error
                    ),
                    const SizedBox(width: 16),
                    Text(
                      brandLiteracy
                          .name, // Removed '??' as brandLiteracy is guaranteed non-null here
                      style: GoogleFonts.permanentMarker(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow:
                          TextOverflow.ellipsis, // Handle potential overflow
                      maxLines: 1, // Allow up to 2 lines for the name
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(),
              Expanded(
                child: Center(child: _buildGauge(context, animatedScore)),
              ), // Use animated score for gauge
            ],
          ),
        ),
        Divider(),
        Expanded(
          flex: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.ourOpinion),
                const SizedBox(height: 4),
                Text(
                  finalScoreNote, // Use the passed final score note
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGauge(BuildContext context, int score) {
    final filledGraduations = (score * 2).clamp(0, 20);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 12),
              ...List.generate(20, (index) {
                final isActive = index < filledGraduations;
                final graduationColor =
                    isActive ? Colors.green : Colors.red.shade700;

                return Expanded(
                  child: Center(
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: graduationColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              }).reversed.toList(),
              SizedBox(height: 12),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Colors.white,
            child: Image.asset("assets/images/duck_garbage_no_bg.png"),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Colors.white,
            child: Image.asset("assets/images/duck_transat_no_bg.png"),
          ),
        ),
      ],
    );
  }

  String _getLocalizedString(AppLocalizations l10n, String? key) {
    if (key == null) return "";
    switch (key) {
      case "note12":
        return l10n.note12;
      case "note34":
        return l10n.note34;
      case "note56":
        return l10n.note56;
      case "note78":
        return l10n.note78;
      case "note910":
        return l10n.note910;
      case "errorLoadingData":
        return l10n.errorLoadingData;
      default:
        return "";
    }
  }

  String? _getScoreNoteKey(int score) {
    if (score >= 1 && score <= 2) {
      return "note12";
    } else if (score >= 3 && score <= 4) {
      return "note34";
    } else if (score >= 5 && score <= 6) {
      return "note56";
    } else if (score >= 7 && score <= 8) {
      return "note78";
    } else if (score >= 9 && score <= 10) {
      return "note910";
    } else {
      return null;
    }
  }
}
