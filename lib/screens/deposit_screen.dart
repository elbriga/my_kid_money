import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/storage_service.dart';
import '../models/transaction.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final controller = TextEditingController();

  void showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> doDeposit() async {
    final value = double.tryParse(controller.text.replaceAll(',', '.'));
    if (value == null || value <= 0) return showMsg("Valor inválido");

    final ok = await BiometricService.authenticate("Confirme para depositar");
    if (!ok) return showMsg("Falha na autenticação");

    final current = StorageService.getBalance();
    final newBalance = current + value;

    await StorageService.addTransaction(
      AppTransaction(
        value: value,
        timestamp: DateTime.now(),
        balanceAfter: newBalance,
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Depositar")),
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
              onPressed: doDeposit,
              child: const Text("Confirmar"),
            ),
          ],
        ),
      ),
    );
  }
}
