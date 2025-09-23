import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../services/dashboard_service.dart';

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
    // TODO: Cancel any ongoing requests
    super.dispose();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(),
                      const SizedBox(height: 16),
                      _buildOverviewSection(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Recent Transactions'),
                      _buildTransactionsList(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Quick Actions'),
                      _buildQuickActions(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_totalBalance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIncomeExpense(
                  icon: Icons.arrow_downward,
                  label: 'Income',
                  amount: _monthlyIncome,
                  isIncome: true,
                ),
                _buildIncomeExpense(
                  icon: Icons.arrow_upward,
                  label: 'Expenses',
                  amount: _monthlyExpenses,
                  isIncome: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Income',
            '\$${_monthlyIncome.toStringAsFixed(2)}',
            Icons.arrow_upward,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Expenses',
            '\$${_monthlyExpenses.toStringAsFixed(2)}',
            Icons.arrow_downward,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String amount, IconData icon, Color color) {
    return Card(
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
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
    );
  }

  Widget _buildTransactionsList() {
    if (_recentTransactions.isEmpty) {
      return const Center(
        child: Text('No recent transactions'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _recentTransactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isDeposit = transaction.type == TransactionType.deposit;
    final icon = isDeposit ? Icons.arrow_downward : Icons.arrow_upward;
    final color = isDeposit ? Colors.green : Colors.red;
    final amountText = '\$${transaction.amount.abs().toStringAsFixed(2)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          amountText,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickAction(
          icon: Icons.add,
          label: 'Add Money',
          onTap: () {
            // TODO: Implement add money
          },
        ),
        _buildQuickAction(
          icon: Icons.arrow_upward,
          label: 'Withdraw',
          onTap: () {
            // TODO: Implement withdraw
          },
        ),
        _buildQuickAction(
          icon: Icons.history,
          label: 'History',
          onTap: () {
            // TODO: Navigate to history
          },
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpense({
    required IconData icon,
    required String label,
    required double amount,
    required bool isIncome,
  }) {
    final color = isIncome ? Colors.green : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // TODO: Replace with actual API calls
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _totalBalance = 12500.0;
          _monthlyIncome = 4500.0;
          _monthlyExpenses = 2300.0;
          _recentTransactions.clear();
          _recentTransactions.addAll([
            Transaction(
              id: '1',
              userId: 'current_user_id',
              type: TransactionType.deposit,
              amount: 1000.0,
              description: 'Salary',
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
              updatedAt: DateTime.now(),
              status: TransactionStatus.completed,
              currency: 'IDR',
            ),
            Transaction(
              id: '2',
              userId: 'current_user_id',
              type: TransactionType.withdrawal,
              amount: 300.0,
              description: 'Grocery Shopping',
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
              updatedAt: DateTime.now(),
              status: TransactionStatus.completed,
              currency: 'IDR',
            ),
          ]);
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
}
