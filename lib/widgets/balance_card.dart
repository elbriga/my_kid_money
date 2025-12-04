import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Saldo", style: TextStyle(fontSize: 18)),
                Text(
                  "R\$ ${balance.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 26,
                  ),
                ),
              ],
            ),
            const Icon(Icons.savings, size: 40),
          ],
        ),
      ),
    );
  }
}
