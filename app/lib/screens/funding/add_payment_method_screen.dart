import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_theme.dart';
import '../../providers/funding_provider.dart';

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  static const String routeName = '/funding/add-payment-method';

  const AddPaymentMethodScreen({super.key});

  @override
  ConsumerState<AddPaymentMethodScreen> createState() =>
      _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends ConsumerState<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();

  bool _isSaving = false;
  String _selectedType = 'card';

  final List<Map<String, dynamic>> _paymentTypes = [
    {'value': 'card', 'label': 'Credit/Debit Card', 'icon': Icons.credit_card},
    {'value': 'paypal', 'label': 'PayPal', 'icon': Icons.payment},
    {'value': 'bank', 'label': 'Bank Account', 'icon': Icons.account_balance},
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final paymentMethod = {
        'type': _selectedType,
        'isDefault': false,
      };

      switch (_selectedType) {
        case 'card':
          paymentMethod.addAll({
            'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
            'expiry': _expiryController.text,
            'cvv': _cvvController.text,
            'name': _nameController.text,
            'last4': _cardNumberController.text.replaceAll(' ', '').substring(
                _cardNumberController.text.replaceAll(' ', '').length - 4),
            'brand': _detectCardBrand(_cardNumberController.text),
          });
          break;
        case 'paypal':
          paymentMethod.addAll({
            'email': _emailController.text,
            'name': _nameController.text,
          });
          break;
        case 'bank':
          paymentMethod.addAll({
            'accountNumber': _accountNumberController.text,
            'routingNumber': _routingNumberController.text,
            'name': _nameController.text,
            'bankName': 'Bank Account',
          });
          break;
      }

      await ref.read(fundingProvider.notifier).savePaymentMethod(paymentMethod);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method added successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save payment method: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _detectCardBrand(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    if (number.startsWith('3')) return 'American Express';
    if (number.startsWith('6')) return 'Discover';
    return 'Card';
  }

  String _formatCardNumber(String value) {
    // Remove all non-digits
    value = value.replaceAll(RegExp(r'\D'), '');

    // Add spaces every 4 digits
    String result = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        result += ' ';
      }
      result += value[i];
    }

    return result;
  }

  Widget _buildCardFields() {
    return Column(
      children: [
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            final cardNumber = value.replaceAll(' ', '');
            if (cardNumber.length < 13 || cardNumber.length > 19) {
              return 'Invalid card number';
            }
            return null;
          },
          onChanged: (value) {
            final formatted = _formatCardNumber(value);
            if (formatted != _cardNumberController.text) {
              _cardNumberController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'John Doe',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter cardholder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(
                  labelText: 'MM/YY',
                  hintText: '12/25',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(value)) {
                    return 'Invalid format';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value)) {
                    return 'Invalid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayPalFields() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'PayPal Email',
            hintText: 'john@example.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter PayPal email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Account Name',
            hintText: 'John Doe',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Account Holder Name',
            hintText: 'John Doe',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account holder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNumberController,
          decoration: const InputDecoration(
            labelText: 'Account Number',
            hintText: '1234567890',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            if (value.length < 8) {
              return 'Account number must be at least 8 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _routingNumberController,
          decoration: const InputDecoration(
            labelText: 'Routing Number',
            hintText: '123456789',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter routing number';
            }
            if (value.length != 9) {
              return 'Routing number must be 9 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Payment Type Selector
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Payment Method Type',
                border: OutlineInputBorder(),
              ),
              items: _paymentTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'] as String,
                  child: Row(
                    children: [
                      Icon(type['icon'] as IconData),
                      const SizedBox(width: 8),
                      Text(type['label'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Dynamic fields based on selected type
            if (_selectedType == 'card') _buildCardFields(),
            if (_selectedType == 'paypal') _buildPayPalFields(),
            if (_selectedType == 'bank') _buildBankFields(),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _savePaymentMethod,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Payment Method',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
