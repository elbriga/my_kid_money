import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/account.dart';

const _uuid = Uuid();

class StorageService {
  static late SharedPreferences _prefs;

  static const _accountsListKey = 'accountsList';
  static const _currentAccountIdKey = 'currentAccountId';
  static const _childNameKey = 'childName'; // Still global for now

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Initialize accounts if they don't exist
    if (!_prefs.containsKey(_accountsListKey)) {
      final defaultAccount = Account(name: 'Minha Conta Principal');
      await _saveAllAccounts([defaultAccount]);
      await _prefs.setString(_currentAccountIdKey, defaultAccount.id);
    }
    _prefs.setString(_childNameKey, _prefs.getString(_childNameKey) ?? '');
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
}
