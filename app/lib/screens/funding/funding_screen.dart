import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_theme.dart';
import '../../../models/funding_platform_model.dart';
import '../../../providers/funding_provider.dart';

class FundingScreen extends ConsumerStatefulWidget {
  const FundingScreen({super.key});

  @override
  ConsumerState<FundingScreen> createState() => _FundingScreenState();
}

class _FundingScreenState extends ConsumerState<FundingScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fundingPlatformsProvider.future);
      ref.read(paymentMethodsProvider.future);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Funds'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPlatformSelection(theme),
            const SizedBox(height: 24),
            _buildAmountInput(theme),
            const SizedBox(height: 24),
            _buildPaymentMethodSelection(theme),
            const SizedBox(height: 32),
            _buildSubmitButton(theme),
            const SizedBox(height: 32),
            _buildTransactionHistory(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Platform',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final platformsAsync = ref.watch(fundingPlatformsProvider);
            final selectedPlatform = ref.watch(selectedPlatformProvider);
            
            return platformsAsync.when(
              data: (platforms) => platforms.isEmpty
                  ? _buildEmptyState('No platforms available')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: platforms.map((platform) {
                        final isSelected = selectedPlatform?.id == platform.id;
                        return _PlatformChip(
                          platform: platform,
                          isSelected: isSelected,
                          onSelected: (selected) {
                            ref.read(selectedPlatformProvider.notifier).state = 
                                selected ? platform : null;
                          },
                        );
                      }).toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(error.toString()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountInput(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: '0.00',
              filled: true,
              fillColor: theme.cardColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [10, 50, 100, 200].map((amount) {
              return InputChip(
                label: Text('\$$amount'),
                onSelected: (_) {
                  _amountController.text = amount.toString();
                },
                backgroundColor: theme.cardColor,
                selectedColor: theme.primaryColor.withOpacity(0.2),
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final paymentMethodsAsync = ref.watch(paymentMethodsProvider);
            final selectedMethod = ref.watch(selectedPaymentMethodProvider);
            
            return paymentMethodsAsync.when(
              data: (methods) => methods.isEmpty
                  ? _buildEmptyState('No payment methods')
                  : Column(
                      children: methods.map((method) {
                        final isSelected = selectedMethod?['id'] == method['id'];
                        return Card(
                          elevation: 0,
                          color: isSelected
                              ? theme.primaryColor.withOpacity(0.1)
                              : theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.primaryColor
                                  : theme.dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: SvgPicture.asset(
                              _getPaymentMethodIcon(method['type'] ?? ''),
                              width: 32,
                              height: 32,
                            ),
                            title: Text(method['name'] ?? ''),
                            subtitle: Text(
                              '•••• ${method['last4'] ?? ''}',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: theme.primaryColor,
                                  )
                                : null,
                            onTap: () {
                              ref.read(selectedPaymentMethodProvider.notifier).state =
                                  isSelected ? null : method;
                            },
                          ),
                        );
                      }).toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(error.toString()),
            );
          },
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            // TODO: Implement add payment method
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Payment Method'),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState?.validate() ?? false) {
          final amount = double.tryParse(_amountController.text) ?? 0;
          final platform = ref.read(selectedPlatformProvider);
          final paymentMethod = ref.read(selectedPaymentMethodProvider);
          
          if (platform == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a platform')),
            );
            return;
          }
          
          if (paymentMethod == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a payment method')),
            );
            return;
          }

          try {
            // TODO: Process transaction
            await Future.delayed(const Duration(seconds: 2)); // Simulate API call
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction successful!'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Reset form
              _amountController.clear();
              ref.read(selectedPlatformProvider.notifier).state = null;
              ref.read(selectedPaymentMethodProvider.notifier).state = null;
              
              // Refresh data
              ref.invalidate(fundingPlatformsProvider);
              ref.invalidate(paymentMethodsProvider);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Add Funds',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTransactionHistory(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full transaction history
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // TODO: Replace with actual transaction list
        _buildTransactionList(theme),
      ],
    );
  }

  Widget _buildTransactionList(ThemeData theme) {
    // Mock data - replace with actual data from your API
    final mockTransactions = [
      {
        'id': '1',
        'amount': 100.0,
        'status': 'completed',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'platform': 'Stripe',
      },
      {
        'id': '2',
        'amount': 50.0,
        'status': 'pending',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'platform': 'PayPal',
      },
    ];

    if (mockTransactions.isEmpty) {
      return _buildEmptyState('No recent transactions');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockTransactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = mockTransactions[index];
        final isCompleted = tx['status'] == 'completed';
        
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.pending,
              color: isCompleted ? Colors.green : Colors.orange,
            ),
          ),
          title: Text(
            '\$${tx['amount'].toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${tx['platform']} • ${DateFormat('MMM d, y').format(tx['date'])}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Text(
            tx['status'].toString().toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCompleted ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            'Error: $error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Retry loading data
              ref.invalidate(fundingPlatformsProvider);
              ref.invalidate(paymentMethodsProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodIcon(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return 'assets/icons/visa.svg';
      case 'mastercard':
        return 'assets/icons/mastercard.svg';
      case 'paypal':
        return 'assets/icons/paypal.svg';
      default:
        return 'assets/icons/credit_card.svg';
    }
  }
}

class _PlatformChip extends StatelessWidget {
  final FundingPlatform platform;
  final bool isSelected;
  final Function(bool) onSelected;

  const _PlatformChip({
    required this.platform,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(platform.name),
      selected: isSelected,
      onSelected: onSelected,
      avatar: platform.iconUrl != null
          ? Image.network(
              platform.iconUrl!,
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.credit_card),
            )
          : const Icon(Icons.credit_card),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).textTheme.bodyLarge?.color,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}
