import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/storage_service.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../widgets/balance_card.dart';
import '../theme/colors.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final controllerValor = TextEditingController();
  final controllerDescricao = TextEditingController();
  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;

  Account? _currentAccount;
  bool _isLoading = true;

  void showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
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
      showMsg("Erro ao carregar conta");
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

  Future<void> doWithdraw() async {
    if (_currentAccount == null) {
      showMsg(
        "Nenhuma conta selecionada. Por favor, selecione ou crie uma conta.",
      );
      return;
    }

    final value = double.tryParse(controllerValor.text.replaceAll(',', '.'));
    if (value == null || value <= 0) return showMsg("Valor inválido");

    if (_currentAccount!.password?.isNotEmpty == true) {
      _showPasswordDialog(value);
    } else {
      _performWithdrawal(value);
    }
  }

  Future<void> _showPasswordDialog(double value) async {
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
                    (_currentAccount!.password ?? '')) {
                  Navigator.pop(context);
                  _performWithdrawal(value);
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

  Future<void> _performWithdrawal(double value) async {
    final desc = controllerDescricao.text;

    if (value > _currentAccount!.balance) return showMsg("Saldo insuficiente");

    // Play feedback
    _confettiController.play();
    _audioPlayer.play(AssetSource('audio/deposit.mp3'));

    final newBalance = _currentAccount!.balance - value;

    final newTransaction = AppTransaction(
      value: -value, // Withdrawal is a negative value
      timestamp: DateTime.now(),
      balanceAfter: newBalance,
      description: desc,
    );

    setState(() {
      _currentAccount!.addTransaction(newTransaction);
    });
    await StorageService.updateAccount(_currentAccount!);

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
            title: const Text("Sacar", style: TextStyle(fontSize: 24)),
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
                        onPressed: () {
                          _loadAccount();
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      BalanceCard(
                        balance: _currentAccount!.balance,
                        icon: 'cifrao',
                      ),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Confirmar"),
                            SizedBox(width: 16),
                            Icon(Icons.keyboard_alt),
                          ],
                        ),
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
