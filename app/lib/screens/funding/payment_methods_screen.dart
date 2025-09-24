import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_theme.dart';
import '../../providers/funding_provider.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/funding/payment-methods';

  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      setState(() => _isLoading = true);
      final methods = await ref.read(paymentMethodsProvider.future);
      if (mounted) {
        setState(() {
          _paymentMethods = methods;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load payment methods: $e'),
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

  Future<void> _navigateToAddPaymentMethod() async {
    final result = await Navigator.pushNamed(
      context,
      '/funding/add-payment-method',
    );

    if (result == true) {
      // Refresh payment methods if a new one was added
      _loadPaymentMethods();
    }
  }

  Future<void> _deletePaymentMethod(Map<String, dynamic> method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: const Text('Are you sure you want to remove this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Implement payment method deletion
        await ref.read(fundingProvider.notifier).removePaymentMethod(method['id']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment method removed')),
          );
          _loadPaymentMethods();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove payment method: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isDefault = method['isDefault'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Payment method icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    method['type'] == 'card' ? Icons.credit_card :
                    method['type'] == 'paypal' ? Icons.payment :
                    method['type'] == 'bank' ? Icons.account_balance :
                    Icons.payment,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                // Payment method details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            method['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method['type'] == 'card'
                            ? '•••• •••• •••• ${method['last4']}'
                            : method['type'] == 'paypal'
                                ? '${method['email']}'
                                : method['type'] == 'bank'
                                    ? '••••${method['accountNumber']?.substring(method['accountNumber'].length - 4)}'
                                    : 'Payment method',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu button
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deletePaymentMethod(method);
                    } else if (value == 'set_default') {
                      // TODO: Implement set as default
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Set as default - Coming soon!')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'set_default',
                      child: ListTile(
                        leading: Icon(Icons.star_outline),
                        title: Text('Set as Default'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Remove', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
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
        title: const Text('Payment Methods'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paymentMethods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No payment methods added',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a payment method to start funding your account',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPaymentMethods,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentMethodCard(_paymentMethods[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPaymentMethod,
        icon: const Icon(Icons.add),
        label: const Text('Add Payment Method'),
      ),
    );
  }
}
