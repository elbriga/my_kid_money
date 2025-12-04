import 'package:flutter/material.dart';

import '../services/biometric_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = StorageService.getChildName();
  }

  Future<void> _save() async {
    await StorageService.setChildName(_controller.text);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nome salvo com sucesso!')));
      Navigator.pop(context);
    }
  }

  void showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _confirmClearHistory(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text(
            'Tem certeza que deseja apagar todo o histórico de transações?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final ok = await BiometricService.authenticate(
        "Confirme para Apagar os dados",
      );
      if (!ok) return showMsg("Falha na autenticação");

      await _clearHistory();
    }
  }

  Future<void> _clearHistory() async {
    await StorageService.clearTransactions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Histórico de transações apagado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Nome')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Nome da criança'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Salvar')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmClearHistory(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Limpar Histórico'),
            ),
          ],
        ),
      ),
    );
  }
}
