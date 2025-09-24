import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../constants/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/funding_provider.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  static const String routeName = '/funding/transactions';

  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  DateTimeRange? _selectedDateRange;

  final List<String> _filterOptions = [
    'All',
    'Deposit',
    'Withdrawal',
    'Profit',
    'Subscription',
    'Refund',
    'Bonus'
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() => _isLoading = true);
      final transactions = await ref.read(transactionsProvider.future);
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load transactions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        // Apply type filter
        if (_selectedFilter != 'All' &&
            transaction.type.name != _selectedFilter.toLowerCase()) {
          return false;
        }

        // Apply date range filter
        if (_selectedDateRange != null) {
          final transactionDate = transaction.createdAt;
          if (transactionDate.isBefore(_selectedDateRange!.start) ||
              transactionDate.isAfter(_selectedDateRange!.end)) {
            return false;
          }
        }

        return true;
      }).toList();

      // Sort by date (newest first)
      _filteredTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _applyFilters();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = 'All';
      _selectedDateRange = null;
      _applyFilters();
    });
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type != TransactionType.withdrawal &&
        transaction.type != TransactionType.subscription;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isIncome ? AppTheme.successColor : AppTheme.errorColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${transaction.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(transaction.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isIncome ? '+' : '-',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                  ),
                  Text(
                    '\$${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (transaction.metadata != null && transaction.metadata!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Details',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTextColor,
              ),
            ),
            const SizedBox(height: 4),
            ...transaction.metadata!.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        '${entry.key}:',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'filters') {
                _showFilterDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filters',
                child: ListTile(
                  leading: Icon(Icons.filter_list),
                  title: Text('Filters'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters summary
          if (_selectedFilter != 'All' || _selectedDateRange != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedFilter != 'All')
                          Text('Filter: $_selectedFilter'),
                        if (_selectedDateRange != null)
                          Text(
                            'Date: ${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_selectedDateRange!.end)}',
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            return _buildTransactionItem(_filteredTransactions[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Transactions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type filter
              DropdownButtonFormField<String>(
                value: _selectedFilter,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                ),
                items: _filterOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date range picker
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _selectDateRange();
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDateRange == null
                      ? 'Select Date Range'
                      : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_selectedDateRange!.end)}',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _applyFilters();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
