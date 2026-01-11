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
  final _passwordController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.account.name;
    _imagePath = widget.account.imagePath;
    _passwordController.text = widget.account.password ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _save() async {
    widget.account.name = _nameController.text;
    widget.account.imagePath = _imagePath;
    widget.account.password = _passwordController.text;
    await StorageService.updateAccount(widget.account);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta atualizada com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _showAddAccountDialog() async {
    String newAccountName = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Conta'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nome da conta'),
            onChanged: (value) {
              newAccountName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newAccountName.trim().isNotEmpty) {
                  final newAccount = Account(name: newAccountName.trim());
                  await StorageService.addAccount(newAccount);
                  await StorageService.setCurrentAccountId(newAccount.id);
                  if (!context.mounted) return;
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('O nome da conta não pode ser vazio.'),
                    ),
                  );
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  void showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão de dados'),
          content: const Text('Tem certeza que deseja apagar esta conta?'),
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
        "Confirme para Apagar todos os dados",
      );
      if (!ok) return showMsg("Falha na autenticação");

      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    await StorageService.deleteAccount(widget.account.id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Conta apagada!')));
      Navigator.pop(context); // Pop back to home screen which will reinitialize
    }
  }

  @override
  Widget build(BuildContext context) {
    //StorageService.initData();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações da Conta')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imagePath != null
                      ? FileImage(File(_imagePath!))
                      : null,
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
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha de Saque'),
                keyboardType: TextInputType.number,
                obscureText: false,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Salvar')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showAddAccountDialog,
                child: const Text('Adicionar Nova Conta'),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => _confirmDeleteAccount(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Apagar Esta Conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
