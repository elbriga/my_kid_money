class AppTransaction {
  final double value; // positivo=depósito, negativo=saque
  final DateTime timestamp;
  final double balanceAfter;
  final String description;

  AppTransaction({
    required this.value,
    required this.timestamp,
    required this.balanceAfter,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'balanceAfter': balanceAfter,
    'description': description,
  };

  factory AppTransaction.fromJson(Map<String, dynamic> json) => AppTransaction(
    value: json['value'],
    timestamp: DateTime.parse(json['timestamp']),
    balanceAfter: json['balanceAfter'],
    description: json['description'] ?? '',
  );
}
