import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:dont_feed_donald/main.dart"; 
import "package:dont_feed_donald/data/models/brand_search_result.dart";
import "package:dont_feed_donald/presentation/pages/home_page.dart";
import "package:dont_feed_donald/presentation/pages/brand_details_page.dart";
import "package:dont_feed_donald/presentation/pages/settings_page.dart";

class AppRouter {
  static const String home = '/';
  static const String brandDetails = '/brand-details';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    observers: [routeObserver], 
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '$brandDetails/:id',
        builder: (context, state) {
          final searchResult = state.extra as BrandSearchResult;
          
          return BrandDetailsPage(searchResult: searchResult);
        },
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
