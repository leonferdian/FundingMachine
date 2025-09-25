import Joi from 'joi';

export const trackEventSchema = Joi.object({
  sessionId: Joi.string().optional(),
  sessionStart: Joi.date().optional(),
  screenName: Joi.string().required(),
  route: Joi.string().optional(),
  previousScreen: Joi.string().optional(),
  action: Joi.string().required(),
  actionDetails: Joi.object().optional(),
  deviceType: Joi.string().valid('mobile', 'tablet', 'desktop').required(),
  platform: Joi.string().valid('android', 'ios', 'web', 'windows', 'macos', 'linux').required(),
  appVersion: Joi.string().optional(),
  deviceInfo: Joi.object().optional(),
  country: Joi.string().optional(),
  region: Joi.string().optional(),
  city: Joi.string().optional(),
  ipAddress: Joi.string().optional(),
  userAgent: Joi.string().optional(),
  loadTime: Joi.number().integer().min(0).optional(),
  errorCount: Joi.number().integer().min(0).optional(),
  errorDetails: Joi.object().optional()
});

export const trackFundingInteractionSchema = Joi.object({
  platformId: Joi.string().required(),
  interactionType: Joi.string().valid('view', 'favorite', 'apply', 'funded', 'review', 'share').required(),
  amountInvested: Joi.number().precision(2).optional(),
  expectedReturn: Joi.number().precision(2).optional(),
  riskLevel: Joi.string().valid('low', 'medium', 'high').optional(),
  rating: Joi.number().integer().min(1).max(5).optional(),
  review: Joi.string().optional(),
  recommendationScore: Joi.number().integer().min(-10).max(10).optional(),
  conversionStep: Joi.string().optional(),
  conversionValue: Joi.number().precision(2).optional(),
  timeSpent: Joi.number().integer().min(0).optional(),
  sessionId: Joi.string().required(),
  deviceType: Joi.string().valid('mobile', 'tablet', 'desktop').required(),
  platform: Joi.string().valid('android', 'ios', 'web', 'windows', 'macos', 'linux').required()
});

export const generateReportSchema = Joi.object({
  reportType: Joi.string().valid('user_engagement', 'financial_performance', 'platform_usage', 'system_performance', 'custom').required(),
  dateFrom: Joi.date().required(),
  dateTo: Joi.date().min(Joi.ref('dateFrom')).required(),
  filters: Joi.object().required(),
  parameters: Joi.object().optional()
});

export const exportAnalyticsSchema = Joi.object({
  type: Joi.string().valid('csv', 'excel', 'pdf', 'json').required(),
  format: Joi.string().valid('raw', 'aggregated', 'report').required(),
  dateFrom: Joi.date().required(),
  dateTo: Joi.date().min(Joi.ref('dateFrom')).required(),
  filters: Joi.object().required(),
  name: Joi.string().required()
});

export const createNotificationRuleSchema = Joi.object({
  name: Joi.string().required(),
  description: Joi.string().optional(),
  conditions: Joi.array().items(Joi.object({
    metric: Joi.string().required(),
    operator: Joi.string().valid('gt', 'lt', 'gte', 'lte', 'eq', 'ne').required(),
    value: Joi.number().required(),
    timeRange: Joi.string().optional()
  })).min(1).required(),
  actions: Joi.array().items(Joi.object({
    type: Joi.string().valid('email', 'webhook', 'slack', 'dashboard').required(),
    config: Joi.object().required()
  })).min(1).required(),
  cooldownPeriod: Joi.number().integer().min(0).required(),
  enabled: Joi.boolean().default(true)
});

export const analyticsQuerySchema = Joi.object({
  startDate: Joi.date().required(),
  endDate: Joi.date().min(Joi.ref('startDate')).required(),
  screenName: Joi.string().optional(),
  action: Joi.string().optional(),
  limit: Joi.number().integer().min(1).max(1000).default(100),
  offset: Joi.number().integer().min(0).default(0)
});

export const systemMetricsQuerySchema = Joi.object({
  metricType: Joi.string().valid('performance', 'error', 'usage', 'business').optional(),
  metricName: Joi.string().optional(),
  period: Joi.string().valid('minute', 'hour', 'day', 'week', 'month').default('hour'),
  startDate: Joi.date().optional(),
  endDate: Joi.date().optional()
});

export const trendAnalysisSchema = Joi.object({
  days: Joi.number().integer().min(1).max(365).default(30)
});

export const predictiveAnalyticsSchema = Joi.object({
  days: Joi.number().integer().min(1).max(90).default(7)
});

export const anomalyDetectionSchema = Joi.object({
  hours: Joi.number().integer().min(1).max(168).default(24) // Max 1 week
});

export const cohortAnalysisSchema = Joi.object({
  cohortType: Joi.string().default('user_registration'),
  periods: Joi.number().integer().min(1).max(24).default(12)
});

export const funnelAnalysisSchema = Joi.object({
  startDate: Joi.date().optional(),
  endDate: Joi.date().optional()
});

export const customDashboardSchema = Joi.object({
  name: Joi.string().required(),
  description: Joi.string().optional(),
  widgets: Joi.array().items(Joi.object({
    type: Joi.string().valid('chart', 'metric', 'table', 'heatmap').required(),
    title: Joi.string().required(),
    position: Joi.object({
      x: Joi.number().integer().required(),
      y: Joi.number().integer().required(),
      width: Joi.number().integer().min(1).required(),
      height: Joi.number().integer().min(1).required()
    }).required(),
    config: Joi.object().required()
  })).required(),
  layout: Joi.object({
    columns: Joi.number().integer().min(1).max(12).default(6),
    rows: Joi.number().integer().min(1).max(10).default(4)
  }).required(),
  refreshInterval: Joi.number().integer().min(30).max(3600).default(300), // 30 seconds to 1 hour
  isPublic: Joi.boolean().default(false)
});

export const analyticsSettingsSchema = Joi.object({
  trackingEnabled: Joi.boolean().default(true),
  sessionTimeout: Joi.number().integer().min(1).max(120).default(30),
  pageViewTracking: Joi.boolean().default(true),
  eventTracking: Joi.boolean().default(true),
  errorTracking: Joi.boolean().default(true),
  performanceTracking: Joi.boolean().default(true),
  userConsentRequired: Joi.boolean().default(false),
  dataRetentionDays: Joi.number().integer().min(30).max(3650).default(365),
  anonymizeIp: Joi.boolean().default(true),
  compliance: Joi.object({
    gdprEnabled: Joi.boolean().default(true),
    ccpaEnabled: Joi.boolean().default(false),
    consentRequired: Joi.boolean().default(false),
    anonymizationEnabled: Joi.boolean().default(true),
    auditLogging: Joi.boolean().default(true)
  }).default()
});
