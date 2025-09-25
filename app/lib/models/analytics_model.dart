import 'package:equatable/equatable.dart';

/// Analytics event model for tracking user interactions
class AnalyticsEvent extends Equatable {
  final String userId;
  final String sessionId;
  final DateTime sessionStart;
  final String screenName;
  final String? route;
  final String? previousScreen;
  final String action;
  final Map<String, dynamic>? actionDetails;
  final String deviceType;
  final String platform;
  final String? appVersion;
  final Map<String, dynamic>? deviceInfo;
  final String? country;
  final String? region;
  final String? city;
  final String? ipAddress;
  final String? userAgent;
  final DateTime timestamp;
  final int? loadTime;
  final int? errorCount;
  final Map<String, dynamic>? errorDetails;

  const AnalyticsEvent({
    required this.userId,
    required this.sessionId,
    required this.sessionStart,
    required this.screenName,
    this.route,
    this.previousScreen,
    required this.action,
    this.actionDetails,
    required this.deviceType,
    required this.platform,
    this.appVersion,
    this.deviceInfo,
    this.country,
    this.region,
    this.city,
    this.ipAddress,
    this.userAgent,
    required this.timestamp,
    this.loadTime,
    this.errorCount,
    this.errorDetails,
  });

  /// Create from JSON
  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      userId: json['userId'],
      sessionId: json['sessionId'],
      sessionStart: DateTime.parse(json['sessionStart']),
      screenName: json['screenName'],
      route: json['route'],
      previousScreen: json['previousScreen'],
      action: json['action'],
      actionDetails: json['actionDetails'],
      deviceType: json['deviceType'],
      platform: json['platform'],
      appVersion: json['appVersion'],
      deviceInfo: json['deviceInfo'],
      country: json['country'],
      region: json['region'],
      city: json['city'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      timestamp: DateTime.parse(json['timestamp']),
      loadTime: json['loadTime'],
      errorCount: json['errorCount'],
      errorDetails: json['errorDetails'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sessionId': sessionId,
      'sessionStart': sessionStart.toIso8601String(),
      'screenName': screenName,
      'route': route,
      'previousScreen': previousScreen,
      'action': action,
      'actionDetails': actionDetails,
      'deviceType': deviceType,
      'platform': platform,
      'appVersion': appVersion,
      'deviceInfo': deviceInfo,
      'country': country,
      'region': region,
      'city': city,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'timestamp': timestamp.toIso8601String(),
      'loadTime': loadTime,
      'errorCount': errorCount,
      'errorDetails': errorDetails,
    };
  }

  @override
  List<Object?> get props => [
    userId,
    sessionId,
    sessionStart,
    screenName,
    route,
    previousScreen,
    action,
    actionDetails,
    deviceType,
    platform,
    appVersion,
    deviceInfo,
    country,
    region,
    city,
    ipAddress,
    userAgent,
    timestamp,
    loadTime,
    errorCount,
    errorDetails,
  ];

  /// Get action icon based on action type
  String get actionIcon {
    switch (action) {
      case 'screen_view':
        return '👁️';
      case 'click':
        return '👆';
      case 'search':
        return '🔍';
      case 'filter':
        return '🔽';
      case 'create':
        return '➕';
      case 'update':
        return '✏️';
      case 'delete':
        return '🗑️';
      case 'share':
        return '📤';
      case 'export':
        return '📊';
      case 'error':
        return '❌';
      case 'performance_metric':
        return '⚡';
      default:
        return '📝';
    }
  }

  /// Get device type icon
  String get deviceTypeIcon {
    switch (deviceType) {
      case 'mobile':
        return '📱';
      case 'tablet':
        return '📟';
      case 'desktop':
        return '🖥️';
      default:
        return '📱';
    }
  }

  /// Get platform icon
  String get platformIcon {
    switch (platform) {
      case 'android':
        return '🤖';
      case 'ios':
        return '🍎';
      case 'web':
        return '🌐';
      case 'windows':
        return '🪟';
      case 'macos':
        return '💻';
      case 'linux':
        return '🐧';
      default:
        return '📱';
    }
  }

  /// Get formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inSeconds}s ago';
    }
  }

  /// Get session duration in readable format
  String get sessionDurationFormatted {
    final endTime = DateTime.now();
    final duration = endTime.difference(sessionStart);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// Analytics report model
class AnalyticsReport extends Equatable {
  final String id;
  final String userId;
  final String reportType;
  final String reportName;
  final String? description;
  final DateTime dateFrom;
  final DateTime dateTo;
  final Map<String, dynamic> filters;
  final Map<String, dynamic>? parameters;
  final Map<String, dynamic> data;
  final String dataHash;
  final DateTime lastUpdated;
  final bool isScheduled;
  final Map<String, dynamic>? scheduleConfig;
  final bool isPublic;
  final List<String>? sharedWith;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnalyticsReport({
    required this.id,
    required this.userId,
    required this.reportType,
    required this.reportName,
    this.description,
    required this.dateFrom,
    required this.dateTo,
    required this.filters,
    this.parameters,
    required this.data,
    required this.dataHash,
    required this.lastUpdated,
    this.isScheduled = false,
    this.scheduleConfig,
    this.isPublic = false,
    this.sharedWith,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory AnalyticsReport.fromJson(Map<String, dynamic> json) {
    return AnalyticsReport(
      id: json['id'],
      userId: json['userId'],
      reportType: json['reportType'],
      reportName: json['reportName'],
      description: json['description'],
      dateFrom: DateTime.parse(json['dateFrom']),
      dateTo: DateTime.parse(json['dateTo']),
      filters: json['filters'],
      parameters: json['parameters'],
      data: json['data'],
      dataHash: json['dataHash'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isScheduled: json['isScheduled'] ?? false,
      scheduleConfig: json['scheduleConfig'],
      isPublic: json['isPublic'] ?? false,
      sharedWith: json['sharedWith'] != null ? List<String>.from(json['sharedWith']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'reportType': reportType,
      'reportName': reportName,
      'description': description,
      'dateFrom': dateFrom.toIso8601String(),
      'dateTo': dateTo.toIso8601String(),
      'filters': filters,
      'parameters': parameters,
      'data': data,
      'dataHash': dataHash,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isScheduled': isScheduled,
      'scheduleConfig': scheduleConfig,
      'isPublic': isPublic,
      'sharedWith': sharedWith,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    reportType,
    reportName,
    description,
    dateFrom,
    dateTo,
    filters,
    parameters,
    data,
    dataHash,
    lastUpdated,
    isScheduled,
    scheduleConfig,
    isPublic,
    sharedWith,
    createdAt,
    updatedAt,
  ];
}

/// Real-time metrics model
class RealTimeMetrics extends Equatable {
  final int activeUsers;
  final int currentSessions;
  final int pageViewsLastHour;
  final double errorRateLastHour;
  final int averageResponseTime;
  final List<ActivePage> topActivePages;
  final List<ErrorPage> topErrorPages;

  const RealTimeMetrics({
    required this.activeUsers,
    required this.currentSessions,
    required this.pageViewsLastHour,
    required this.errorRateLastHour,
    required this.averageResponseTime,
    required this.topActivePages,
    required this.topErrorPages,
  });

  /// Create from JSON
  factory RealTimeMetrics.fromJson(Map<String, dynamic> json) {
    return RealTimeMetrics(
      activeUsers: json['activeUsers'],
      currentSessions: json['currentSessions'],
      pageViewsLastHour: json['pageViewsLastHour'],
      errorRateLastHour: json['errorRateLastHour'].toDouble(),
      averageResponseTime: json['averageResponseTime'],
      topActivePages: (json['topActivePages'] as List)
          .map((item) => ActivePage.fromJson(item))
          .toList(),
      topErrorPages: (json['topErrorPages'] as List)
          .map((item) => ErrorPage.fromJson(item))
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'activeUsers': activeUsers,
      'currentSessions': currentSessions,
      'pageViewsLastHour': pageViewsLastHour,
      'errorRateLastHour': errorRateLastHour,
      'averageResponseTime': averageResponseTime,
      'topActivePages': topActivePages.map((page) => page.toJson()).toList(),
      'topErrorPages': topErrorPages.map((page) => page.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    activeUsers,
    currentSessions,
    pageViewsLastHour,
    errorRateLastHour,
    averageResponseTime,
    topActivePages,
    topErrorPages,
  ];
}

/// Active page model
class ActivePage extends Equatable {
  final String page;
  final int views;

  const ActivePage({
    required this.page,
    required this.views,
  });

  /// Create from JSON
  factory ActivePage.fromJson(Map<String, dynamic> json) {
    return ActivePage(
      page: json['page'],
      views: json['views'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'views': views,
    };
  }

  @override
  List<Object?> get props => [page, views];
}

/// Error page model
class ErrorPage extends Equatable {
  final String page;
  final int errors;

  const ErrorPage({
    required this.page,
    required this.errors,
  });

  /// Create from JSON
  factory ErrorPage.fromJson(Map<String, dynamic> json) {
    return ErrorPage(
      page: json['page'],
      errors: json['errors'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'errors': errors,
    };
  }

  @override
  List<Object?> get props => [page, errors];
}

/// Trend analysis model
class TrendAnalysis extends Equatable {
  final String metric;
  final String trend;
  final double changePercentage;
  final String period;
  final List<DataPoint> dataPoints;

  const TrendAnalysis({
    required this.metric,
    required this.trend,
    required this.changePercentage,
    required this.period,
    required this.dataPoints,
  });

  /// Create from JSON
  factory TrendAnalysis.fromJson(Map<String, dynamic> json) {
    return TrendAnalysis(
      metric: json['metric'],
      trend: json['trend'],
      changePercentage: json['changePercentage'].toDouble(),
      period: json['period'],
      dataPoints: (json['dataPoints'] as List)
          .map((item) => DataPoint.fromJson(item))
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'trend': trend,
      'changePercentage': changePercentage,
      'period': period,
      'dataPoints': dataPoints.map((point) => point.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [metric, trend, changePercentage, period, dataPoints];
}

/// Data point model for charts
class DataPoint extends Equatable {
  final DateTime date;
  final double value;

  const DataPoint({
    required this.date,
    required this.value,
  });

  /// Create from JSON
  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      date: DateTime.parse(json['date']),
      value: json['value'].toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
    };
  }

  @override
  List<Object?> get props => [date, value];
}

/// Predictive analytics model
class PredictiveAnalytics extends Equatable {
  final String metric;
  final double predictedValue;
  final double confidence;
  final String predictionPeriod;
  final List<DataPoint> historicalData;
  final Map<String, double> factors;

  const PredictiveAnalytics({
    required this.metric,
    required this.predictedValue,
    required this.confidence,
    required this.predictionPeriod,
    required this.historicalData,
    required this.factors,
  });

  /// Create from JSON
  factory PredictiveAnalytics.fromJson(Map<String, dynamic> json) {
    return PredictiveAnalytics(
      metric: json['metric'],
      predictedValue: json['predictedValue'].toDouble(),
      confidence: json['confidence'].toDouble(),
      predictionPeriod: json['predictionPeriod'],
      historicalData: (json['historicalData'] as List)
          .map((item) => DataPoint.fromJson(item))
          .toList(),
      factors: Map<String, double>.from(json['factors']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'predictedValue': predictedValue,
      'confidence': confidence,
      'predictionPeriod': predictionPeriod,
      'historicalData': historicalData.map((point) => point.toJson()).toList(),
      'factors': factors,
    };
  }

  @override
  List<Object?> get props => [metric, predictedValue, confidence, predictionPeriod, historicalData, factors];
}

/// Anomaly detection model
class AnomalyDetection extends Equatable {
  final String metric;
  final double currentValue;
  final double expectedValue;
  final double deviation;
  final String severity;
  final DateTime timestamp;
  final String description;

  const AnomalyDetection({
    required this.metric,
    required this.currentValue,
    required this.expectedValue,
    required this.deviation,
    required this.severity,
    required this.timestamp,
    required this.description,
  });

  /// Create from JSON
  factory AnomalyDetection.fromJson(Map<String, dynamic> json) {
    return AnomalyDetection(
      metric: json['metric'],
      currentValue: json['currentValue'].toDouble(),
      expectedValue: json['expectedValue'].toDouble(),
      deviation: json['deviation'].toDouble(),
      severity: json['severity'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'currentValue': currentValue,
      'expectedValue': expectedValue,
      'deviation': deviation,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  @override
  List<Object?> get props => [metric, currentValue, expectedValue, deviation, severity, timestamp, description];
}

/// Cohort analysis model
class CohortAnalysis extends Equatable {
  final String cohortId;
  final int cohortSize;
  final String period;
  final CohortMetrics metrics;
  final List<TrendData> trends;

  const CohortAnalysis({
    required this.cohortId,
    required this.cohortSize,
    required this.period,
    required this.metrics,
    required this.trends,
  });

  /// Create from JSON
  factory CohortAnalysis.fromJson(Map<String, dynamic> json) {
    return CohortAnalysis(
      cohortId: json['cohortId'],
      cohortSize: json['cohortSize'],
      period: json['period'],
      metrics: CohortMetrics.fromJson(json['metrics']),
      trends: (json['trends'] as List)
          .map((item) => TrendData.fromJson(item))
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cohortId': cohortId,
      'cohortSize': cohortSize,
      'period': period,
      'metrics': metrics.toJson(),
      'trends': trends.map((trend) => trend.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [cohortId, cohortSize, period, metrics, trends];
}

/// Cohort metrics model
class CohortMetrics extends Equatable {
  final double retentionRate;
  final double averageRevenue;
  final double conversionRate;
  final double churnRate;

  const CohortMetrics({
    required this.retentionRate,
    required this.averageRevenue,
    required this.conversionRate,
    required this.churnRate,
  });

  /// Create from JSON
  factory CohortMetrics.fromJson(Map<String, dynamic> json) {
    return CohortMetrics(
      retentionRate: json['retentionRate'].toDouble(),
      averageRevenue: json['averageRevenue'].toDouble(),
      conversionRate: json['conversionRate'].toDouble(),
      churnRate: json['churnRate'].toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'retentionRate': retentionRate,
      'averageRevenue': averageRevenue,
      'conversionRate': conversionRate,
      'churnRate': churnRate,
    };
  }

  @override
  List<Object?> get props => [retentionRate, averageRevenue, conversionRate, churnRate];
}

/// Trend data model
class TrendData extends Equatable {
  final String period;
  final double value;

  const TrendData({
    required this.period,
    required this.value,
  });

  /// Create from JSON
  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      period: json['period'],
      value: json['value'].toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'value': value,
    };
  }

  @override
  List<Object?> get props => [period, value];
}
