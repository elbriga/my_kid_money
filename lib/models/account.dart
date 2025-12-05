import 'package:uuid/uuid.dart';

import 'transaction.dart';

const uuid = Uuid();

class Account {
  final String id;
  String name;
  double balance;
  List<AppTransaction> transactions;
  String? imagePath;

  Account({
    String? id,
    required this.name,
    this.balance = 0.0,
    List<AppTransaction>? transactions,
    this.imagePath,
  })  : id = id ?? uuid.v4(),
        transactions = transactions ?? [];

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: json['balance'] as double,
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => AppTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'imagePath': imagePath,
    };
  }

  void addTransaction(AppTransaction transaction) {
    transactions.add(transaction);
    balance += transaction.value;
  }
}
