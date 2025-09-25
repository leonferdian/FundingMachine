import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  UserAnalytics,
  FundingAnalytics,
  SystemAnalytics,
  AnalyticsReport,
  Prisma
} from '@prisma/client';
import { AnalyticsEventDto, AnalyticsQueryDto, ReportConfigDto } from '../types/analytics';
import { v4 as uuidv4 } from 'uuid';

export enum MetricType {
  PERFORMANCE = 'performance',
  ERROR = 'error',
  USAGE = 'usage',
  BUSINESS = 'business'
}

export enum MetricName {
  // Performance metrics
  API_RESPONSE_TIME = 'api_response_time',
  PAGE_LOAD_TIME = 'page_load_time',
  DATABASE_QUERY_TIME = 'database_query_time',
  MEMORY_USAGE = 'memory_usage',

  // Error metrics
  ERROR_RATE = 'error_rate',
  ERROR_COUNT = 'error_count',
  CRASH_COUNT = 'crash_count',

  // Usage metrics
  ACTIVE_USERS = 'active_users',
  SESSION_DURATION = 'session_duration',
  PAGE_VIEWS = 'page_views',
  FEATURE_USAGE = 'feature_usage',

  // Business metrics
  TOTAL_FUNDING = 'total_funding',
  TOTAL_USERS = 'total_users',
  CONVERSION_RATE = 'conversion_rate',
  REVENUE = 'revenue'
}

export enum ReportType {
  USER_ENGAGEMENT = 'user_engagement',
  FINANCIAL_PERFORMANCE = 'financial_performance',
  PLATFORM_USAGE = 'platform_usage',
  SYSTEM_PERFORMANCE = 'system_performance',
  CUSTOM = 'custom'
}

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Track user analytics events
   */
  async trackUserEvent(eventData: AnalyticsEventDto): Promise<void> {
    try {
      const sessionId = eventData.sessionId || uuidv4();

      await this.prisma.userAnalytics.create({
        data: {
          userId: eventData.userId,
          sessionId,
          sessionStart: eventData.sessionStart || new Date(),
          screenName: eventData.screenName,
          route: eventData.route,
          previousScreen: eventData.previousScreen,
          action: eventData.action,
          actionDetails: eventData.actionDetails,
          deviceType: eventData.deviceType,
          platform: eventData.platform,
          appVersion: eventData.appVersion,
          deviceInfo: eventData.deviceInfo,
          country: eventData.country,
          region: eventData.region,
          city: eventData.city,
          ipAddress: eventData.ipAddress,
          userAgent: eventData.userAgent,
          loadTime: eventData.loadTime,
          errorCount: eventData.errorCount || 0,
          errorDetails: eventData.errorDetails,
          timestamp: new Date()
        }
      });

      // Track system metrics for performance monitoring
      await this.trackSystemMetric(
        MetricType.PERFORMANCE,
        eventData.loadTime ? MetricName.PAGE_LOAD_TIME : MetricName.PAGE_VIEWS,
        eventData.loadTime || 1,
        'ms'
      );

    } catch (error) {
      console.error('Error tracking user analytics:', error);
      // Don't throw error to avoid breaking user flow
    }
  }

  /**
   * Track funding platform interactions
   */
  async trackFundingInteraction(eventData: {
    userId: string;
    platformId: string;
    interactionType: string;
    amountInvested?: number;
    expectedReturn?: number;
    riskLevel?: string;
    rating?: number;
    review?: string;
    recommendationScore?: number;
    conversionStep?: string;
    conversionValue?: number;
    timeSpent?: number;
    sessionId: string;
    deviceType: string;
    platform: string;
  }): Promise<void> {
    try {
      await this.prisma.fundingAnalytics.create({
        data: {
          userId: eventData.userId,
          platformId: eventData.platformId,
          interactionType: eventData.interactionType,
          amountInvested: eventData.amountInvested,
          expectedReturn: eventData.expectedReturn,
          riskLevel: eventData.riskLevel,
          rating: eventData.rating,
          review: eventData.review,
          recommendationScore: eventData.recommendationScore,
          conversionStep: eventData.conversionStep,
          conversionValue: eventData.conversionValue,
          timeSpent: eventData.timeSpent,
          sessionId: eventData.sessionId,
          deviceType: eventData.deviceType,
          platform: eventData.platform,
          timestamp: new Date()
        }
      });

      // Track business metrics
      if (eventData.amountInvested) {
        await this.trackSystemMetric(
          MetricType.BUSINESS,
          MetricName.TOTAL_FUNDING,
          eventData.amountInvested,
          'currency'
        );
      }

    } catch (error) {
      console.error('Error tracking funding analytics:', error);
    }
  }

  /**
   * Track system metrics
   */
  async trackSystemMetric(
    metricType: MetricType,
    metricName: MetricName,
    value: number,
    unit?: string,
    tags?: Record<string, any>,
    metadata?: Record<string, any>
  ): Promise<void> {
    try {
      const now = new Date();
      const periodStart = this.getPeriodStart(now, 'minute');
      const periodEnd = new Date(periodStart.getTime() + 60 * 1000);

      await this.prisma.systemAnalytics.create({
        data: {
          metricType,
          metricName,
          value,
          unit,
          period: 'minute',
          periodStart,
          periodEnd,
          tags,
          metadata,
          timestamp: now
        }
      });

      // Also aggregate for hourly metrics
      await this.aggregateMetrics(metricType, metricName, 'hour');

    } catch (error) {
      console.error('Error tracking system metric:', error);
    }
  }

  /**
   * Aggregate metrics for different time periods
   */
  private async aggregateMetrics(
    metricType: MetricType,
    metricName: MetricName,
    period: 'hour' | 'day' | 'week' | 'month'
  ): Promise<void> {
    try {
      const now = new Date();
      const periodStart = this.getPeriodStart(now, period);

      const aggregatedValue = await this.calculateAggregatedValue(
        metricType,
        metricName,
        periodStart,
        now
      );

      if (aggregatedValue !== null) {
        const periodEnd = this.getPeriodEnd(periodStart, period);

        await this.prisma.systemAnalytics.upsert({
          where: {
            metricType_metricName_period_periodStart: {
              metricType,
              metricName,
              period,
              periodStart
            }
          },
          update: {
            value: aggregatedValue,
            periodEnd,
            timestamp: now
          },
          create: {
            metricType,
            metricName,
            value: aggregatedValue,
            period,
            periodStart,
            periodEnd,
            timestamp: now
          }
        });
      }
    } catch (error) {
      console.error('Error aggregating metrics:', error);
    }
  }

  /**
   * Calculate aggregated value for a metric
   */
  private async calculateAggregatedValue(
    metricType: MetricType,
    metricName: MetricName,
    periodStart: Date,
    periodEnd: Date
  ): Promise<number | null> {
    const result = await this.prisma.systemAnalytics.aggregate({
      where: {
        metricType,
        metricName,
        period: 'minute',
        periodStart: {
          gte: periodStart,
          lt: periodEnd
        }
      },
      _avg: {
        value: true
      },
      _count: {
        id: true
      }
    });

    return result._count.id > 0 ? Number(result._avg.value) : null;
  }

  /**
   * Get user analytics data
   */
  async getUserAnalytics(
    userId: string,
    query: AnalyticsQueryDto
  ): Promise<UserAnalytics[]> {
    const { startDate, endDate, screenName, action, limit = 100, offset = 0 } = query;

    return this.prisma.userAnalytics.findMany({
      where: {
        userId,
        timestamp: {
          gte: startDate,
          lte: endDate
        },
        screenName: screenName ? { contains: screenName } : undefined,
        action: action ? { contains: action } : undefined
      },
      orderBy: {
        timestamp: 'desc'
      },
      take: limit,
      skip: offset
    });
  }

  /**
   * Get funding analytics data
   */
  async getFundingAnalytics(
    userId: string,
    query: AnalyticsQueryDto
  ): Promise<FundingAnalytics[]> {
    const { startDate, endDate, limit = 100, offset = 0 } = query;

    return this.prisma.fundingAnalytics.findMany({
      where: {
        userId,
        timestamp: {
          gte: startDate,
          lte: endDate
        }
      },
      orderBy: {
        timestamp: 'desc'
      },
      take: limit,
      skip: offset,
      include: {
        platform: true
      }
    });
  }

  /**
   * Get system metrics
   */
  async getSystemMetrics(
    metricType?: MetricType,
    metricName?: MetricName,
    period: 'minute' | 'hour' | 'day' | 'week' | 'month' = 'hour',
    startDate?: Date,
    endDate?: Date
  ): Promise<SystemAnalytics[]> {
    return this.prisma.systemAnalytics.findMany({
      where: {
        metricType,
        metricName,
        period,
        periodStart: {
          gte: startDate,
          lte: endDate
        }
      },
      orderBy: {
        periodStart: 'desc'
      }
    });
  }

  /**
   * Generate analytics report
   */
  async generateReport(
    userId: string,
    reportConfig: ReportConfigDto
  ): Promise<AnalyticsReport> {
    const { reportType, dateFrom, dateTo, filters, parameters } = reportConfig;

    // Generate data hash for caching
    const dataHash = this.generateDataHash({
      reportType,
      dateFrom,
      dateTo,
      filters,
      parameters
    });

    // Check if report already exists and is up to date
    const existingReport = await this.prisma.analyticsReport.findFirst({
      where: {
        userId,
        reportType,
        dataHash,
        lastUpdated: {
          gte: new Date(Date.now() - 60 * 60 * 1000) // 1 hour cache
        }
      }
    });

    if (existingReport) {
      return existingReport;
    }

    // Generate new report data
    const reportData = await this.generateReportData(reportType, {
      dateFrom,
      dateTo,
      filters,
      parameters
    });

    // Create or update report
    return this.prisma.analyticsReport.upsert({
      where: {
        userId_reportType_dataHash: {
          userId,
          reportType,
          dataHash
        }
      },
      update: {
        data: reportData,
        lastUpdated: new Date()
      },
      create: {
        userId,
        reportType,
        reportName: this.getReportName(reportType),
        description: this.getReportDescription(reportType),
        dateFrom,
        dateTo,
        filters,
        parameters,
        data: reportData,
        dataHash
      }
    });
  }

  /**
   * Generate report data based on type
   */
  private async generateReportData(
    reportType: ReportType,
    config: { dateFrom: Date; dateTo: Date; filters: any; parameters: any }
  ): Promise<any> {
    switch (reportType) {
      case ReportType.USER_ENGAGEMENT:
        return this.generateUserEngagementReport(config);
      case ReportType.FINANCIAL_PERFORMANCE:
        return this.generateFinancialPerformanceReport(config);
      case ReportType.PLATFORM_USAGE:
        return this.generatePlatformUsageReport(config);
      case ReportType.SYSTEM_PERFORMANCE:
        return this.generateSystemPerformanceReport(config);
      default:
        return {};
    }
  }

  /**
   * Generate user engagement report
   */
  private async generateUserEngagementReport(config: {
    dateFrom: Date;
    dateTo: Date;
    filters: any;
    parameters: any;
  }): Promise<any> {
    const { dateFrom, dateTo } = config;

    // Get user analytics data
    const userAnalytics = await this.prisma.userAnalytics.findMany({
      where: {
        timestamp: {
          gte: dateFrom,
          lte: dateTo
        }
      }
    });

    // Get funding analytics data
    const fundingAnalytics = await this.prisma.fundingAnalytics.findMany({
      where: {
        timestamp: {
          gte: dateFrom,
          lte: dateTo
        }
      },
      include: {
        platform: true
      }
    });

    // Calculate metrics
    const totalSessions = new Set(userAnalytics.map(a => a.sessionId)).size;
    const totalPageViews = userAnalytics.length;
    const averageSessionDuration = userAnalytics.reduce((acc, a) => acc + (a.sessionDuration || 0), 0) / totalSessions;
    const uniqueUsers = new Set(userAnalytics.map(a => a.userId)).size;

    const platformInteractions = fundingAnalytics.length;
    const totalInvested = fundingAnalytics.reduce((acc, a) => acc + (Number(a.amountInvested) || 0), 0);

    return {
      summary: {
        totalUsers: uniqueUsers,
        totalSessions,
        totalPageViews,
        averageSessionDuration: Math.round(averageSessionDuration),
        platformInteractions,
        totalInvested
      },
      userAnalytics: this.aggregateUserAnalytics(userAnalytics),
      fundingAnalytics: this.aggregateFundingAnalytics(fundingAnalytics),
      trends: this.calculateTrends(userAnalytics, fundingAnalytics, dateFrom, dateTo)
    };
  }

  /**
   * Generate financial performance report
   */
  private async generateFinancialPerformanceReport(config: {
    dateFrom: Date;
    dateTo: Date;
    filters: any;
    parameters: any;
  }): Promise<any> {
    const { dateFrom, dateTo } = config;

    // Get funding data
    const fundings = await this.prisma.funding.findMany({
      where: {
        createdAt: {
          gte: dateFrom,
          lte: dateTo
        }
      },
      include: {
        user: true,
        platform: true,
        transactions: true
      }
    });

    // Get transaction data
    const transactions = await this.prisma.transaction.findMany({
      where: {
        createdAt: {
          gte: dateFrom,
          lte: dateTo
        },
        type: {
          in: ['DEPOSIT', 'PROFIT']
        }
      },
      include: {
        user: true,
        funding: true
      }
    });

    const totalFunding = fundings.reduce((acc, f) => acc + f.amount, 0);
    const totalProfit = transactions
      .filter(t => t.type === 'PROFIT')
      .reduce((acc, t) => acc + t.amount, 0);
    const totalDeposits = transactions
      .filter(t => t.type === 'DEPOSIT')
      .reduce((acc, t) => acc + t.amount, 0);

    return {
      summary: {
        totalFunding,
        totalProfit,
        totalDeposits,
        netReturn: totalProfit - totalFunding,
        roi: totalFunding > 0 ? (totalProfit / totalFunding) * 100 : 0
      },
      fundingsByPlatform: this.groupByPlatform(fundings),
      profitByPlatform: this.groupProfitByPlatform(fundings, transactions),
      monthlyTrends: this.calculateMonthlyTrends(fundings, transactions, dateFrom, dateTo)
    };
  }

  /**
   * Generate platform usage report
   */
  private async generatePlatformUsageReport(config: {
    dateFrom: Date;
    dateTo: Date;
    filters: any;
    parameters: any;
  }): Promise<any> {
    const { dateFrom, dateTo } = config;

    const fundingAnalytics = await this.prisma.fundingAnalytics.findMany({
      where: {
        timestamp: {
          gte: dateFrom,
          lte: dateTo
        }
      },
      include: {
        platform: true,
        user: true
      }
    });

    return {
      platformStats: this.calculatePlatformStats(fundingAnalytics),
      userEngagement: this.calculateUserEngagementStats(fundingAnalytics),
      conversionFunnel: this.calculateConversionFunnel(fundingAnalytics),
      topPerformers: this.getTopPerformingPlatforms(fundingAnalytics)
    };
  }

  /**
   * Generate system performance report
   */
  private async generateSystemPerformanceReport(config: {
    dateFrom: Date;
    dateTo: Date;
    filters: any;
    parameters: any;
  }): Promise<any> {
    const { dateFrom, dateTo } = config;

    const systemMetrics = await this.prisma.systemAnalytics.findMany({
      where: {
        timestamp: {
          gte: dateFrom,
          lte: dateTo
        }
      }
    });

    return {
      performanceMetrics: this.aggregatePerformanceMetrics(systemMetrics),
      errorMetrics: this.aggregateErrorMetrics(systemMetrics),
      usageMetrics: this.aggregateUsageMetrics(systemMetrics),
      alerts: this.generatePerformanceAlerts(systemMetrics)
    };
  }

  // Helper methods for data aggregation and calculation
  private aggregateUserAnalytics(analytics: UserAnalytics[]): any {
    const actionsByType = analytics.reduce((acc, a) => {
      acc[a.action] = (acc[a.action] || 0) + 1;
      return acc;
    }, {});

    const screensByName = analytics.reduce((acc, a) => {
      acc[a.screenName] = (acc[a.screenName] || 0) + 1;
      return acc;
    }, {});

    return {
      actionsByType,
      screensByName,
      totalEvents: analytics.length
    };
  }

  private aggregateFundingAnalytics(analytics: FundingAnalytics[]): any {
    const interactionsByType = analytics.reduce((acc, a) => {
      acc[a.interactionType] = (acc[a.interactionType] || 0) + 1;
      return acc;
    }, {});

    const totalInvested = analytics.reduce((acc, a) => acc + (Number(a.amountInvested) || 0), 0);
    const averageRating = analytics
      .filter(a => a.rating)
      .reduce((acc, a, _, arr) => acc + (a.rating! / arr.length), 0);

    return {
      interactionsByType,
      totalInvested,
      averageRating: Math.round(averageRating * 10) / 10
    };
  }

  private calculateTrends(
    userAnalytics: UserAnalytics[],
    fundingAnalytics: FundingAnalytics[],
    startDate: Date,
    endDate: Date
  ): any {
    // Calculate daily trends
    const days = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24));

    const dailyUserActivity = [];
    const dailyFundingActivity = [];

    for (let i = 0; i < days; i++) {
      const day = new Date(startDate.getTime() + i * 24 * 60 * 60 * 1000);
      const nextDay = new Date(day.getTime() + 24 * 60 * 60 * 1000);

      const dayUserEvents = userAnalytics.filter(a =>
        a.timestamp >= day && a.timestamp < nextDay
      ).length;

      const dayFundingEvents = fundingAnalytics.filter(a =>
        a.timestamp >= day && a.timestamp < nextDay
      ).length;

      dailyUserActivity.push({ date: day.toISOString().split('T')[0], events: dayUserEvents });
      dailyFundingActivity.push({ date: day.toISOString().split('T')[0], events: dayFundingEvents });
    }

    return {
      dailyUserActivity,
      dailyFundingActivity,
      trendDirection: this.calculateTrendDirection(dailyUserActivity)
    };
  }

  private calculateTrendDirection(data: { date: string; events: number }[]): 'up' | 'down' | 'stable' {
    if (data.length < 2) return 'stable';

    const recent = data.slice(-7); // Last 7 days
    const previous = data.slice(-14, -7); // Previous 7 days

    const recentAvg = recent.reduce((acc, d) => acc + d.events, 0) / recent.length;
    const previousAvg = previous.reduce((acc, d) => acc + d.events, 0) / previous.length;

    const change = ((recentAvg - previousAvg) / previousAvg) * 100;

    if (change > 10) return 'up';
    if (change < -10) return 'down';
    return 'stable';
  }

  private groupByPlatform(fundings: any[]): any {
    return fundings.reduce((acc, funding) => {
      const platformName = funding.platform.name;
      if (!acc[platformName]) {
        acc[platformName] = { count: 0, totalAmount: 0 };
      }
      acc[platformName].count++;
      acc[platformName].totalAmount += funding.amount;
      return acc;
    }, {});
  }

  private groupProfitByPlatform(fundings: any[], transactions: any[]): any {
    return fundings.reduce((acc, funding) => {
      const platformName = funding.platform.name;
      const platformTransactions = transactions.filter(t => t.fundingId === funding.id);
      const totalProfit = platformTransactions
        .filter(t => t.type === 'PROFIT')
        .reduce((sum, t) => sum + t.amount, 0);

      if (!acc[platformName]) {
        acc[platformName] = { totalProfit, profitCount: platformTransactions.length };
      } else {
        acc[platformName].totalProfit += totalProfit;
        acc[platformName].profitCount += platformTransactions.length;
      }
      return acc;
    }, {});
  }

  private calculateMonthlyTrends(
    fundings: any[],
    transactions: any[],
    startDate: Date,
    endDate: Date
  ): any {
    const months = [];
    const currentDate = new Date(startDate);

    while (currentDate <= endDate) {
      const monthStart = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
      const monthEnd = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);

      const monthFundings = fundings.filter(f =>
        f.createdAt >= monthStart && f.createdAt <= monthEnd
      );

      const monthTransactions = transactions.filter(t =>
        t.createdAt >= monthStart && t.createdAt <= monthEnd
      );

      months.push({
        month: monthStart.toISOString().substring(0, 7),
        fundings: monthFundings.length,
        totalFunding: monthFundings.reduce((sum, f) => sum + f.amount, 0),
        profits: monthTransactions.filter(t => t.type === 'PROFIT').reduce((sum, t) => sum + t.amount, 0)
      });

      currentDate.setMonth(currentDate.getMonth() + 1);
    }

    return months;
  }

  private calculatePlatformStats(fundingAnalytics: FundingAnalytics[]): any {
    const platformStats = fundingAnalytics.reduce((acc, analytics) => {
      const platformName = analytics.platform.name;
      if (!acc[platformName]) {
        acc[platformName] = {
          views: 0,
          interactions: 0,
          totalInvested: 0,
          averageRating: 0,
          ratingCount: 0
        };
      }

      if (analytics.interactionType === 'view') {
        acc[platformName].views++;
      } else {
        acc[platformName].interactions++;
      }

      if (analytics.amountInvested) {
        acc[platformName].totalInvested += Number(analytics.amountInvested);
      }

      if (analytics.rating) {
        acc[platformName].averageRating =
          (acc[platformName].averageRating * acc[platformName].ratingCount + analytics.rating) /
          (acc[platformName].ratingCount + 1);
        acc[platformName].ratingCount++;
      }

      return acc;
    }, {});

    return Object.entries(platformStats).map(([platform, stats]: [string, any]) => ({
      platform,
      ...stats
    }));
  }

  private calculateUserEngagementStats(fundingAnalytics: FundingAnalytics[]): any {
    const userStats = fundingAnalytics.reduce((acc, analytics) => {
      if (!acc[analytics.userId]) {
        acc[analytics.userId] = {
          interactions: 0,
          totalInvested: 0,
          platformsViewed: new Set(),
          lastActivity: analytics.timestamp
        };
      }

      acc[analytics.userId].interactions++;
      if (analytics.amountInvested) {
        acc[analytics.userId].totalInvested += Number(analytics.amountInvested);
      }
      acc[analytics.userId].platformsViewed.add(analytics.platformId);

      if (analytics.timestamp > acc[analytics.userId].lastActivity) {
        acc[analytics.userId].lastActivity = analytics.timestamp;
      }

      return acc;
    }, {});

    const totalUsers = Object.keys(userStats).length;
    const averageInteractions = Object.values(userStats).reduce((acc: number, user: any) => acc + user.interactions, 0) / totalUsers;
    const averageInvestment = Object.values(userStats).reduce((acc: number, user: any) => acc + user.totalInvested, 0) / totalUsers;

    return {
      totalUsers,
      averageInteractions: Math.round(averageInteractions * 10) / 10,
      averageInvestment: Math.round(averageInvestment * 100) / 100,
      userActivityDistribution: this.calculateActivityDistribution(userStats)
    };
  }

  private calculateConversionFunnel(fundingAnalytics: FundingAnalytics[]): any {
    const funnel = {
      views: 0,
      favorites: 0,
      applications: 0,
      investments: 0,
      reviews: 0
    };

    fundingAnalytics.forEach(analytics => {
      switch (analytics.interactionType) {
        case 'view':
          funnel.views++;
          break;
        case 'favorite':
          funnel.favorites++;
          break;
        case 'apply':
          funnel.applications++;
          break;
        case 'funded':
          funnel.investments++;
          break;
        case 'review':
          funnel.reviews++;
          break;
      }
    });

    return {
      ...funnel,
      conversionRates: {
        viewToFavorite: funnel.views > 0 ? (funnel.favorites / funnel.views) * 100 : 0,
        favoriteToApply: funnel.favorites > 0 ? (funnel.applications / funnel.favorites) * 100 : 0,
        applyToInvest: funnel.applications > 0 ? (funnel.investments / funnel.applications) * 100 : 0,
        investToReview: funnel.investments > 0 ? (funnel.reviews / funnel.investments) * 100 : 0
      }
    };
  }

  private getTopPerformingPlatforms(fundingAnalytics: FundingAnalytics[]): any {
    const platformPerformance = fundingAnalytics.reduce((acc, analytics) => {
      const platformName = analytics.platform.name;
      if (!acc[platformName]) {
        acc[platformName] = {
          interactions: 0,
          totalInvested: 0,
          averageRating: 0,
          ratingCount: 0,
          conversionRate: 0
        };
      }

      acc[platformName].interactions++;

      if (analytics.amountInvested) {
        acc[platformName].totalInvested += Number(analytics.amountInvested);
        acc[platformName].conversionRate++;
      }

      if (analytics.rating) {
        acc[platformName].averageRating =
          (acc[platformName].averageRating * acc[platformName].ratingCount + analytics.rating) /
          (acc[platformName].ratingCount + 1);
        acc[platformName].ratingCount++;
      }

      return acc;
    }, {});

    return Object.entries(platformPerformance)
      .map(([platform, stats]: [string, any]) => ({
        platform,
        ...stats,
        conversionRate: stats.interactions > 0 ? (stats.conversionRate / stats.interactions) * 100 : 0
      }))
      .sort((a, b) => b.totalInvested - a.totalInvested)
      .slice(0, 10);
  }

  private calculateActivityDistribution(userStats: any): any {
    const interactions = Object.values(userStats).map((user: any) => user.interactions);
    const maxInteractions = Math.max(...interactions);
    const minInteractions = Math.min(...interactions);

    return {
      highActivity: interactions.filter(i => i >= maxInteractions * 0.7).length,
      mediumActivity: interactions.filter(i => i >= maxInteractions * 0.3 && i < maxInteractions * 0.7).length,
      lowActivity: interactions.filter(i => i < maxInteractions * 0.3).length,
      averageInteractions: Math.round(interactions.reduce((a, b) => a + b, 0) / interactions.length)
    };
  }

  private aggregatePerformanceMetrics(metrics: SystemAnalytics[]): any {
    const performanceMetrics = metrics.filter(m => m.metricType === MetricType.PERFORMANCE);

    return {
      averageResponseTime: this.calculateAverage(performanceMetrics, MetricName.API_RESPONSE_TIME),
      averagePageLoadTime: this.calculateAverage(performanceMetrics, MetricName.PAGE_LOAD_TIME),
      averageDatabaseQueryTime: this.calculateAverage(performanceMetrics, MetricName.DATABASE_QUERY_TIME),
      averageMemoryUsage: this.calculateAverage(performanceMetrics, MetricName.MEMORY_USAGE)
    };
  }

  private aggregateErrorMetrics(metrics: SystemAnalytics[]): any {
    const errorMetrics = metrics.filter(m => m.metricType === MetricType.ERROR);

    return {
      totalErrors: this.calculateSum(errorMetrics, MetricName.ERROR_COUNT),
      errorRate: this.calculateAverage(errorMetrics, MetricName.ERROR_RATE),
      crashCount: this.calculateSum(errorMetrics, MetricName.CRASH_COUNT)
    };
  }

  private aggregateUsageMetrics(metrics: SystemAnalytics[]): any {
    const usageMetrics = metrics.filter(m => m.metricType === MetricType.USAGE);

    return {
      averageActiveUsers: this.calculateAverage(usageMetrics, MetricName.ACTIVE_USERS),
      averageSessionDuration: this.calculateAverage(usageMetrics, MetricName.SESSION_DURATION),
      totalPageViews: this.calculateSum(usageMetrics, MetricName.PAGE_VIEWS)
    };
  }

  private calculateAverage(metrics: SystemAnalytics[], metricName: MetricName): number {
    const relevantMetrics = metrics.filter(m => m.metricName === metricName);
    if (relevantMetrics.length === 0) return 0;

    const sum = relevantMetrics.reduce((acc, m) => acc + Number(m.value), 0);
    return Math.round((sum / relevantMetrics.length) * 100) / 100;
  }

  private calculateSum(metrics: SystemAnalytics[], metricName: MetricName): number {
    return metrics
      .filter(m => m.metricName === metricName)
      .reduce((acc, m) => acc + Number(m.value), 0);
  }

  private generatePerformanceAlerts(metrics: SystemAnalytics[]): any {
    const alerts = [];

    const errorRate = this.calculateAverage(metrics.filter(m => m.metricType === MetricType.ERROR), MetricName.ERROR_RATE);
    if (errorRate > 5) {
      alerts.push({
        type: 'error',
        message: `High error rate detected: ${errorRate.toFixed(2)}%`,
        severity: 'high'
      });
    }

    const avgResponseTime = this.calculateAverage(metrics.filter(m => m.metricType === MetricType.PERFORMANCE), MetricName.API_RESPONSE_TIME);
    if (avgResponseTime > 1000) {
      alerts.push({
        type: 'performance',
        message: `Slow response time detected: ${avgResponseTime.toFixed(0)}ms`,
        severity: 'medium'
      });
    }

    return alerts;
  }

  private getPeriodStart(date: Date, period: string): Date {
    const d = new Date(date);
    switch (period) {
      case 'minute':
        d.setSeconds(0, 0);
        break;
      case 'hour':
        d.setMinutes(0, 0, 0);
        break;
      case 'day':
        d.setHours(0, 0, 0, 0);
        break;
      case 'week':
        const day = d.getDay();
        d.setDate(d.getDate() - day);
        d.setHours(0, 0, 0, 0);
        break;
      case 'month':
        d.setDate(1);
        d.setHours(0, 0, 0, 0);
        break;
    }
    return d;
  }

  private getPeriodEnd(periodStart: Date, period: string): Date {
    const end = new Date(periodStart);
    switch (period) {
      case 'minute':
        end.setMinutes(end.getMinutes() + 1);
        break;
      case 'hour':
        end.setHours(end.getHours() + 1);
        break;
      case 'day':
        end.setDate(end.getDate() + 1);
        break;
      case 'week':
        end.setDate(end.getDate() + 7);
        break;
      case 'month':
        end.setMonth(end.getMonth() + 1);
        break;
    }
    return end;
  }

  private generateDataHash(data: any): string {
    return require('crypto').createHash('md5').update(JSON.stringify(data)).digest('hex');
  }

  private getReportName(reportType: ReportType): string {
    switch (reportType) {
      case ReportType.USER_ENGAGEMENT:
        return 'User Engagement Report';
      case ReportType.FINANCIAL_PERFORMANCE:
        return 'Financial Performance Report';
      case ReportType.PLATFORM_USAGE:
        return 'Platform Usage Report';
      case ReportType.SYSTEM_PERFORMANCE:
        return 'System Performance Report';
      default:
        return 'Custom Analytics Report';
    }
  }

  private getReportDescription(reportType: ReportType): string {
    switch (reportType) {
      case ReportType.USER_ENGAGEMENT:
        return 'Comprehensive analysis of user engagement and activity patterns';
      case ReportType.FINANCIAL_PERFORMANCE:
        return 'Financial performance metrics and investment analysis';
      case ReportType.PLATFORM_USAGE:
        return 'Platform usage statistics and user interaction analysis';
      case ReportType.SYSTEM_PERFORMANCE:
        return 'System performance metrics and technical analysis';
      default:
        return 'Custom analytics report with user-defined parameters';
    }
  }
}
