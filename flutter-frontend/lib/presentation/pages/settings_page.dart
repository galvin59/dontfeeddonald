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
      backgroundColor: Colors.transparent,
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/home_background.png"),
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: ListView(
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
              items: L10n.all.map<DropdownMenuItem<Locale>>((Locale locale) {
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(_getLanguageName(locale.languageCode)),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2025 Don't Feed Donald",
              );
            },
          ),
        ],
      ),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      default:
        return languageCode;
    }
  }
}
