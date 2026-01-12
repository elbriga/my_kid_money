import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

import '../theme/colors.dart';
import '../widgets/balance_card.dart';
import '../models/transaction.dart';
import '../models/account.dart';
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

  Account? _currentAccount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccount();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    _audioPlayer = AudioPlayer();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _currentAccount = await StorageService.getCurrentAccount();
    } catch (e) {
      showMsg("Erro ao carregar conta: $e");
      _currentAccount = null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          appBar: AppBar(
            title: const Text("Depositar", style: TextStyle(fontSize: 24)),
          ),
          backgroundColor: Colors.purple[50],
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentAccount == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Não foi possível carregar a conta.'),
                      ElevatedButton(
                        onPressed: _loadAccount,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      BalanceCard(balance: _currentAccount!.balance),
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
                        onPressed: doDeposit,
                        child: const Text("Confirmar"),
                      ),
                    ],
                  ),
                ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: AppColors.confettiColors,
          ),
        ),
      ],
    );
  }
}
