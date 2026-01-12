import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../widgets/transaction_tile.dart';
import '../models/account.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Account? _currentAccount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    _currentAccount = await StorageService.getCurrentAccount();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var transactions = [];

    if (_currentAccount != null) {
      // Sort transactions by timestamp in descending order (most recent first)
      transactions = _currentAccount!.transactions.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Histórico", style: const TextStyle(fontSize: 24)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentAccount == null || _currentAccount!.transactions.isEmpty
          ? const Center(
              child: Text("Nenhuma transação encontrada para esta conta."),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (_, i) => TransactionTile(transactions[i]),
            ),
    );
  }
}
