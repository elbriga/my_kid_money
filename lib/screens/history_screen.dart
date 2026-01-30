import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kid_money/models/transaction.dart';

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
          : Builder(
              builder: (context) {
                // Sort transactions by timestamp in descending order (most recent first)
                List<AppTransaction> transactions =
                    _currentAccount!.transactions.toList()
                      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                // Put month separators between TransactionTiles
                List<Widget> historyItems = [];
                int lastMonth = -1;
                int lastYear = 2000;
                for (var transaction in transactions) {
                  final DateTime date = transaction.timestamp;
                  if (date.month != lastMonth || date.year != lastYear) {
                    // Add separator
                    historyItems.add(
                      ListTile(
                        title: Text(
                          DateFormat('MMMM yyyy', 'pt_BR').format(date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                    lastMonth = date.month;
                    lastYear = date.year;
                  }
                  historyItems.add(TransactionTile(transaction));
                }

                return ListView.builder(
                  itemCount: historyItems.length,
                  itemBuilder: (_, i) => historyItems[i],
                );
              },
            ),
    );
  }
}
