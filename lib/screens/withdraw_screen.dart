import 'package:flutter/material.dart';
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

  void showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> doWithdraw() async {
    final value = double.tryParse(controllerValor.text.replaceAll(',', '.'));
    if (value == null || value <= 0) return showMsg("Valor inválido");

    final desc = controllerDescricao.text;

    Account? currentAccount = await StorageService.getCurrentAccount();
    if (currentAccount == null) {
      showMsg(
        "Nenhuma conta selecionada. Por favor, selecione ou crie uma conta.",
      );
      return;
    }

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
    return Scaffold(
      appBar: AppBar(title: const Text("Sacar")),
      backgroundColor: Colors.purple[50],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
