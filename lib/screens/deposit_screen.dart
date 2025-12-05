import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../models/account.dart';
import '../services/biometric_service.dart';
import '../services/storage_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final controllerValor = TextEditingController();
  final controllerDescricao = TextEditingController();
  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> doDeposit() async {
    final value = double.tryParse(controllerValor.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      showMsg("Valor inválido");
      return;
    }
    final desc = controllerDescricao.text;

    final ok = await BiometricService.authenticate("Confirme para depositar");
    if (!ok) {
      showMsg("Falha na autenticação");
      return;
    }

    Account? currentAccount = await StorageService.getCurrentAccount();
    if (currentAccount == null) {
      showMsg(
        "Nenhuma conta selecionada. Por favor, selecione ou crie uma conta.",
      );
      return;
    }

    // Play feedback
    _confettiController.play();
    _audioPlayer.play(AssetSource('audio/deposit.mp3'));

    final newBalance = currentAccount.balance + value;

    final newTransaction = AppTransaction(
      value: value,
      timestamp: DateTime.now(),
      balanceAfter: newBalance,
      description: desc,
    );

    currentAccount.addTransaction(newTransaction);
    await StorageService.updateAccount(currentAccount);

    // Wait a bit for the user to see the animation
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text("Depositar")),
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
                TextField(
                  controller: controllerDescricao,
                  decoration: const InputDecoration(
                    labelText: "Descrição (opcional)",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: doDeposit,
                  child: const Text("Confirmar"),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }
}
