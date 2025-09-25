export interface AnalyticsEventDto {
  userId: string;
  sessionId?: string;
  sessionStart?: Date;
  screenName: string;
  route?: string;
  previousScreen?: string;
  action: string;
  actionDetails?: Record<string, any>;
  deviceType: string;
  platform: string;
  appVersion?: string;
  deviceInfo?: Record<string, any>;
  country?: string;
  region?: string;
  city?: string;
  ipAddress?: string;
  userAgent?: string;
  loadTime?: number;
  errorCount?: number;
  errorDetails?: Record<string, any>;
}

export interface AnalyticsQueryDto {
  startDate: Date;
  endDate: Date;
  screenName?: string;
  action?: string;
  limit?: number;
  offset?: number;
}

export interface ReportConfigDto {
  reportType: ReportType;
  dateFrom: Date;
  dateTo: Date;
  filters: Record<string, any>;
  parameters?: Record<string, any>;
}

export enum ReportType {
  USER_ENGAGEMENT = 'user_engagement',
  FINANCIAL_PERFORMANCE = 'financial_performance',
  PLATFORM_USAGE = 'platform_usage',
  SYSTEM_PERFORMANCE = 'system_performance',
  CUSTOM = 'custom'
}

export interface UserEngagementReport {
  summary: {
    totalUsers: number;
    totalSessions: number;
    totalPageViews: number;
    averageSessionDuration: number;
    platformInteractions: number;
    totalInvested: number;
  };
  userAnalytics: {
    actionsByType: Record<string, number>;
    screensByName: Record<string, number>;
    totalEvents: number;
  };
  fundingAnalytics: {
    interactionsByType: Record<string, number>;
    totalInvested: number;
    averageRating: number;
  };
  trends: {
    dailyUserActivity: Array<{ date: string; events: number }>;
    dailyFundingActivity: Array<{ date: string; events: number }>;
    trendDirection: 'up' | 'down' | 'stable';
  };
}

export interface FinancialPerformanceReport {
  summary: {
    totalFunding: number;
    totalProfit: number;
    totalDeposits: number;
    netReturn: number;
    roi: number;
  };
  fundingsByPlatform: Record<string, { count: number; totalAmount: number }>;
  profitByPlatform: Record<string, { totalProfit: number; profitCount: number }>;
  monthlyTrends: Array<{
    month: string;
    fundings: number;
    totalFunding: number;
    profits: number;
  }>;
}

export interface PlatformUsageReport {
  platformStats: Array<{
    platform: string;
    views: number;
    interactions: number;
    totalInvested: number;
    averageRating: number;
    ratingCount: number;
  }>;
  userEngagement: {
    totalUsers: number;
    averageInteractions: number;
    averageInvestment: number;
    userActivityDistribution: {
      highActivity: number;
      mediumActivity: number;
      lowActivity: number;
      averageInteractions: number;
    };
  };
  conversionFunnel: {
    views: number;
    favorites: number;
    applications: number;
    investments: number;
    reviews: number;
    conversionRates: {
      viewToFavorite: number;
      favoriteToApply: number;
      applyToInvest: number;
      investToReview: number;
    };
  };
  topPerformers: Array<{
    platform: string;
    interactions: number;
    totalInvested: number;
    averageRating: number;
    ratingCount: number;
    conversionRate: number;
  }>;
}

export interface SystemPerformanceReport {
  performanceMetrics: {
    averageResponseTime: number;
    averagePageLoadTime: number;
    averageDatabaseQueryTime: number;
    averageMemoryUsage: number;
  };
  errorMetrics: {
    totalErrors: number;
    errorRate: number;
    crashCount: number;
  };
  usageMetrics: {
    averageActiveUsers: number;
    averageSessionDuration: number;
    totalPageViews: number;
  };
  alerts: Array<{
    type: string;
    message: string;
    severity: string;
  }>;
}

export type AnalyticsReportData =
  | UserEngagementReport
  | FinancialPerformanceReport
  | PlatformUsageReport
  | SystemPerformanceReport
  | Record<string, any>;

export interface AnalyticsReport {
  id: string;
  userId: string;
  reportType: ReportType;
  reportName: string;
  description?: string;
  dateFrom: Date;
  dateTo: Date;
  filters: Record<string, any>;
  parameters?: Record<string, any>;
  data: AnalyticsReportData;
  dataHash: string;
  lastUpdated: Date;
  isScheduled: boolean;
  scheduleConfig?: Record<string, any>;
  isPublic: boolean;
  sharedWith?: string[];
  createdAt: Date;
  updatedAt: Date;
}

export interface AnalyticsFilters {
  userId?: string;
  platformId?: string;
  deviceType?: string;
  platform?: string;
  dateRange?: {
    start: Date;
    end: Date;
  };
  customFilters?: Record<string, any>;
}

export interface AnalyticsAggregation {
  groupBy: string[];
  metrics: string[];
  timeRange: {
    start: Date;
    end: Date;
    interval: 'hour' | 'day' | 'week' | 'month';
  };
}

export interface RealTimeMetrics {
  activeUsers: number;
  currentSessions: number;
  pageViewsLastHour: number;
  errorRateLastHour: number;
  averageResponseTime: number;
  topActivePages: Array<{ page: string; views: number }>;
  topErrorPages: Array<{ page: string; errors: number }>;
}

export interface TrendAnalysis {
  metric: string;
  trend: 'increasing' | 'decreasing' | 'stable';
  changePercentage: number;
  period: string;
  dataPoints: Array<{ date: Date; value: number }>;
}

export interface PredictiveAnalytics {
  metric: string;
  predictedValue: number;
  confidence: number;
  predictionPeriod: string;
  historicalData: Array<{ date: Date; value: number }>;
  factors: Record<string, number>;
}

export interface AnomalyDetection {
  metric: string;
  currentValue: number;
  expectedValue: number;
  deviation: number;
  severity: 'low' | 'medium' | 'high' | 'critical';
  timestamp: Date;
  description: string;
}

export interface CohortAnalysis {
  cohortId: string;
  cohortSize: number;
  period: string;
  metrics: {
    retentionRate: number;
    averageRevenue: number;
    conversionRate: number;
    churnRate: number;
  };
  trends: Array<{ period: string; value: number }>;
}

export interface FunnelAnalysis {
  funnelId: string;
  steps: Array<{
    stepId: string;
    stepName: string;
    users: number;
    conversionRate: number;
    dropOffRate: number;
  }>;
  overallConversionRate: number;
  averageTimeToConvert: number;
}

export interface HeatmapData {
  page: string;
  elements: Array<{
    selector: string;
    clicks: number;
    x: number;
    y: number;
    width: number;
    height: number;
  }>;
  dimensions: {
    width: number;
    height: number;
  };
}

export interface SessionRecording {
  sessionId: string;
  userId: string;
  startTime: Date;
  endTime?: Date;
  duration: number;
  events: Array<{
    timestamp: Date;
    type: 'click' | 'scroll' | 'page_view' | 'form_submit' | 'error';
    data: Record<string, any>;
  }>;
  metadata: {
    deviceType: string;
    platform: string;
    userAgent: string;
    viewport: { width: number; height: number };
  };
}

export interface ABTestResult {
  testId: string;
  testName: string;
  variants: Array<{
    variantId: string;
    variantName: string;
    users: number;
    conversions: number;
    conversionRate: number;
    confidence: number;
    improvement: number;
  }>;
  winner?: string;
  recommendation: string;
  status: 'running' | 'completed' | 'paused';
}

export interface CustomDashboard {
  id: string;
  userId: string;
  name: string;
  description?: string;
  widgets: Array<{
    id: string;
    type: 'chart' | 'metric' | 'table' | 'heatmap';
    title: string;
    position: { x: number; y: number; width: number; height: number };
    config: Record<string, any>;
    data: any;
  }>;
  layout: {
    columns: number;
    rows: number;
  };
  refreshInterval: number; // in seconds
  isPublic: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface NotificationRule {
  id: string;
  name: string;
  description?: string;
  conditions: Array<{
    metric: string;
    operator: 'gt' | 'lt' | 'gte' | 'lte' | 'eq' | 'ne';
    value: number;
    timeRange?: string;
  }>;
  actions: Array<{
    type: 'email' | 'webhook' | 'slack' | 'dashboard';
    config: Record<string, any>;
  }>;
  cooldownPeriod: number; // in minutes
  enabled: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface AnalyticsExport {
  id: string;
  userId: string;
  name: string;
  type: 'csv' | 'excel' | 'pdf' | 'json';
  format: 'raw' | 'aggregated' | 'report';
  dateRange: {
    start: Date;
    end: Date;
  };
  filters: Record<string, any>;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  downloadUrl?: string;
  expiresAt?: Date;
  createdAt: Date;
  completedAt?: Date;
}

export interface DataRetentionPolicy {
  dataType: string;
  retentionPeriod: number; // in days
  archiveAfter?: number; // in days
  deleteAfter?: number; // in days
  anonymizeAfter?: number; // in days
}

export interface ComplianceSettings {
  gdprEnabled: boolean;
  ccpaEnabled: boolean;
  dataRetention: DataRetentionPolicy[];
  consentRequired: boolean;
  anonymizationEnabled: boolean;
  auditLogging: boolean;
}

export interface AnalyticsSettings {
  trackingEnabled: boolean;
  sessionTimeout: number; // in minutes
  pageViewTracking: boolean;
  eventTracking: boolean;
  errorTracking: boolean;
  performanceTracking: boolean;
  userConsentRequired: boolean;
  dataRetentionDays: number;
  anonymizeIp: boolean;
  compliance: ComplianceSettings;
}
