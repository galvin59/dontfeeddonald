import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:dont_feed_donald/main.dart"; // Import main to access routeObserver
import "package:dont_feed_donald/core/routes/app_router.dart";
import "package:dont_feed_donald/core/theme/app_theme.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:google_fonts/google_fonts.dart";
import "package:dont_feed_donald/presentation/widgets/sliding_search_panel.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, RouteAware {
  // Reference to the sliding search panel state
  final GlobalKey<SlidingSearchPanelState> _searchPanelKey =
      GlobalKey<SlidingSearchPanelState>();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isPanelVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unsubscribe from the RouteObserver
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped and this route is shown again.
    // If the search panel was visible when we left, close it now.
    if (_isPanelVisible) {
      // Use WidgetsBinding to ensure setState is called after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _toggleSearchPanel();
        }
      });
    }
  }

  void _toggleSearchPanel() {
    setState(() {
      _isPanelVisible = !_isPanelVisible;
      if (_isPanelVisible) {
        _controller.forward().then((_) {
          // Request focus for the search field when panel is fully visible
          _searchPanelKey.currentState?.requestSearchFocus();
        });
      } else {
        // Hide keyboard when panel disappears
        FocusManager.instance.primaryFocus?.unfocus();
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI mode to edge-to-edge (full screen)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Get the localization instance and ensure it's non-null
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true, // Allows content to extend behind the bottom nav bar
      extendBodyBehindAppBar:
          true, // Allows content to extend behind the app bar

      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/home_background.png"),
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: Stack(
          children: [
            // Grey container for bottom status bar - positioned first so it's at the bottom of the stack
            Positioned(
              bottom: -20, // Position at bottom with some overlap
              left: 0,
              right: 0,
              height: 240, // Height to cover bottom status bar
              child: Container(color: Colors.grey.withAlpha(220)),
            ),

            // Bottom content with search button - positioned above the grey bottom panel
            SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  l10n.enterBrandNamePrompt,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _toggleSearchPanel,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.primaryColor,
                                    padding: const EdgeInsets.fromLTRB(
                                      32,
                                      4,
                                      32,
                                      8,
                                    ),
                                    textStyle: GoogleFonts.permanentMarker(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: Text(
                                    l10n.searchBrandTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sliding search panel - positioned here so it hides bottom content but stays below top elements
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  // Panel goes all the way to the top edge of screen
                  // When animation is 0, panel is below screen
                  // When animation is 1, panel is at top of screen
                  top:
                      MediaQuery.of(context).size.height *
                      (1 - _animation.value),
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlidingSearchPanel(key: _searchPanelKey),
                );
              },
            ),

            // Grey inclined container for top status bar - positioned last so it's on top of everything
            Positioned(
              top:
                  -50, // Move it up to ensure it covers the top edge including status bar
              left: -50, // Move it left to ensure it covers the left edge
              right: -50, // Extend beyond the right edge
              height: 240, // Fixed height for top container
              child: Transform.rotate(
                angle: -0.1,
                origin: const Offset(
                  0,
                  100,
                ), // Rotate around a point near the top
                child: Container(color: Colors.grey.withAlpha(220)),
              ),
            ),

            // Top content (title and settings) - positioned last so it's on top of everything
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 20,
                    child: Transform.rotate(
                      angle: -0.1, // Slight inclination
                      child: Column(
                        children: [
                          Text(
                            l10n.appTitle,
                            style: GoogleFonts.permanentMarker(
                              textStyle: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 3.0,
                                    color: Colors.black54,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width:
                                MediaQuery.of(context).size.width *
                                0.9, // Set width to 90% of screen width
                            child: Text(
                              l10n.appTagline,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height:
                                    1.2, // Add line height for better spacing
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        _isPanelVisible ? Icons.close : Icons.settings,
                        color: Colors.white,
                      ),
                      onPressed:
                          _isPanelVisible
                              ? _toggleSearchPanel
                              : () => context.go(AppRouter.settings),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
