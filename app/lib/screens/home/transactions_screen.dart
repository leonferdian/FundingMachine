import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_theme.dart';
import '../../models/transaction_model.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // Mock data - replace with actual API calls
  final List<Transaction> _transactions = [];
  final List<String> _filterOptions = ['All', 'Income', 'Expense'];
  String _selectedFilter = 'All';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    // TODO: Replace with actual API calls
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _transactions.addAll([
        Transaction(
          id: '1',
          userId: 'user1',
          type: TransactionType.subscription,
          status: TransactionStatus.completed,
          amount: 150.00,
          currency: 'USD',
          description: 'Netflix Subscription',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Transaction(
          id: '2',
          userId: 'user1',
          type: TransactionType.deposit,
          status: TransactionStatus.completed,
          amount: 2000.00,
          currency: 'USD',
          description: 'Freelance Work',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Transaction(
          id: '3',
          userId: 'user1',
          type: TransactionType.withdrawal,
          status: TransactionStatus.completed,
          amount: 45.75,
          currency: 'USD',
          description: 'Grocery Store',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          completedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Transaction(
          id: '4',
          userId: 'user1',
          type: TransactionType.subscription,
          status: TransactionStatus.completed,
          amount: 25.99,
          currency: 'USD',
          description: 'Spotify Premium',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
          completedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        Transaction(
          id: '5',
          userId: 'user1',
          type: TransactionType.deposit,
          status: TransactionStatus.completed,
          amount: 1500.00,
          currency: 'USD',
          description: 'Salary',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
          completedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ]);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // TODO: Filter transactions by selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and date selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Filter chips
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filterOptions.map((option) {
                        final isSelected = _selectedFilter == option;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(option),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = option;
                                // TODO: Apply filter
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Date picker
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 20),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),
          
          // Transactions list
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Text('No transactions found'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return _buildTransactionItem(transaction);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add transaction screen
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isExpense = transaction.type == TransactionType.withdrawal || 
                     transaction.type == TransactionType.subscription;
    final amountColor = isExpense ? AppTheme.errorColor : AppTheme.successColor;
    final icon = isExpense ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown;
    final formattedDate = '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: amountColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: amountColor,
            size: 16,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
        subtitle: Text(
          '$formattedDate • ${transaction.metadata?['category'] ?? 'Uncategorized'}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'}\$${transaction.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: amountColor,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // TODO: Navigate to transaction details
        },
      ),
    );
  }
}
