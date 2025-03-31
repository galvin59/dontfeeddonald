import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dont_feed_donald/core/providers/locale_provider.dart';
import 'package:dont_feed_donald/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:dont_feed_donald/core/routes/app_router.dart';
import 'package:dont_feed_donald/core/theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI mode to edge-to-edge (full screen)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: DropdownButton<Locale>(
              value: localeProvider.locale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  localeProvider.setLocale(newLocale);
                }
              },
              items:
                  L10n.all
                      .where(
                        (locale) => locale.languageCode != 'es',
                      ) // Filter out Spanish
                      .map<DropdownMenuItem<Locale>>((Locale locale) {
                        // Use localized language names directly
                        String languageName = locale.languageCode == 'en' ? l10n.languageEnglish : l10n.languageFrench;
                        return DropdownMenuItem<Locale>(
                          value: locale,
                          child: Text(languageName),
                        );
                      })
                      .toList(),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
