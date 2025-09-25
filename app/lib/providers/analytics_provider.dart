import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../models/analytics_model.dart';

/// Analytics state class
class AnalyticsState {
  final bool isLoading;
  final String? error;
  final RealTimeMetrics? realTimeMetrics;
  final List<Map<String, dynamic>> userEngagementData;
  final List<Map<String, dynamic>> platformPerformanceData;
  final List<Map<String, dynamic>> topPlatforms;
  final List<Map<String, dynamic>> userGrowthData;
  final List<Map<String, dynamic>> userDemographics;
  final List<Map<String, dynamic>> revenueData;
  final Map<String, double> revenueBreakdown;
  final List<Map<String, dynamic>> performanceData;
  final List<Map<String, dynamic>> performanceAlerts;
  final List<Map<String, dynamic>> errorData;
  final List<Map<String, dynamic>> topErrorPages;

  const AnalyticsState({
    this.isLoading = false,
    this.error,
    this.realTimeMetrics,
    this.userEngagementData = const [],
    this.platformPerformanceData = const [],
    this.topPlatforms = const [],
    this.userGrowthData = const [],
    this.userDemographics = const [],
    this.revenueData = const [],
    this.revenueBreakdown = const {},
    this.performanceData = const [],
    this.performanceAlerts = const [],
    this.errorData = const [],
    this.topErrorPages = const [],
  });

  /// Copy with method
  AnalyticsState copyWith({
    bool? isLoading,
    String? error,
    RealTimeMetrics? realTimeMetrics,
    List<Map<String, dynamic>>? userEngagementData,
    List<Map<String, dynamic>>? platformPerformanceData,
    List<Map<String, dynamic>>? topPlatforms,
    List<Map<String, dynamic>>? userGrowthData,
    List<Map<String, dynamic>>? userDemographics,
    List<Map<String, dynamic>>? revenueData,
    Map<String, double>? revenueBreakdown,
    List<Map<String, dynamic>>? performanceData,
    List<Map<String, dynamic>>? performanceAlerts,
    List<Map<String, dynamic>>? errorData,
    List<Map<String, dynamic>>? topErrorPages,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      realTimeMetrics: realTimeMetrics ?? this.realTimeMetrics,
      userEngagementData: userEngagementData ?? this.userEngagementData,
      platformPerformanceData: platformPerformanceData ?? this.platformPerformanceData,
      topPlatforms: topPlatforms ?? this.topPlatforms,
      userGrowthData: userGrowthData ?? this.userGrowthData,
      userDemographics: userDemographics ?? this.userDemographics,
      revenueData: revenueData ?? this.revenueData,
      revenueBreakdown: revenueBreakdown ?? this.revenueBreakdown,
      performanceData: performanceData ?? this.performanceData,
      performanceAlerts: performanceAlerts ?? this.performanceAlerts,
      errorData: errorData ?? this.errorData,
      topErrorPages: topErrorPages ?? this.topErrorPages,
    );
  }
}

/// Analytics notifier
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsService _analyticsService;

  AnalyticsNotifier(this._analyticsService) : super(const AnalyticsState()) {
    _initializeAnalytics();
  }

  /// Initialize analytics
  Future<void> _initializeAnalytics() async {
    try {
      await _analyticsService.initialize();
      debugPrint('✅ Analytics service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing analytics: $e');
    }
  }

  /// Load dashboard data
  Future<void> loadDashboardData(DateTimeRange dateRange) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load real-time metrics
      final realTimeMetrics = await _analyticsService.getRealTimeMetrics();

      // Load user engagement data
      final userEngagementData = await _analyticsService.getUserEngagementData(dateRange);

      // Load platform performance data
      final platformPerformanceData = await _analyticsService.getPlatformPerformanceData(dateRange);

      // Load top platforms
      final topPlatforms = await _analyticsService.getTopPlatforms();

      // Load user growth data
      final userGrowthData = await _analyticsService.getUserGrowthData(dateRange);

      // Load user demographics
      final userDemographics = await _analyticsService.getUserDemographics();

      // Load revenue data
      final revenueData = await _analyticsService.getRevenueData(dateRange);

      // Load revenue breakdown
      final revenueBreakdown = await _analyticsService.getRevenueBreakdown(dateRange);

      // Load performance data
      final performanceData = await _analyticsService.getPerformanceData(dateRange);

      // Load performance alerts
      final performanceAlerts = await _analyticsService.getPerformanceAlerts();

      // Load error data
      final errorData = await _analyticsService.getErrorData(dateRange);

      // Load top error pages
      final topErrorPages = await _analyticsService.getTopErrorPages();

      state = state.copyWith(
        isLoading: false,
        realTimeMetrics: realTimeMetrics,
        userEngagementData: userEngagementData,
        platformPerformanceData: platformPerformanceData,
        topPlatforms: topPlatforms,
        userGrowthData: userGrowthData,
        userDemographics: userDemographics,
        revenueData: revenueData,
        revenueBreakdown: revenueBreakdown,
        performanceData: performanceData,
        performanceAlerts: performanceAlerts,
        errorData: errorData,
        topErrorPages: topErrorPages,
      );

      debugPrint('✅ Analytics dashboard data loaded successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      debugPrint('❌ Error loading analytics dashboard data: $e');
    }
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName, {Map<String, dynamic>? parameters}) async {
    try {
      await _analyticsService.trackScreenView(
        screenName: screenName,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('❌ Error tracking screen view: $e');
    }
  }

  /// Track user action
  Future<void> trackAction(String action, {String screenName = '', Map<String, dynamic>? parameters}) async {
    try {
      await _analyticsService.trackAction(
        action: action,
        screenName: screenName,
        actionDetails: parameters,
      );
    } catch (e) {
      debugPrint('❌ Error tracking action: $e');
    }
  }

  /// Track error
  Future<void> trackError(String errorMessage, {String screenName = '', Map<String, dynamic>? context}) async {
    try {
      await _analyticsService.trackError(
        errorMessage: errorMessage,
        screenName: screenName,
        context: context,
      );
    } catch (e) {
      debugPrint('❌ Error tracking error: $e');
    }
  }

  /// Generate custom report
  Future<void> generateReport(String reportType, DateTimeRange dateRange) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _analyticsService.generateReport(reportType, dateRange);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Export analytics data
  Future<void> exportData(String type, DateTimeRange dateRange) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _analyticsService.exportData(type, dateRange);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Analytics provider
final analyticsNotifierProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final analyticsService = AnalyticsService.instance;
  return AnalyticsNotifier(analyticsService);
});

/// Real-time metrics provider
final realTimeMetricsProvider = StreamProvider<RealTimeMetrics>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (_) async {
    final analyticsService = AnalyticsService.instance;
    return await analyticsService.getRealTimeMetrics();
  }).asyncMap((event) async => await event);
});

/// User engagement data provider
final userEngagementProvider = FutureProvider.family<List<Map<String, dynamic>>, DateTimeRange>((ref, dateRange) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getUserEngagementData(dateRange);
});

/// Platform performance data provider
final platformPerformanceProvider = FutureProvider.family<List<Map<String, dynamic>>, DateTimeRange>((ref, dateRange) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getPlatformPerformanceData(dateRange);
});

/// Top platforms provider
final topPlatformsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getTopPlatforms();
});

/// User growth data provider
final userGrowthProvider = FutureProvider.family<List<Map<String, dynamic>>, DateTimeRange>((ref, dateRange) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getUserGrowthData(dateRange);
});

/// User demographics provider
final userDemographicsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getUserDemographics();
});

/// Revenue data provider
final revenueProvider = FutureProvider.family<List<Map<String, dynamic>>, DateTimeRange>((ref, dateRange) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getRevenueData(dateRange);
});

/// Revenue breakdown provider
final revenueBreakdownProvider = FutureProvider.family<Map<String, double>, DateTimeRange>((ref, dateRange) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getRevenueBreakdown(dateRange);
});

/// Performance data provider
final performanceProvider = FutureProvider.family<List<Map<String, dynamic>>, DateTimeRange>((ref, dateRange) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getPerformanceData(dateRange);
});

/// Performance alerts provider
final performanceAlertsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getPerformanceAlerts();
});

/// Error data provider
final errorProvider = FutureProvider.family<List<Map<String, dynamic>>, DateTimeRange>((ref, dateRange) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getErrorData(dateRange);
});

/// Top error pages provider
final topErrorPagesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final analyticsService = AnalyticsService.instance;
  return await analyticsService.getTopErrorPages();
});
