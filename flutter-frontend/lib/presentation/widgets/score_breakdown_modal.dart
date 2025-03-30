import "package:country_flags/country_flags.dart";
import "package:dont_feed_donald/domain/entities/brand_literacy.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart"; // Import localization

/// A modal popup displaying the breakdown of the brand literacy score components.
class ScoreBreakdownModal extends StatelessWidget {
  final BrandLiteracy brandLiteracy;

  const ScoreBreakdownModal({super.key, required this.brandLiteracy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get localizations

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      backgroundColor: Colors.white.withOpacity(0.9), // Semi-transparent white
      title: Text(
        l10n.scoreBreakdownTitle, // Use localized title
        style: GoogleFonts.oswald(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContent(context, brandLiteracy), // Extracted content build logic
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              l10n.aiDisclaimer, // Use localized disclaimer
              style: GoogleFonts.lato(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            l10n.closeButtonLabel, // Use localized button text
            style: GoogleFonts.oswald(color: Colors.blueAccent, fontSize: 16),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  // Helper widget to build the main content section
  Widget _buildContent(BuildContext context, BrandLiteracy brandLiteracy) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandOriginRow(context, brandLiteracy.brandOrigin), // Pass context
        const SizedBox(height: 10),
        _buildInfoRow(context, l10n.usEmployeesLabel, brandLiteracy.usEmployees), // Pass context
        const SizedBox(height: 5),
        _buildInfoRow(context, l10n.euEmployeesLabel, brandLiteracy.euEmployees), // Pass context
        const Divider(height: 25, thickness: 1, color: Colors.black12),
        _buildInfoRow(context, l10n.usFactoryLabel, brandLiteracy.usFactory), // Pass context
        const SizedBox(height: 5),
        _buildInfoRow(context, l10n.euFactoryLabel, brandLiteracy.euFactory), // Pass context
        const Divider(height: 25, thickness: 1, color: Colors.black12),
        _buildInfoRow(context, l10n.usSupplierLabel, brandLiteracy.usSupplier), // Pass context
        const SizedBox(height: 5),
        _buildInfoRow(context, l10n.euSupplierLabel, brandLiteracy.euSupplier), // Pass context
      ],
    );
  }

  // Refactor _buildBrandOriginRow to accept context
  Widget _buildBrandOriginRow(BuildContext context, String? countryCode) {
    final l10n = AppLocalizations.of(context)!;
    Widget flagWidget;
    String countryText = "Unknown"; // Default/fallback text

    if (countryCode != null && countryCode.isNotEmpty && countryCode.length == 2) {
      final code = countryCode.toUpperCase();
      // Assuming countryCode is a 2-letter ISO code
      try {
        flagWidget = CountryFlag.fromCountryCode(
          code,
          height: 20,
          width: 30,
          borderRadius: 4,
        );
        countryText = code; // Display the code if flag is found
      } catch (e) {
        // Handle cases where the code might be invalid or flag not found
        flagWidget = const Icon(Icons.question_mark, size: 20, color: Colors.orangeAccent);
        countryText = l10n.unknownCountryCode(code); // Use localized unknown text
      }

    } else {
      flagWidget = const Icon(Icons.question_mark, size: 20, color: Colors.orangeAccent);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
        children: [
          Expanded( // Allow label to take available space
            child: Text(
              l10n.brandOriginLabel, // Use localized label
              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
              softWrap: true, // Allow wrapping
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 10), // Add space before flag/text
              flagWidget,
              const SizedBox(width: 8),
              Text(
                countryText,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Refactor _buildInfoRow to accept context
  Widget _buildInfoRow(BuildContext context, String label, bool? value) {
    // No need for l10n here as label is passed already localized
    Icon valueIcon;
    if (value == true) {
      valueIcon = const Icon(Icons.check_circle, color: Colors.green, size: 24);
    } else if (value == false) {
      valueIcon = const Icon(Icons.cancel, color: Colors.red, size: 24);
    } else {
      valueIcon = const Icon(Icons.question_mark, color: Colors.orangeAccent, size: 24);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Increased vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
        children: [
          Expanded( // Allow label to take available space
            child: Text(
              label, // Use the passed localized label
              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
              softWrap: true, // Allow wrapping
            ),
          ),
          const SizedBox(width: 10), // Add space before icon
          valueIcon,
        ],
      ),
    );
  }
}
