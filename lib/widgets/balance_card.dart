import 'package:flutter/material.dart';

import '../theme/colors.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String? icon;
  const BalanceCard({super.key, required this.balance, this.icon});

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final iconPath = 'assets/icon/${icon == null ? 'icon' : icon!}.png';

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: isPositive
              ? AppColors.primaryGradient
              : LinearGradient(
                  colors: [AppColors.error, AppColors.withdraw],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Saldo",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textOnPrimary.withAlpha(230),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "R\$ ${balance.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                      fontSize: 32,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Image.asset(iconPath, width: 64, height: 64),
            ],
          ),
        ),
      ),
    );
  }
}
