import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/account.dart';
import '../models/transaction.dart';

class StorageService {
  static const _currentAccountIdKey = 'currentAccountId';
  static const _childNameKey = 'childName';
  static final Map<String, Set<String>> _persistedTransactionIds = {};

  static DocumentReference<Map<String, dynamic>> get _userDocument {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('É necessário entrar para acessar os dados.');
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  static CollectionReference<Map<String, dynamic>> get _accountsCollection =>
      _userDocument.collection('accounts');

  static Future<void> init() async {
    final accounts = await _loadAllAccounts();
    if (accounts.isEmpty) {
      final defaultAccount = Account(name: 'Meu Cofrinho');
      await addAccount(defaultAccount);
      await setCurrentAccountId(defaultAccount.id);
    } else {
      final currentAccountId = await getCurrentAccountId();
      if (currentAccountId == null ||
          !accounts.any((account) => account.id == currentAccountId)) {
        await setCurrentAccountId(accounts.first.id);
      }
    }

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

  static Future<Account> _loadAccount(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final transactionSnapshot = await document.reference
        .collection('transactions')
        .orderBy('timestamp')
        .get();
    final transactionIds = transactionSnapshot.docs
        .map((transaction) => transaction.id)
        .toSet();
    _persistedTransactionIds[document.id] = transactionIds;

    final transactions = transactionSnapshot.docs.map((transaction) {
      final data = transaction.data();
      final timestamp = data['timestamp'];
      return <String, dynamic>{
        ...data,
        'id': transaction.id,
        'timestamp': timestamp is Timestamp
            ? timestamp.toDate().toIso8601String()
            : timestamp as String,
      };
    }).toList();

    return Account.fromJson({
      ...document.data()!,
      'id': document.id,
      'transactions': transactions,
    });
  }

  static Future<List<Account>> _loadAllAccounts() async {
    final snapshot = await _accountsCollection.get();
    return Future.wait(snapshot.docs.map(_loadAccount));
  }

  static Future<void> _saveAccount(Account account) async {
    final accountData = account.toJson()..remove('transactions');
    await _accountsCollection.doc(account.id).set(accountData);

    final persistedIds = _persistedTransactionIds.putIfAbsent(
      account.id,
      () => <String>{},
    );
    final transactions = _accountsCollection
        .doc(account.id)
        .collection('transactions');
    for (final transaction in account.transactions) {
      if (persistedIds.contains(transaction.id)) continue;
      await transactions.doc(transaction.id).set({
        'value': transaction.value,
        'description': transaction.description,
        'balanceAfter': transaction.balanceAfter,
        'timestamp': Timestamp.fromDate(transaction.timestamp),
      });
      persistedIds.add(transaction.id);
    }
  }

  static Future<void> addAccount(Account account) async {
    await _saveAccount(account);
  }

  static Future<void> updateAccount(Account updatedAccount) async {
    await _saveAccount(updatedAccount);
  }

  static Future<void> deleteAccount(String accountId) async {
    final currentAccountId = await getCurrentAccountId();
    final accountReference = _accountsCollection.doc(accountId);
    final transactions = await accountReference
        .collection('transactions')
        .get();
    for (final transaction in transactions.docs) {
      await transaction.reference.delete();
    }
    await accountReference.delete();
    _persistedTransactionIds.remove(accountId);

    if (currentAccountId == accountId) {
      final accounts = await _loadAllAccounts();
      if (accounts.isNotEmpty) {
        await setCurrentAccountId(accounts.first.id);
      } else {
        await _userDocument.set({
          _currentAccountIdKey: FieldValue.delete(),
        }, SetOptions(merge: true));
      }
    }
  }

  static Future<List<Account>> getAccounts() async {
    return await _loadAllAccounts();
  }

  static Future<Account?> getAccount(String accountId) async {
    final snapshot = await _accountsCollection.doc(accountId).get();
    if (!snapshot.exists) return null;
    return _loadAccount(snapshot);
  }

  static Future<void> setCurrentAccountId(String accountId) async {
    await _userDocument.set({
      _currentAccountIdKey: accountId,
    }, SetOptions(merge: true));
  }

  static Future<String?> getCurrentAccountId() async {
    final snapshot = await _userDocument.get();
    return snapshot.data()?[_currentAccountIdKey] as String?;
  }

  static Future<Account?> getCurrentAccount() async {
    final currentAccountId = await getCurrentAccountId();
    if (currentAccountId == null) {
      return null;
    }
    return getAccount(currentAccountId);
  }

  static Future<String> getChildName() async {
    final snapshot = await _userDocument.get();
    return snapshot.data()?[_childNameKey] as String? ?? '';
  }

  static Future<void> setChildName(String name) async {
    await _userDocument.set({_childNameKey: name}, SetOptions(merge: true));
  }

  static Future<void> clearAllAccountsData() async {
    final accounts = await _loadAllAccounts();
    for (final account in accounts) {
      await deleteAccount(account.id);
    }
    await init();
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
