import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/storage_service.dart';
import '../models/transaction.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final controller = TextEditingController();

  void showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> doWithdraw() async {
    final value = double.tryParse(controller.text.replaceAll(',', '.'));
    if (value == null || value <= 0) return showMsg("Valor inválido");

    final current = StorageService.getBalance();
    if (value > current) return showMsg("Saldo insuficiente");

    final ok = await BiometricService.authenticate("Confirme para sacar");
    if (!ok) return showMsg("Falha na autenticação");

    final newBalance = current - value;

    await StorageService.addTransaction(
      AppTransaction(
        value: -value,
        timestamp: DateTime.now(),
        balanceAfter: newBalance,
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sacar")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Valor"),
            ),
            const SizedBox(height: 16),
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
