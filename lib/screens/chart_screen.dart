import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/storage_service.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = StorageService.getTransactions().reversed.toList();

    final spots = [
      for (int i = 0; i < tx.length; i++)
        FlSpot(i.toDouble(), tx[i].balanceAfter),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Gráfico de Saldo")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            lineBarsData: [LineChartBarData(spots: spots, isCurved: true)],
            gridData: FlGridData(show: true),
          ),
        ),
      ),
    );
  }
}
