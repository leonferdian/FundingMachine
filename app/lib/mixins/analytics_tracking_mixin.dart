import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

/// Mixin for automatic user behavior tracking in widgets
mixin AnalyticsTrackingMixin<T extends StatefulWidget> on State<T> {
  final AnalyticsService _analyticsService = AnalyticsService.instance;
  String? _currentScreenName;
  DateTime? _screenStartTime;
  bool _hasTrackedScreenView = false;

  @override
  void initState() {
    super.initState();
    _currentScreenName = _getScreenName();
    _screenStartTime = DateTime.now();

    // Track screen view after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackScreenView();
    });
  }

  @override
  void dispose() {
    _trackScreenTime();
    super.dispose();
  }

  /// Get the screen name for analytics tracking
  String _getScreenName() {
    // Get screen name from widget class name or override in subclasses
    final className = T.toString();
    return className.replaceFirst('_', '').replaceAll('Screen', '').replaceAll('Page', '');
  }

  /// Track screen view
  Future<void> _trackScreenView() async {
    if (_hasTrackedScreenView || _currentScreenName == null) return;

    try {
      await _analyticsService.trackScreenView(
        screenName: _currentScreenName!,
        parameters: await _getScreenParameters(),
      );
      _hasTrackedScreenView = true;
    } catch (e) {
      debugPrint('Error tracking screen view: $e');
    }
  }

  /// Track screen time when leaving
  Future<void> _trackScreenTime() async {
    if (_screenStartTime != null && _currentScreenName != null) {
      final duration = DateTime.now().difference(_screenStartTime!);
      final timeSpent = duration.inSeconds;

      try {
        await _analyticsService.trackCustomEvent(
          eventName: 'screen_time',
          properties: {
            'screen': _currentScreenName,
            'timeSpent': timeSpent,
            'duration': duration.inMilliseconds,
          },
        );
      } catch (e) {
        debugPrint('Error tracking screen time: $e');
      }
    }
  }

  /// Get screen parameters for additional context
  Future<Map<String, dynamic>> _getScreenParameters() async {
    return {};
  }

  /// Track user action
  Future<void> trackAction(String action, {Map<String, dynamic>? parameters}) async {
    try {
      await _analyticsService.trackAction(
        action: action,
        screenName: _currentScreenName ?? '',
        actionDetails: parameters ?? {},
      );
    } catch (e) {
      debugPrint('Error tracking action: $e');
    }
  }

  /// Track button tap
  Future<void> trackButtonTap(String buttonName, {Map<String, dynamic>? parameters}) async {
    await trackAction('button_tap', parameters: {
      'button': buttonName,
      ...parameters ?? {},
    });
  }

  /// Track navigation
  Future<void> trackNavigation(String destination, {Map<String, dynamic>? parameters}) async {
    await trackAction('navigation', parameters: {
      'destination': destination,
      ...parameters ?? {},
    });
  }

  /// Track search
  Future<void> trackSearch(String query, {Map<String, dynamic>? parameters}) async {
    await trackAction('search', parameters: {
      'query': query,
      ...parameters ?? {},
    });
  }

  /// Track filter usage
  Future<void> trackFilter(String filterType, {Map<String, dynamic>? parameters}) async {
    await trackAction('filter', parameters: {
      'filterType': filterType,
      ...parameters ?? {},
    });
  }

  /// Track form submission
  Future<void> trackFormSubmission(String formName, {Map<String, dynamic>? parameters}) async {
    await trackAction('form_submit', parameters: {
      'form': formName,
      ...parameters ?? {},
    });
  }

  /// Track error
  Future<void> trackError(String errorMessage, {Map<String, dynamic>? context}) async {
    try {
      await _analyticsService.trackError(
        errorMessage: errorMessage,
        screenName: _currentScreenName ?? '',
        context: context ?? {},
      );
    } catch (e) {
      debugPrint('Error tracking error: $e');
    }
  }

  /// Track performance metric
  Future<void> trackPerformance(String metricName, int value, {String unit = 'ms'}) async {
    try {
      await _analyticsService.trackPerformance(
        metricName: metricName,
        value: value,
        unit: unit,
      );
    } catch (e) {
      debugPrint('Error tracking performance: $e');
    }
  }

  /// Track conversion event
  Future<void> trackConversion(String conversionType, {Map<String, dynamic>? parameters}) async {
    await trackAction('conversion', parameters: {
      'conversionType': conversionType,
      ...parameters ?? {},
    });
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(String feature, {Map<String, dynamic>? parameters}) async {
    await trackAction('feature_usage', parameters: {
      'feature': feature,
      ...parameters ?? {},
    });
  }

  /// Track user engagement
  Future<void> trackEngagement(String engagementType, {Map<String, dynamic>? parameters}) async {
    await trackAction('engagement', parameters: {
      'engagementType': engagementType,
      ...parameters ?? {},
    });
  }

  /// Track scroll events
  Future<void> trackScroll(String direction, {Map<String, dynamic>? parameters}) async {
    await trackAction('scroll', parameters: {
      'direction': direction,
      ...parameters ?? {},
    });
  }

  /// Track share events
  Future<void> trackShare(String platform, {Map<String, dynamic>? parameters}) async {
    await trackAction('share', parameters: {
      'platform': platform,
      ...parameters ?? {},
    });
  }

  /// Track download events
  Future<void> trackDownload(String contentType, {Map<String, dynamic>? parameters}) async {
    await trackAction('download', parameters: {
      'contentType': contentType,
      ...parameters ?? {},
    });
  }

  /// Track tutorial events
  Future<void> trackTutorial(String step, {Map<String, dynamic>? parameters}) async {
    await trackAction('tutorial', parameters: {
      'step': step,
      ...parameters ?? {},
    });
  }

  /// Track onboarding events
  Future<void> trackOnboarding(String step, {Map<String, dynamic>? parameters}) async {
    await trackAction('onboarding', parameters: {
      'step': step,
      ...parameters ?? {},
    });
  }

  /// Track custom event
  Future<void> trackCustomEvent(String eventName, {Map<String, dynamic>? properties}) async {
    try {
      await _analyticsService.trackCustomEvent(
        eventName: eventName,
        properties: properties ?? {},
        screenName: _currentScreenName ?? '',
      );
    } catch (e) {
      debugPrint('Error tracking custom event: $e');
    }
  }
}

/// Extension methods for common widgets to add analytics tracking
extension AnalyticsWidgetExtension on Widget {
  /// Add tap analytics to any widget
  Widget withTapAnalytics(String eventName, {Map<String, dynamic>? parameters}) {
    return GestureDetector(
      onTap: () {
        // Track the tap event
        AnalyticsService.instance.trackAction(
          eventName,
          actionDetails: parameters ?? {},
        );
      },
      child: this,
    );
  }

  /// Add long press analytics to any widget
  Widget withLongPressAnalytics(String eventName, {Map<String, dynamic>? parameters}) {
    return GestureDetector(
      onLongPress: () {
        // Track the long press event
        AnalyticsService.instance.trackAction(
          '${eventName}_long_press',
          actionDetails: parameters ?? {},
        );
      },
      child: this,
    );
  }
}

/// Analytics tracking for form fields
class AnalyticsFormField extends StatelessWidget {
  final String fieldName;
  final Widget child;
  final bool trackFocus;
  final bool trackChange;

  const AnalyticsFormField({
    Key? key,
    required this.fieldName,
    required this.child,
    this.trackFocus = true,
    this.trackChange = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        onFocusChange: (hasFocus) {
          if (trackFocus && hasFocus) {
            AnalyticsService.instance.trackAction(
              'form_field_focus',
              actionDetails: {'field': fieldName},
            );
          }
        },
        child: child,
      ),
    );
  }
}

/// Analytics tracking for buttons
class AnalyticsButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback? onPressed;
  final Widget child;
  final bool trackTap;
  final Map<String, dynamic>? parameters;

  const AnalyticsButton({
    Key? key,
    required this.buttonName,
    this.onPressed,
    required this.child,
    this.trackTap = true,
    this.parameters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (trackTap) {
          await AnalyticsService.instance.trackAction(
            'button_tap',
            actionDetails: {
              'button': buttonName,
              ...parameters ?? {},
            },
          );
        }

        if (onPressed != null) {
          onPressed!();
        }
      },
      child: child,
    );
  }
}

/// Analytics tracking for navigation
class AnalyticsNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _trackNavigation('push', route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _trackNavigation('pop', route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _trackNavigation('replace', newRoute, oldRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _trackNavigation('remove', route, previousRoute);
  }

  Future<void> _trackNavigation(String action, Route? route, Route? previousRoute) async {
    try {
      final routeName = route?.settings.name ?? 'unknown';
      final previousRouteName = previousRoute?.settings.name ?? 'unknown';

      await AnalyticsService.instance.trackAction(
        'navigation',
        actionDetails: {
          'action': action,
          'route': routeName,
          'previousRoute': previousRouteName,
        },
      );
    } catch (e) {
      debugPrint('Error tracking navigation: $e');
    }
  }
}

/// Analytics tracking for scrollable widgets
class AnalyticsScrollable extends StatelessWidget {
  final String scrollableName;
  final Widget child;
  final bool trackScroll;
  final bool trackScrollEnd;

  const AnalyticsScrollable({
    Key? key,
    required this.scrollableName,
    required this.child,
    this.trackScroll = true,
    this.trackScrollEnd = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (trackScroll && scrollNotification is ScrollStartNotification) {
          AnalyticsService.instance.trackAction(
            'scroll_start',
            actionDetails: {'scrollable': scrollableName},
          );
        }

        if (trackScrollEnd && scrollNotification is ScrollEndNotification) {
          AnalyticsService.instance.trackAction(
            'scroll_end',
            actionDetails: {'scrollable': scrollableName},
          );
        }

        return false;
      },
      child: child,
    );
  }
}

/// Analytics tracking for search functionality
class AnalyticsSearchDelegate extends SearchDelegate {
  final String searchScope;

  AnalyticsSearchDelegate({
    required String hintText,
    required this.searchScope,
  }) : super(searchFieldLabel: hintText);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          _trackSearch('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
        _trackSearch('cancelled');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _trackSearch('submitted');
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  @override
  void showResults(BuildContext context) {
    super.showResults(context);
    _trackSearch('submitted');
  }

  Future<void> _trackSearch(String action) async {
    await AnalyticsService.instance.trackSearch(
      query,
      parameters: {
        'scope': searchScope,
        'action': action,
      },
    );
  }
}

/// Analytics tracking for errors
class AnalyticsErrorHandler {
  static void trackError(
    Object error,
    StackTrace stackTrace, {
    String screenName = '',
    Map<String, dynamic>? context,
  }) {
    AnalyticsService.instance.trackError(
      error.toString(),
      screenName: screenName,
      context: {
        'stackTrace': stackTrace.toString(),
        ...context ?? {},
      },
    );
  }

  static void trackFlutterError(FlutterErrorDetails details) {
    trackError(
      details.exception,
      details.stack ?? StackTrace.current,
      context: {
        'library': details.library,
        'context': details.context?.toString() ?? '',
        'informationCollector': details.informationCollector?.toString() ?? '',
      },
    );
  }
}

/// Utility class for analytics constants
class AnalyticsConstants {
  // Event names
  static const String screenView = 'screen_view';
  static const String buttonTap = 'button_tap';
  static const String navigation = 'navigation';
  static const String search = 'search';
  static const String filter = 'filter';
  static const String formSubmit = 'form_submit';
  static const String error = 'error';
  static const String performance = 'performance_metric';
  static const String conversion = 'conversion';
  static const String featureUsage = 'feature_usage';
  static const String engagement = 'engagement';
  static const String scroll = 'scroll';
  static const String share = 'share';
  static const String download = 'download';
  static const String tutorial = 'tutorial';
  static const String onboarding = 'onboarding';

  // Screen names
  static const String dashboard = 'dashboard';
  static const String platforms = 'platforms';
  static const String transactions = 'transactions';
  static const String analytics = 'analytics';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String notifications = 'notifications';

  // Action types
  static const String view = 'view';
  static const String click = 'click';
  static const String submit = 'submit';
  static const String cancel = 'cancel';
  static const String delete = 'delete';
  static const String edit = 'edit';
  static const String create = 'create';
  static const String update = 'update';
  static const String share = 'share';
  static const String export = 'export';
  static const String import = 'import';
  static const String search = 'search';
  static const String filter = 'filter';
  static const String sort = 'sort';
  static const String refresh = 'refresh';
  static const String loadMore = 'load_more';

  // Device types
  static const String mobile = 'mobile';
  static const String tablet = 'tablet';
  static const String desktop = 'desktop';

  // Platforms
  static const String android = 'android';
  static const String ios = 'ios';
  static const String web = 'web';
  static const String windows = 'windows';
  static const String macos = 'macos';
  static const String linux = 'linux';
}
