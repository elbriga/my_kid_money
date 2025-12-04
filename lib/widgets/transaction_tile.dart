import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final AppTransaction t;
  const TransactionTile(this.t, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = t.value >= 0 ? Colors.green : Colors.red;
    final sign = t.value >= 0 ? '+' : '-';
    final desc = t.description != ''
        ? t.description
        : (sign == '+' ? 'Depósito' : 'Saque');

    // Format date - should use de intl package!
    String data = t.timestamp.toString().split('.')[0];
    String hora = data.split(' ')[1];
    data = data.split(' ')[0];
    String year = data.split('-')[0];
    String month = data.split('-')[1];
    String day = data.split('-')[2];

    data = "$day/$month/$year $hora";

    return ListTile(
      leading: CircleAvatar(child: Text(sign)),
      title: Text(
        "$sign R\$ ${t.value.abs().toStringAsFixed(2)}",
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(desc),
      trailing: Text("R\$ ${t.balanceAfter.toStringAsFixed(2)}\n$data"),
    );
  }
}
