import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_provider.dart';
import '../models/analytics_model.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/analytics_metric_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  String _selectedPeriod = '30d';
  String _selectedMetric = 'overview';

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyticsData();
    });
  }

  Future<void> _loadAnalyticsData() async {
    final analyticsNotifier = ref.read(analyticsNotifierProvider.notifier);
    await analyticsNotifier.loadDashboardData(_dateRange);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      await _loadAnalyticsData();
    }
  }

  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });

    DateTime startDate;
    final endDate = DateTime.now();

    switch (period) {
      case '7d':
        startDate = endDate.subtract(const Duration(days: 7));
        break;
      case '30d':
        startDate = endDate.subtract(const Duration(days: 30));
        break;
      case '90d':
        startDate = endDate.subtract(const Duration(days: 90));
        break;
      case '1y':
        startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
        break;
      default:
        startDate = endDate.subtract(const Duration(days: 30));
    }

    setState(() {
      _dateRange = DateTimeRange(start: startDate, end: endDate);
    });

    _loadAnalyticsData();
  }

  void _changeMetric(String metric) {
    setState(() {
      _selectedMetric = metric;
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: analyticsState.isLoading
          ? const LoadingWidget(message: 'Loading analytics data...')
          : analyticsState.error != null
              ? ErrorWidget(
                  message: analyticsState.error!,
                  onRetry: _loadAnalyticsData,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period selector
                      _buildPeriodSelector(),

                      const SizedBox(height: 24),

                      // Real-time metrics
                      if (_selectedMetric == 'overview') ...[
                        _buildRealTimeMetrics(analyticsState.realTimeMetrics),
                        const SizedBox(height: 24),
                      ],

                      // Metric selector
                      _buildMetricSelector(),

                      const SizedBox(height: 24),

                      // Main content based on selected metric
                      _buildMetricContent(analyticsState),

                      const SizedBox(height: 32),

                      // Quick actions
                      _buildQuickActions(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPeriodSelector() {
    const periods = [
      {'label': '7D', 'value': '7d'},
      {'label': '30D', 'value': '30d'},
      {'label': '90D', 'value': '90d'},
      {'label': '1Y', 'value': '1y'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20),
          const SizedBox(width: 8),
          Text(
            '${DateFormat('MMM d').format(_dateRange.start)} - ${DateFormat('MMM d, yyyy').format(_dateRange.end)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ...periods.map((period) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(period['label']!),
              selected: _selectedPeriod == period['value'],
              onSelected: (selected) {
                if (selected) _changePeriod(period['value']!);
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRealTimeMetrics(RealTimeMetrics? metrics) {
    if (metrics == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Real-Time Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Active Users',
                value: metrics.activeUsers.toString(),
                icon: Icons.people,
                color: Colors.blue,
                subtitle: 'Currently online',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Sessions',
                value: metrics.currentSessions.toString(),
                icon: Icons.session,
                color: Colors.green,
                subtitle: 'Active sessions',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Page Views',
                value: metrics.pageViewsLastHour.toString(),
                icon: Icons.visibility,
                color: Colors.orange,
                subtitle: 'Last hour',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Error Rate',
                value: '${metrics.errorRateLastHour.toStringAsFixed(1)}%',
                icon: Icons.error,
                color: metrics.errorRateLastHour > 5 ? Colors.red : Colors.green,
                subtitle: 'Last hour',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnalyticsMetricCard(
                title: 'Avg Response',
                value: '${metrics.averageResponseTime}ms',
                icon: Icons.speed,
                color: Colors.purple,
                subtitle: 'API response time',
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox.shrink()), // Empty space for alignment
          ],
        ),
      ],
    );
  }

  Widget _buildMetricSelector() {
    const metrics = [
      {'label': 'Overview', 'value': 'overview', 'icon': Icons.dashboard},
      {'label': 'Users', 'value': 'users', 'icon': Icons.people},
      {'label': 'Revenue', 'value': 'revenue', 'icon': Icons.attach_money},
      {'label': 'Performance', 'value': 'performance', 'icon': Icons.speed},
      {'label': 'Errors', 'value': 'errors', 'icon': Icons.error},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: metrics.map((metric) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Row(
              children: [
                Icon(metric['icon'] as IconData, size: 18),
                const SizedBox(width: 8),
                Text(metric['label'] as String),
              ],
            ),
            selected: _selectedMetric == metric['value'],
            onSelected: (selected) {
              if (selected) _changeMetric(metric['value'] as String);
            },
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMetricContent(AnalyticsState analyticsState) {
    switch (_selectedMetric) {
      case 'overview':
        return _buildOverviewContent(analyticsState);
      case 'users':
        return _buildUsersContent(analyticsState);
      case 'revenue':
        return _buildRevenueContent(analyticsState);
      case 'performance':
        return _buildPerformanceContent(analyticsState);
      case 'errors':
        return _buildErrorsContent(analyticsState);
      default:
        return _buildOverviewContent(analyticsState);
    }
  }

  Widget _buildOverviewContent(AnalyticsState analyticsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // User engagement chart
        AnalyticsChart(
          title: 'User Engagement',
          data: analyticsState.userEngagementData,
          chartType: ChartType.line,
          height: 200,
        ),

        const SizedBox(height: 24),

        // Platform performance
        AnalyticsChart(
          title: 'Platform Performance',
          data: analyticsState.platformPerformanceData,
          chartType: ChartType.bar,
          height: 200,
        ),

        const SizedBox(height: 24),

        // Top performing platforms
        if (analyticsState.topPlatforms.isNotEmpty) ...[
          const Text(
            'Top Performing Platforms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...analyticsState.topPlatforms.take(5).map((platform) => ListTile(
            leading: CircleAvatar(
              child: Text(platform['name']![0].toUpperCase()),
            ),
            title: Text(platform['name']!),
            subtitle: Text('Conversion: ${(platform['conversionRate']! * 100).toStringAsFixed(1)}%'),
            trailing: Text(
              '\$${platform['revenue']!.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildUsersContent(AnalyticsState analyticsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        AnalyticsChart(
          title: 'User Growth',
          data: analyticsState.userGrowthData,
          chartType: ChartType.area,
          height: 200,
        ),

        const SizedBox(height: 24),

        // User demographics
        if (analyticsState.userDemographics.isNotEmpty) ...[
          const Text(
            'User Demographics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          AnalyticsChart(
            title: 'Device Types',
            data: analyticsState.userDemographics,
            chartType: ChartType.pie,
            height: 200,
          ),
        ],
      ],
    );
  }

  Widget _buildRevenueContent(AnalyticsState analyticsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revenue Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        AnalyticsChart(
          title: 'Revenue Trends',
          data: analyticsState.revenueData,
          chartType: ChartType.line,
          height: 200,
        ),

        const SizedBox(height: 24),

        // Revenue breakdown
        if (analyticsState.revenueBreakdown.isNotEmpty) ...[
          const Text(
            'Revenue by Platform',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...analyticsState.revenueBreakdown.entries.map((entry) => ListTile(
            title: Text(entry.key),
            trailing: Text(
              '\$${entry.value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildPerformanceContent(AnalyticsState analyticsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        AnalyticsChart(
          title: 'Response Times',
          data: analyticsState.performanceData,
          chartType: ChartType.line,
          height: 200,
        ),

        const SizedBox(height: 24),

        // Performance alerts
        if (analyticsState.performanceAlerts.isNotEmpty) ...[
          const Text(
            'Performance Alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...analyticsState.performanceAlerts.map((alert) => Card(
            color: alert['severity'] == 'high' ? Colors.red[50] : Colors.orange[50],
            child: ListTile(
              leading: Icon(
                alert['severity'] == 'high' ? Icons.error : Icons.warning,
                color: alert['severity'] == 'high' ? Colors.red : Colors.orange,
              ),
              title: Text(alert['message']!),
              subtitle: Text(alert['timestamp']!),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildErrorsContent(AnalyticsState analyticsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Error Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        AnalyticsChart(
          title: 'Error Trends',
          data: analyticsState.errorData,
          chartType: ChartType.line,
          height: 200,
        ),

        const SizedBox(height: 24),

        // Top error pages
        if (analyticsState.topErrorPages.isNotEmpty) ...[
          const Text(
            'Top Error Pages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...analyticsState.topErrorPages.map((error) => ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: Text(error['page']!),
            trailing: Text(
              '${error['errors']} errors',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Export analytics data
                },
                icon: const Icon(Icons.download),
                label: const Text('Export Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Generate custom report
                },
                icon: const Icon(Icons.assessment),
                label: const Text('Custom Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // View detailed analytics
                },
                icon: const Icon(Icons.analytics),
                label: const Text('Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
