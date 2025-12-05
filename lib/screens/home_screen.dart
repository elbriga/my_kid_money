import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'deposit_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'withdraw_screen.dart';
import '../models/account.dart';
import '../services/storage_service.dart';
import '../services/biometric_service.dart';
import '../widgets/balance_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Account? _currentAccount;
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _accounts = await StorageService.getAccounts();
      final currentAccountId = StorageService.getCurrentAccountId();

      if (_accounts.isEmpty) {
        // This case should ideally be handled by StorageService.init()
        // but as a fallback, create a default account
        final defaultAccount = Account(name: 'Minha Conta Principal');
        await StorageService.addAccount(defaultAccount);
        await StorageService.setCurrentAccountId(defaultAccount.id);
        _accounts.add(defaultAccount);
        _currentAccount = defaultAccount;
      } else if (currentAccountId == null ||
          !_accounts.any((acc) => acc.id == currentAccountId)) {
        // If current account ID is invalid or not set, pick the first one
        await StorageService.setCurrentAccountId(_accounts.first.id);
        _currentAccount = _accounts.first;
      } else {
        _currentAccount = await StorageService.getAccount(currentAccountId);
      }
    } catch (e) {
      showMsg("Erro ao carregar dados: $e");
      _currentAccount = null; // Ensure current account is null on error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentAccount == null) {
      // Fallback if no account could be loaded/created
      return Scaffold(
        appBar: AppBar(title: const Text('Conta Digital')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Nenhuma conta encontrada.'),
              ElevatedButton(
                onPressed: () {
                  // This button should likely navigate to a dedicated "Create Account" screen
                  // or be removed if account creation is handled elsewhere.
                  // For now, it does nothing as the dialog is moved.
                },
                child: const Text('Criar nova conta'),
              ),
            ],
          ),
        ),
      );
    }

    final spots = [
      for (int i = 0; i < _currentAccount!.transactions.length; i++)
        FlSpot(i.toDouble(), _currentAccount!.transactions[i].balanceAfter),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _accounts.isEmpty
            ? const Text('Conta Digital')
            : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currentAccount!.id,
                  dropdownColor: Theme.of(context).colorScheme.primary,
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  iconEnabledColor: Theme.of(context).colorScheme.onPrimary,
                  items: _accounts
                      .map(
                        (account) => DropdownMenuItem(
                          value: account.id,
                          child: Row(
                            children: [
                              if (account.imagePath != null)
                                CircleAvatar(
                                  backgroundImage: FileImage(
                                    File(account.imagePath!),
                                  ),
                                )
                              else
                                const CircleAvatar(child: Icon(Icons.person)),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(account.name),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (accountId) async {
                    if (accountId != null) {
                      await StorageService.setCurrentAccountId(accountId);
                      _loadData();
                    }
                  },
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () async {
              final ok = await BiometricService.authenticate(
                "Confirme sua identidade!",
              );
              if (!ok) return showMsg("Falha na autenticação");

              if (!context.mounted) return;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(account: _currentAccount!),
                ),
              );

              _loadData(); // Refresh data after returning from settings
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BalanceCard(balance: _currentAccount!.balance),
            const SizedBox(height: 16),
            if (spots.length > 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Theme.of(context).colorScheme.secondary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      titlesData: const FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      gridData: const FlGridData(show: true),
                      // Optional: customize axis titles for clarity
                      // leftTitles: AxisTitles(
                      //   sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      // ),
                      // bottomTitles: AxisTitles(
                      //   sideTitles: SideTitles(showTitles: false),
                      // ),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await BiometricService.authenticate(
                        "Confirme para depositar",
                      );
                      if (!ok) {
                        showMsg("Falha na autenticação");
                        return;
                      }

                      if (!context.mounted) return;

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
                      final ok = await BiometricService.authenticate(
                        "Confirme para sacar",
                      );
                      if (!ok) {
                        showMsg("Falha na autenticação");
                        return;
                      }

                      if (!context.mounted) return;

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
