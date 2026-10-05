import 'package:uuid/uuid.dart';

const _transactionUuid = Uuid();

class AppTransaction {
  final String id;
  final double value; // positivo=depósito, negativo=saque
  final DateTime timestamp;
  final double balanceAfter;
  final String description;

  AppTransaction({
    String? id,
    required this.value,
    required this.timestamp,
    required this.balanceAfter,
    required this.description,
  }) : id = id ?? _transactionUuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'balanceAfter': balanceAfter,
    'description': description,
  };

  factory AppTransaction.fromJson(Map<String, dynamic> json) => AppTransaction(
    id: json['id'] as String?,
    value: (json['value'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp']),
    balanceAfter: (json['balanceAfter'] as num).toDouble(),
    description: json['description'] ?? '',
  );
}
