import 'package:flutter/material.dart';
import 'package:my_kid_money/widgets/balance_card.dart';
import '../services/storage_service.dart';
import '../models/transaction.dart';
import '../models/account.dart'; // Added this import

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final controllerValor = TextEditingController();
  final controllerDescricao = TextEditingController();

  Account? _currentAccount;
  bool _isLoading = true;

  void showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _currentAccount = await StorageService.getCurrentAccount();
    } catch (e) {
      showMsg("Erro ao carregar conta");
      _currentAccount = null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> doWithdraw() async {
    final value = double.tryParse(controllerValor.text.replaceAll(',', '.'));
    if (value == null || value <= 0) return showMsg("Valor inválido");

    final currentAccount = await StorageService.getCurrentAccount();
    if (currentAccount == null) {
      showMsg(
        "Nenhuma conta selecionada. Por favor, selecione ou crie uma conta.",
      );
      return;
    }

    if (currentAccount.password?.isNotEmpty == true) {
      _showPasswordDialog(value, currentAccount);
    } else {
      _performWithdrawal(value, currentAccount);
    }
  }

  Future<void> _showPasswordDialog(double value, Account currentAccount) async {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Digite a senha'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Senha'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text.isEmpty) {
                  showMsg('Por favor, digite a senha');
                  return;
                }
                if (passwordController.text ==
                    (currentAccount.password ?? '')) {
                  Navigator.pop(context);
                  _performWithdrawal(value, currentAccount);
                } else {
                  showMsg('Senha incorreta');
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performWithdrawal(double value, Account currentAccount) async {
    final desc = controllerDescricao.text;

    if (value > currentAccount.balance) return showMsg("Saldo insuficiente");

    final newBalance = currentAccount.balance - value;

    final newTransaction = AppTransaction(
      value: -value, // Withdrawal is a negative value
      timestamp: DateTime.now(),
      balanceAfter: newBalance,
      description: desc,
    );

    currentAccount.addTransaction(newTransaction);
    await StorageService.updateAccount(currentAccount);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Sacar")),
        backgroundColor: Colors.purple[50],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentAccount == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Sacar")),
        backgroundColor: Colors.purple[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Não foi possível carregar a conta.'),
              ElevatedButton(
                onPressed: () {
                  _loadAccount();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sacar")),
      backgroundColor: Colors.purple[50],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BalanceCard(balance: _currentAccount!.balance),
            const SizedBox(height: 16),
            Image.asset('assets/icon/cifrao.png', height: 120, width: 120),
            const SizedBox(height: 16),
            TextField(
              controller: controllerValor,
              decoration: const InputDecoration(labelText: "Valor"),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controllerDescricao,
              decoration: const InputDecoration(
                labelText: "Descrição (opcional)",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: doWithdraw,
              child: const Text("Confirmar"),
            ),
          ],
        ),
      ),
    );
  }
}
