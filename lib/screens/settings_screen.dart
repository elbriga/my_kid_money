import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/account.dart';
import '../services/biometric_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final Account account;

  const SettingsScreen({super.key, required this.account});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.account.name;
    _imagePath = widget.account.imagePath;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _save() async {
    widget.account.name = _nameController.text;
    widget.account.imagePath = _imagePath;
    await StorageService.updateAccount(widget.account);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta atualizada com sucesso!')),
      );
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
      appBar: AppBar(title: const Text('Configurações da Conta')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imagePath != null ? FileImage(File(_imagePath!)) : null,
                child: _imagePath == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome da Conta'),
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