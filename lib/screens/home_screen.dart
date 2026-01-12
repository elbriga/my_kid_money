import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'deposit_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'withdraw_screen.dart';
import '../theme/colors.dart';
import '../models/account.dart';
import '../services/storage_service.dart';
import '../services/biometric_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/chart.dart';
import '../widgets/button.dart';

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

    Widget getHeaderItem(Account account) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (account.imagePath != null)
            CircleAvatar(backgroundImage: FileImage(File(account.imagePath!)))
          else
            const CircleAvatar(child: Icon(Icons.person)),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              account.name,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      );
    }

    Future<bool> auth(String msg) async {
      final ok = await BiometricService.authenticate(msg);
      if (!ok) {
        showMsg("Falha na autenticação");
      }
      return ok;
    }

    Future<void> gotoScreen({
      required StatefulWidget screen,
      String? authMsg,
    }) async {
      if (authMsg != null) {
        if (!await auth("Confirme para depositar")) return;
        if (!context.mounted) return;
      }
      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      _loadData();
    }

    return Scaffold(
      appBar: AppBar(
        title: _accounts.isEmpty
            ? const Text('Conta Digital')
            : _accounts.length == 1
            ? getHeaderItem(_currentAccount!)
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
                          child: getHeaderItem(account),
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
            onPressed: () => gotoScreen(
              screen: SettingsScreen(account: _currentAccount!),
              authMsg: "Confirme sua identidade!",
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => gotoScreen(screen: const HistoryScreen()),
                child: BalanceCard(balance: _currentAccount!.balance),
              ),
              const SizedBox(height: 16),
              if (spots.length > 1) Chart(spots: spots),
              Row(
                children: [
                  Button(
                    caption: 'Depositar',
                    gradient: AppColors.depositGradient,
                    onPressed: () => gotoScreen(
                      screen: const DepositScreen(),
                      authMsg: 'Confirme para depositar',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Button(
                    caption: 'Sacar',
                    gradient: AppColors.withdrawGradient,
                    onPressed: () => gotoScreen(screen: const WithdrawScreen()),
                  ),
                  const SizedBox(width: 8),
                  Button(
                    caption: 'Histórico',
                    gradient: AppColors.historyGradient,
                    onPressed: () => gotoScreen(screen: const HistoryScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
