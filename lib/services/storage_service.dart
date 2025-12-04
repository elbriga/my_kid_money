import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const _balanceKey = 'balance';
  static const _transactionsKey = 'transactions';
  static const _childNameKey = 'childName';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setDouble(_balanceKey, _prefs.getDouble(_balanceKey) ?? 0.0);
    _prefs.setStringList(
      _transactionsKey,
      _prefs.getStringList(_transactionsKey) ?? [],
    );
    _prefs.setString(_childNameKey, _prefs.getString(_childNameKey) ?? '');
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

  static String getChildName() => _prefs.getString(_childNameKey) ?? '';

  static Future<void> setChildName(String name) async =>
      _prefs.setString(_childNameKey, name);
}