import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:dont_feed_donald/data/models/brand_search_result.dart";
import "package:dont_feed_donald/data/repositories/brand_repository.dart";
import "package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_bloc.dart";
import "package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_event.dart";
import "package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_state.dart";
import "package:dont_feed_donald/domain/entities/brand_literacy.dart";

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
        appBar: AppBar(title: Text(widget.searchResult.name)),
        backgroundColor: Colors.white,
        body: BlocBuilder<BrandLiteracyBloc, BrandLiteracyState>(
          builder: (context, state) {
            switch (state.status) {
              case BrandLiteracyStatus.initial:
              case BrandLiteracyStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case BrandLiteracyStatus.loaded:
                if (state.brandScore != null && !_animationStarted) {
                  // Use SchedulerBinding to start animation after the build is complete
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _setupAndStartAnimation(state.brandScore!);
                  });
                }
                return _buildBrandLiteracyDetails(
                  context,
                  state.brandLiteracy!,
                  _animationStarted ? _displayScore : state.brandScore!,
                );
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
                            FetchBrandLiteracy(brandId: widget.searchResult.id),
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
    );
  }

  Widget _buildBrandLiteracyDetails(
    BuildContext context,
    BrandLiteracy brandLiteracy,
    int brandScore,
  ) {
    return Column(
      children: [
        // Top 2/3 of the screen with the gauge
        Expanded(
          flex: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                brandLiteracy.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Gauge with graduations
              Expanded(child: Center(child: _buildGauge(context, brandScore))),
            ],
          ),
        ),

        // Bottom 1/3 of the screen (white space for now)
        Expanded(flex: 10, child: Container(color: Colors.white)),
      ],
    );
  }

  Widget _buildGauge(BuildContext context, int score) {
    // Calculate how many graduations should be filled based on score
    // Score is 0-10, we have 20 graduations, so each point is 2 graduations
    final filledGraduations = (score * 2).clamp(0, 20);

    // Gauge
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 35),
              ...List.generate(20, (index) {
                // Index 0 is the bottom graduation, 19 is the top
                final isActive = index < filledGraduations;
                // Use green for active bars (higher score is better) and red for inactive
                final graduationColor =
                    isActive ? Colors.green : Colors.red.shade700;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: graduationColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).reversed.toList(),
              SizedBox(height: 35),
            ], // Reverse to have 0 at bottom, 19 at top
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
}
