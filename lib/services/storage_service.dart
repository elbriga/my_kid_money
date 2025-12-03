import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const _balanceKey = 'balance';
  static const _transactionsKey = 'transactions';
  static const _configFileName = 'conta_infantil_config.json';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setDouble(_balanceKey, _prefs.getDouble(_balanceKey) ?? 0.0);
    _prefs.setStringList(
      _transactionsKey,
      _prefs.getStringList(_transactionsKey) ?? [],
    );
  }

  static double getBalance() => _prefs.getDouble(_balanceKey) ?? 0.0;

  static Future<void> setBalance(double v) async =>
      _prefs.setDouble(_balanceKey, v);

  static List<AppTransaction> getTransactions() {
    final list = _prefs.getStringList(_transactionsKey) ?? [];
    return list.map((e) => AppTransaction.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<void> addTransaction(AppTransaction t) async {
    final list = _prefs.getStringList(_transactionsKey) ?? [];
    list.add(jsonEncode(t.toJson()));
    await _prefs.setStringList(_transactionsKey, list);
    await setBalance(t.balanceAfter);
  }

  /// Returns the File used for app configuration (child name etc.).
  static Future<File> getConfigFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_configFileName');
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('{}');
    }
    return file;
  }
}
