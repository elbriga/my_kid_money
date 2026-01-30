import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/colors.dart';
import '../models/transaction.dart';

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
    final isMesada = desc.toLowerCase().contains("mesada");
    final isJuros = desc.toLowerCase().startsWith("juros");

    // Format date using the intl package
    final String data = DateFormat('dd/MM/yyyy HH:mm').format(t.timestamp);

    // Get a playful color based on transaction amount
    Color getTransactionColor() {
      if (isMesada) {
        return AppColors.primary;
      } else if (isJuros) {
        return AppColors.interests;
      } else if (isDeposit) {
        // Use gradient of greens based on amount
        final amount = t.value.abs();
        if (amount < 100) return AppColors.deposit.withAlpha(179);
        if (amount < 600) return AppColors.deposit;
        if (amount < 700) return AppColors.success;
        return AppColors.highDollar;
      } else {
        // Use gradient of oranges/reds based on amount
        final amount = t.value.abs();
        if (amount < 30) return AppColors.withdraw.withAlpha(179);
        if (amount < 100) return AppColors.withdraw;
        if (amount < 400) return AppColors.warning;
        return AppColors.error;
      }
    }

    final transactionColor = getTransactionColor();

    Color getTileColor() {
      // TODO :: add to AppColors
      return isJuros
          ? Colors.yellow.shade100
          : isDeposit
          ? Colors.green.shade100
          : Colors.red.shade100;
    }

    final tileColor = getTileColor();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: tileColor,
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
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "$sign R\$ ${t.value.abs().toStringAsFixed(2)}",
          style: TextStyle(
            color: transactionColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(desc, style: TextStyle(color: AppColors.textSecondary)),
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
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
            ),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
