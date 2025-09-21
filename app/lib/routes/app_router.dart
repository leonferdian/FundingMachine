import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../screens/splash_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/home/funding_screen.dart';
import '../../screens/home/add_funding_platform_screen.dart';
import '../../screens/home/platform_details_screen.dart' show PlatformDetailsScreen, FundingPlatform;
// Import other screens here

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return _buildRoute(settings, const SplashScreen());
      case SettingsScreen.routeName:
        return _buildRoute(settings, const SettingsScreen());
      case FundingScreen.routeName:
        return _buildRoute(settings, const FundingScreen());
      case AddFundingPlatformScreen.routeName:
        return _buildRoute(settings, const AddFundingPlatformScreen());
      case PlatformDetailsScreen.routeName:
        if (settings.arguments is! FundingPlatform) {
          throw ArgumentError('PlatformDetailsScreen requires a FundingPlatform argument');
        }
        final platform = settings.arguments as FundingPlatform;
        return _buildRoute(settings, PlatformDetailsScreen(platform: platform));
      // Add more routes here
      default:
        return _buildRoute(
          settings,
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return CupertinoPageRoute(
      settings: settings,
      builder: (BuildContext context) => builder,
    );
  }

  // Static route names
  static const String initialRoute = SplashScreen.routeName;

  // Route names
  static const String splash = SplashScreen.routeName;
  static const String settings = SettingsScreen.routeName;
  static const String funding = FundingScreen.routeName;
  static const String addFundingPlatform = AddFundingPlatformScreen.routeName;
  static const String platformDetails = PlatformDetailsScreen.routeName;
  // Add more route names here

  // Helper method to get route name without the leading '/'
  static String getRouteName(String fullRoute) {
    return fullRoute.startsWith('/') ? fullRoute.substring(1) : fullRoute;
  }

  // Helper method to check if a route requires authentication
  static bool requiresAuth(String routeName) {
    final publicRoutes = [
      splash,
      // Add other public routes here
    ];
    return !publicRoutes.contains(routeName);
  }
}
