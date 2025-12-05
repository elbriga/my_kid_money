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

  Future<void> _confirmClearAllAccountsData(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão de dados'),
          content: const Text(
            'Tem certeza que deseja apagar todas as contas e seus históricos de transações? Esta ação não pode ser desfeita.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Apagar Tudo'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final ok = await BiometricService.authenticate(
        "Confirme para Apagar todos os dados",
      );
      if (!ok) return showMsg("Falha na autenticação");

      await _clearAllData();
    }
  }

  Future<void> _clearAllData() async {
    await StorageService.clearAllAccountsData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas as contas e históricos apagados!')),
      );
      Navigator.pop(context); // Pop back to home screen which will reinitialize
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
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
              onPressed: () => _confirmClearAllAccountsData(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Apagar Todas as Contas e Históricos'),
            ),
          ],
        ),
      ),
    );
  }
}
