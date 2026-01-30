import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';
import '../models/transaction.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const _accountsListKey = 'accountsList';
  static const _currentAccountIdKey = 'currentAccountId';
  static const _childNameKey = 'childName'; // Still global for now

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Initialize accounts if they don't exist
    if (!_prefs.containsKey(_accountsListKey)) {
      final defaultAccount = Account(name: 'Meu Cofrinho');
      await _saveAllAccounts([defaultAccount]);
      await _prefs.setString(_currentAccountIdKey, defaultAccount.id);
    }
    _prefs.setString(_childNameKey, _prefs.getString(_childNameKey) ?? '');

    final accounts = await _loadAllAccounts();
    for (final account in accounts) {
      await _applyInterest(account);
    }
  }

  static Future<void> _applyInterest(Account account) async {
    if (account.tax == null || account.tax! <= 0) {
      return;
    }

    final now = DateTime.now();
    DateTime lastInterestDate = account.lastInterestDate ?? now;

    // Loop through each month since the last interest application
    while (lastInterestDate.year < now.year ||
        (lastInterestDate.year == now.year &&
            lastInterestDate.month < now.month)) {
      // Calculate interest for one month
      final interest = account.balance * (account.tax! / 100);

      // Move to the next month
      lastInterestDate = DateTime(
        lastInterestDate.year,
        lastInterestDate.month + 1,
        1,
        0,
        0,
        0,
      );

      // Create a new transaction for the interest
      final newTransaction = AppTransaction(
        value: interest,
        description:
            'Juros ${account.tax} % ${DateFormat('MMMM yyyy', 'pt_BR').format(lastInterestDate)}',
        balanceAfter: account.balance + interest,
        timestamp: lastInterestDate,
      );

      // Add the transaction and update the account's last interest date
      account.addTransaction(newTransaction);
      account.lastInterestDate = lastInterestDate;
    }

    // Save the updated account
    await updateAccount(account);
  }

  static Future<List<Account>> _loadAllAccounts() async {
    final accountsJson = _prefs.getStringList(_accountsListKey) ?? [];
    return accountsJson
        .map((json) => Account.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> _saveAllAccounts(List<Account> accounts) async {
    final accountsJson = accounts
        .map((account) => jsonEncode(account.toJson()))
        .toList();
    await _prefs.setStringList(_accountsListKey, accountsJson);
  }

  static Future<void> addAccount(Account account) async {
    final accounts = await _loadAllAccounts();
    accounts.add(account);
    await _saveAllAccounts(accounts);
  }

  static Future<void> updateAccount(Account updatedAccount) async {
    final accounts = await _loadAllAccounts();
    final index = accounts.indexWhere(
      (account) => account.id == updatedAccount.id,
    );
    if (index != -1) {
      accounts[index] = updatedAccount;
      await _saveAllAccounts(accounts);
    }
  }

  static Future<void> deleteAccount(String accountId) async {
    List<Account> accounts = await _loadAllAccounts();
    accounts.removeWhere((account) => account.id == accountId);
    await _saveAllAccounts(accounts);

    // If the deleted account was the current one, select another or clear current
    if (_prefs.getString(_currentAccountIdKey) == accountId) {
      if (accounts.isNotEmpty) {
        await setCurrentAccountId(accounts.first.id);
      } else {
        await _prefs.remove(_currentAccountIdKey);
      }
    }
  }

  static Future<List<Account>> getAccounts() async {
    return await _loadAllAccounts();
  }

  static Future<Account?> getAccount(String accountId) async {
    final accounts = await _loadAllAccounts();
    return accounts.firstWhere((account) => account.id == accountId);
  }

  static Future<void> setCurrentAccountId(String accountId) async {
    await _prefs.setString(_currentAccountIdKey, accountId);
  }

  static String? getCurrentAccountId() {
    return _prefs.getString(_currentAccountIdKey);
  }

  static Future<Account?> getCurrentAccount() async {
    final currentAccountId = getCurrentAccountId();
    if (currentAccountId == null) {
      return null;
    }
    return getAccount(currentAccountId);
  }

  static String getChildName() => _prefs.getString(_childNameKey) ?? '';

  static Future<void> setChildName(String name) async =>
      _prefs.setString(_childNameKey, name);

  static Future<void> clearAllAccountsData() async {
    await _prefs.remove(_accountsListKey);
    await _prefs.remove(_currentAccountIdKey);
    // Optionally clear childName as well if it's tied to account data
    // await _prefs.remove(_childNameKey);
    await init(); // Reinitialize with a default account
  }

  static Future<void> initData() async {
    final account = await getCurrentAccount();
    if (account == null) {
      return;
    }

    final transactions = [
      [600.0, '2025-12-05 20:55', 'cache shopping São José'],
      [100.0, '2025-12-06 21:00', 'mesada dezembro'],
      [100.0, '2025-12-15 13:10', 'da vovó'],
      [16.0, '2026-01-01 00:00', 'Juros 2.0 % janeiro 2026'],
      [100.0, '2026-01-08 20:53', 'mesada janeiro'],
      [700.0, '2026-01-10 14:30', 'Cache natal ssj 2'],
      [-25.0, '2026-01-11 17:11', 'sorvete Lálika'],
    ];

    var balance = 0.0;
    for (var transaction in transactions) {
      var value = transaction[0] as double;
      balance += value;

      final newTransaction = AppTransaction(
        value: value,
        timestamp: DateTime.parse('${transaction[1]}:00'),
        balanceAfter: balance,
        description: transaction[2] as String,
      );

      account.addTransaction(newTransaction);
    }

    await StorageService.updateAccount(account);
  }
}
