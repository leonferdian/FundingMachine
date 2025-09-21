import 'package:flutter/material.dart';

class IncomeExpenseCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final bool isIncome;
  final bool isLoading;

  const IncomeExpenseCard({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.isIncome,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? Colors.green : Colors.red;
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const LinearProgressIndicator()
            else
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
