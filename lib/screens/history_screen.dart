import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/transaction_tile.dart';
import 'chart_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = StorageService.getTransactions();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico"),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChartScreen()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tx.length,
        itemBuilder: (_, i) => TransactionTile(tx[i]),
      ),
    );
  }
}
