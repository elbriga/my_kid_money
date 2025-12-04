import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'deposit_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'withdraw_screen.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../widgets/balance_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double balance = 0;
  String childName = '';
  List<AppTransaction> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      balance = StorageService.getBalance();
      childName = StorageService.getChildName();
      transactions = StorageService.getTransactions().reversed.toList();
    });
  }

  String get _appBarTitle {
    if (childName.isEmpty) return 'Conta Digital';
    return 'Conta de $childName';
  }

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (int i = 0; i < transactions.length; i++)
        FlSpot(i.toDouble(), transactions[i].balanceAfter),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              _loadData();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BalanceCard(balance: balance),
            const SizedBox(height: 16),
            if (spots.length > 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(spots: spots, isCurved: true),
                      ],
                      gridData: FlGridData(show: true),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DepositScreen(),
                        ),
                      );
                      _loadData();
                    },
                    child: const Text("Depositar"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WithdrawScreen(),
                        ),
                      );
                      _loadData();
                    },
                    child: const Text("Sacar"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                      _loadData();
                    },
                    child: const Text("Histórico"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
