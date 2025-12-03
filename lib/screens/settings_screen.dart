import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = TextEditingController();
  String? _currentName;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final file = await StorageService.getConfigFile();
    if (!await file.exists()) return;

    final map = jsonDecode(await file.readAsString());
    setState(() => _currentName = map['childName']);
    _controller.text = _currentName ?? '';
  }

  Future<void> _save() async {
    final file = await StorageService.getConfigFile();
    final map = {'childName': _controller.text};
    await file.writeAsString(jsonEncode(map));
    if (mounted) Navigator.pop(context);
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
          ],
        ),
      ),
    );
  }
}
