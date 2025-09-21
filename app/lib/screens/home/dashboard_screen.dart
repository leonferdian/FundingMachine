import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../services/dashboard_service.dart';
import 'dashboard_widgets/balance_card.dart';
import 'dashboard_widgets/transactions_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // State variables
  final DashboardService _dashboardService = DashboardService();
  double _totalBalance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpenses = 0.0;
  final List<Transaction> _recentTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    // Cancel any ongoing requests
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Load dashboard summary
      final dashboardData = await _dashboardService.getDashboardData();
      
      // Load recent transactions
      final transactions = await _dashboardService.getRecentTransactions();
      
      if (mounted) {
        setState(() {
          _totalBalance = (dashboardData['totalBalance'] ?? 0).toDouble();
          _monthlyIncome = (dashboardData['monthlyIncome'] ?? 0).toDouble();
          _monthlyExpenses = (dashboardData['monthlyExpenses'] ?? 0).toDouble();
          _recentTransactions.clear();
          _recentTransactions.addAll(transactions);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to build the main content
  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(
              balance: _totalBalance,
              isLoading: _isLoading,
              onRefresh: _loadDashboardData,
            ),
            const SizedBox(height: 16),
            _buildOverviewSection(),
            const SizedBox(height: 24),
            TransactionsList(
              transactions: _recentTransactions,
              isLoading: _isLoading,
              onRefresh: _loadDashboardData,
              showViewAll: true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _buildMainContent(),
    );
  }

  // Removed _buildBalanceCard as it's now in its own file

  Widget _buildOverviewSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Monthly Overview'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  'Income',
                  '\$${_monthlyIncome.toStringAsFixed(2)}',
                  Icons.arrow_downward,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Expenses',
                  '\$${_monthlyExpenses.toStringAsFixed(2)}',
                  Icons.arrow_upward,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String amount, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    amount,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Icon(icon, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to transactions screen
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }
}
