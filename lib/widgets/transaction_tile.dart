import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/colors.dart';

class TransactionTile extends StatelessWidget {
  final AppTransaction t;
  const TransactionTile(this.t, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDeposit = t.value >= 0;
    final sign = isDeposit ? '+' : '-';
    final desc = t.description != ''
        ? t.description
        : (isDeposit ? 'Depósito' : 'Saque');

    // Format date - should use de intl package!
    String data = t.timestamp.toString().split('.')[0];
    String hora = data.split(' ')[1];
    data = data.split(' ')[0];
    String year = data.split('-')[0];
    String month = data.split('-')[1];
    String day = data.split('-')[2];

    data = "$day/$month/$year $hora";

    // Get a playful color based on transaction amount
    Color getTransactionColor() {
      if (isDeposit) {
        // Use gradient of greens based on amount
        final amount = t.value.abs();
        if (amount < 10) return AppColors.deposit.withAlpha(179);
        if (amount < 50) return AppColors.deposit;
        if (amount < 100) return AppColors.success;
        return AppColors.secondary;
      } else {
        // Use gradient of oranges/reds based on amount
        final amount = t.value.abs();
        if (amount < 10) return AppColors.withdraw.withAlpha(179);
        if (amount < 50) return AppColors.withdraw;
        if (amount < 100) return AppColors.warning;
        return AppColors.error;
      }
    }

    final transactionColor = getTransactionColor();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: transactionColor.withAlpha(26),
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transactionColor.withAlpha(51),
          foregroundColor: transactionColor,
          child: Text(
            sign,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "$sign R\$ ${t.value.abs().toStringAsFixed(2)}",
          style: TextStyle(
            color: transactionColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          desc,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "R\$ ${t.balanceAfter.toStringAsFixed(2)}",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              data,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
