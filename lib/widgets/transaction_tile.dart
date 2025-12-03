import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final AppTransaction t;
  const TransactionTile(this.t, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = t.value >= 0 ? Colors.green : Colors.red;
    final sign = t.value >= 0 ? '+' : '-';

    return ListTile(
      leading: CircleAvatar(child: Text(sign)),
      title: Text(
        "$sign R\$ ${t.value.abs().toStringAsFixed(2)}",
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(t.timestamp.toString().split('.')[0]),
      trailing: Text("R\$ ${t.balanceAfter.toStringAsFixed(2)}"),
    );
  }
}
