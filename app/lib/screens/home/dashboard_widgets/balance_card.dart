import 'package:flutter/material.dart';
import '../../../constants/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final bool isLoading;
  final VoidCallback onRefresh;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Balance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: isLoading ? null : onRefresh,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const LinearProgressIndicator()
            else
              Text(
                '\$${balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
