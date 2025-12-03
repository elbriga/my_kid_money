import 'package:flutter/material.dart';

import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

import '../services/storage_service.dart';
import '../widgets/balance_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double balance = 0;

  @override
  void initState() {
    super.initState();
    balance = StorageService.getBalance();
  }

  void refresh() => setState(() => balance = StorageService.getBalance());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conta da Filha'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              refresh();
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
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DepositScreen()),
                );
                refresh();
              },
              child: const Text("Depositar"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WithdrawScreen()),
                );
                refresh();
              },
              child: const Text("Sacar"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
                refresh();
              },
              child: const Text("Histórico"),
            ),
          ],
        ),
      ),
    );
  }
}
