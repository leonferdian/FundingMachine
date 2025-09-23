// Core Flutter and Dart imports
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_theme.dart';
import 'constants/strings.dart';
import 'providers.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'services/analytics_service.dart';
import 'services/auth_service.dart';
import 'services/localization_service.dart';
import 'services/navigation_service.dart';

// Initialize navigation service
final navigationService = NavigationService();

// Global navigator key for navigation without BuildContext
final GlobalKey<NavigatorState> navigatorKey = navigationService.navigatorKey;

/// Custom error handler for Flutter framework errors
void _handleFlutterError(FlutterErrorDetails details) {
  // In production, report to your error tracking service
  if (kReleaseMode) {
    AnalyticsService.recordError(details.exception, details.stack);
  } else {
    // In debug mode, print to console and show error UI
    FlutterError.dumpErrorToConsole(details);
  }
}

/// Handle uncaught errors
void _handleUncaughtError(Object error, StackTrace stack) {
  if (kReleaseMode) {
    AnalyticsService.recordError(error, stack);
  } else {
    debugPrint('Uncaught error: $error\n$stack');
  }
}

/// Show error UI when app initialization fails
void _showErrorUI(Object error, StackTrace stack) {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  'Oops! Something went wrong',
                  style: Theme.of(navigatorKey.currentContext ?? Navigator.of(navigatorKey.currentContext!).context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We encountered an error while starting the app. Please try again later.',
                  textAlign: TextAlign.center,
                  style: Theme.of(navigatorKey.currentContext ?? Navigator.of(navigatorKey.currentContext!).context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Error details: ${error.toString()}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Initialize error handling
void _initErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = _handleFlutterError;
  
  // Handle uncaught Dart errors
  PlatformDispatcher.instance.onError = (error, stack) {
    _handleUncaughtError(error, stack);
    return true; // Prevents default error handling
  };
}

void main() async {
  // Initialize error handling before anything else
  _initErrorHandling();
  
  // Run the app with error boundaries
  runZonedGuarded<Future<void>>(
    () async {
      await _initializeApp();
    },
    (error, stackTrace) => _handleUncaughtError(error, stackTrace),
  );
}

/// Initialize app services and configurations
Future<void> _initializeApp() async {
  try {
    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize services
    final prefs = await SharedPreferences.getInstance();
    await AnalyticsService.initialize();
    await LocalizationService.initialize();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    
    // Initialize shared preferences
    final sharedPreferences = await SharedPreferences.getInstance();
  
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: provider.MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
            provider.Provider(create: (_) => AuthService(prefs)),
            provider.ChangeNotifierProvider(
              create: (context) => AuthProvider(
                context.read<AuthService>(),
              ),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );
  } catch (e, stack) {
    // Handle any initialization errors
    _showErrorUI(e, stack);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LocalizationService().dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    switch (state) {
      case AppLifecycleState.resumed:
        AnalyticsService.logEvent('app_resumed');
        break;
      case AppLifecycleState.paused:
        AnalyticsService.logEvent('app_paused');
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _initApp() async {
    // Initialize any async operations here
    await AnalyticsService.setUserProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeProvider);
        
        return MaterialApp.router(
          routerConfig: AppRouter().router,
          title: Strings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: LocalizationService.currentLocale,
          supportedLocales: LocalizationService.supportedLocales,
          localizationsDelegates: const [
            // AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            // Ensure consistent text scaling
            final mediaQuery = MediaQuery.of(context);
            
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: MediaQuery.textScalerOf(context).clamp(
                  minScaleFactor: 0.8, 
                  maxScaleFactor: 1.5,
                ),
                boldText: false,
                highContrast: false,
              ),
              child: Listener(
                onPointerDown: (_) {
                  // Dismiss keyboard when tapping outside of text fields
                  final currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                    currentFocus.focusedChild?.unfocus();
                  }
                },
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(
                    physics: const BouncingScrollPhysics(),
                    overscroll: false,
                  ),
                  child: child!,
                ),
              ),
            );
          },
          // Debug settings
          debugShowMaterialGrid: false,
          showPerformanceOverlay: false,
          checkerboardRasterCacheImages: false,
          checkerboardOffscreenLayers: false,
        );
      },
    );
  }
}
