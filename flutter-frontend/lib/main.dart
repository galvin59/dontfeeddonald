import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:dont_feed_donald/core/providers/locale_provider.dart';
import 'package:dont_feed_donald/core/routes/app_router.dart';
import 'package:dont_feed_donald/core/theme/app_theme.dart';
import 'package:dont_feed_donald/core/services/secure_storage_service.dart';
import 'package:dont_feed_donald/data/repositories/brand_repository.dart';
import 'package:dont_feed_donald/domain/blocs/brand_search/brand_search_bloc.dart';
import 'package:dont_feed_donald/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerSingleton<SecureStorageService>(SecureStorageService());

  // Repositories
  getIt.registerLazySingleton<BrandRepository>(() => BrandRepository());
  
  // Providers
  getIt.registerSingleton<LocaleProvider>(LocaleProvider());

  // Initialize services
  final secureStorage = getIt<SecureStorageService>();
  
  // TEMPORARY: Force refresh of API key from .env file
  await secureStorage.deleteApiKey();
  await secureStorage.ensureApiKeyIsSet();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Make the app full screen by setting the status bar and navigation bar to be transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Ensure keyboard is dismissed when app starts
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  await setupDependencies();
  runApp(const DontFeedDonaldApp());
}

class DontFeedDonaldApp extends StatelessWidget {
  const DontFeedDonaldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(
          value: getIt<LocaleProvider>(),
        ),
        BlocProvider<BrandSearchBloc>(
          create: (context) =>
              BrandSearchBloc(brandRepository: getIt<BrandRepository>())
                ..initialize(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp.router(
            title: 'Don\'t feed Donald',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            locale: localeProvider.locale,
            supportedLocales: L10n.all,
            // Make the app truly full screen
            builder: (context, child) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                ),
                child: child!,
              );
            },
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
