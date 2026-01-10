import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';

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
        final defaultAccount = Account(name: 'Meu Cofrinho');
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
      for (final transaction in _currentAccount!.transactions)
        FlSpot(
          transaction.timestamp.millisecondsSinceEpoch.toDouble(),
          transaction.balanceAfter,
        ),
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
                          color: AppColors.primary,
                          gradient: LinearGradient(
                            colors: AppColors.chartGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color:
                                    AppColors.chartGradient[index %
                                        AppColors.chartGradient.length],
                                strokeWidth: 2,
                                strokeColor: AppColors.background,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withAlpha(77),
                                AppColors.secondary.withAlpha(26),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: spots.length > 1
                                ? (spots.last.x - spots.first.x) / 4
                                : 1,
                            getTitlesWidget: (value, meta) {
                              final timestamp =
                                  DateTime.fromMillisecondsSinceEpoch(
                                    value.toInt(),
                                  );
                              final formattedDate = DateFormat(
                                'dd/MM\nHH:mm',
                              ).format(timestamp);
                              return SideTitleWidget(
                                meta: meta,
                                // axisSide: meta.axisSide,
                                child: Text(
                                  formattedDate,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      gridData: const FlGridData(show: true),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.depositGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deposit.withAlpha(77),
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("Depositar"),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.withdrawGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.withdraw.withAlpha(77),
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("Sacar"),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.historyGradient,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.history, width: 2),
                    ),
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.history,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("Histórico"),
                    ),
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
