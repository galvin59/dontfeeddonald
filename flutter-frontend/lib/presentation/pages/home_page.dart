import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:dont_feed_donald/core/routes/app_router.dart";
import "package:dont_feed_donald/core/theme/app_theme.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:google_fonts/google_fonts.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI mode to edge-to-edge (full screen)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final l10n = AppLocalizations.of(context);

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
            // Grey inclined container for top status bar
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

            // Grey container for bottom status bar
            Positioned(
              bottom: -20, // Position at bottom with some overlap
              left: 0,
              right: 0,
              height: 240, // Height to cover bottom status bar
              child: Container(color: Colors.grey.withAlpha(220)),
            ),
            // SafeArea for the rest of the content
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
                            l10n?.appTitle ?? "Don't Feed Donald",
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
                          Text(
                            "Donald se prend pour le roi de la basse-cour,\nmais surtout, il mange trop.\nAidez-nous à le mettre au régime !",
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => context.go(AppRouter.settings),
                    ),
                  ),
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
                                  "Dites-nous quelle marque vous comptez acheter, et on vous dira si c'est bon pour Donald ou si cela va contrinber à l'engraisser",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed:
                                      () => context.push(AppRouter.search),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 8,
                                    ),
                                    textStyle: GoogleFonts.permanentMarker(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: Text(
                                    l10n?.searchHint ??
                                        "Search for a brand ...",
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
          ],
        ),
      ),
    );
  }
}
