import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/funding/funding_platforms_screen.dart';
import '../../screens/funding/transaction_history_screen.dart';
import '../../screens/funding/payment_methods_screen.dart';
import '../../screens/funding/add_payment_method_screen.dart';

class AppRouter {
  final router = GoRouter(
    initialLocation: SplashScreen.routeName,
    routes: [
      GoRoute(
        path: SplashScreen.routeName,
        pageBuilder: (context, state) => _buildPage(const SplashScreen(), state),
      ),
      GoRoute(
        path: SettingsScreen.routeName,
        pageBuilder: (context, state) => _buildPage(const SettingsScreen(), state),
      ),
      GoRoute(
        path: FundingScreen.routeName,
        pageBuilder: (context, state) => _buildPage(const FundingScreen(), state),
      ),
      GoRoute(
        path: FundingPlatformsScreen.routeName,
        pageBuilder: (context, state) => _buildPage(const FundingPlatformsScreen(), state),
      ),
      GoRoute(
        path: TransactionHistoryScreen.routeName,
        pageBuilder: (context, state) => _buildPage(const TransactionHistoryScreen(), state),
      ),
      GoRoute(
        path: PaymentMethodsScreen.routeName,
        pageBuilder: (context, state) => _buildPage(const PaymentMethodsScreen(), state),
      ),
      GoRoute(
        path: AddPaymentMethodScreen.routeName,
        pageBuilder: (context, state) => _buildPage(const AddPaymentMethodScreen(), state),
      ),
    ],
    errorPageBuilder: (context, state) => _buildPage(
      Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri.path}'),
        ),
      ),
      state,
    ),
  );

  static Page _buildPage(Widget child, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  // Navigation methods
  static void push(BuildContext context, String path, {Object? extra}) {
    GoRouter.of(context).push(path, extra: extra);
  }

  static void pushReplacement(BuildContext context, String path, {Object? extra}) {
    GoRouter.of(context).pushReplacement(path, extra: extra);
  }

  static void pop<T>(BuildContext context, [T? result]) {
    context.pop(result);
  }

  static void pushAndRemoveUntil(
    BuildContext context,
    String newPath,
    bool Function(GoRouterState) predicate, {
    Object? extra,
  }) {
    context.pushReplacement(newPath, extra: extra);
  }

  // Static route names
  static const String initialRoute = SplashScreen.routeName;

  // Helper method to get route name without the leading '/'
  static String getRouteName(String fullRoute) {
    return fullRoute.startsWith('/') ? fullRoute.substring(1) : fullRoute;
  }

  // Helper method to check if a route requires authentication
  static bool requiresAuth(String routeName) {
    final publicRoutes = [
      SplashScreen.routeName,
      // Add other public routes here
    ];
    return !publicRoutes.contains(routeName);
  }
}
