import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/colors.dart';

class Chart extends StatelessWidget {
  const Chart({super.key, required this.spots});

  final List<FlSpot> spots;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    return LineTooltipItem(
                      NumberFormat.currency(
                        locale: 'pt_BR',
                        symbol: 'R\$',
                      ).format(touchedSpot.y),
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                gradient: LinearGradient(
                  colors: AppColors.chartGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color:
                          AppColors.chartGradient[index %
                              AppColors.chartGradient.length],
                      strokeWidth: 2,
                      strokeColor: AppColors.background,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withAlpha(77),
                      AppColors.secondary.withAlpha(26),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: spots.length > 1
                      ? (spots.last.x - spots.first.x) / 4
                      : 1,
                  getTitlesWidget: (value, meta) {
                    final timestamp = DateTime.fromMillisecondsSinceEpoch(
                      value.toInt(),
                    );
                    final formattedDate = DateFormat(
                      'dd/MM\nHH:mm',
                    ).format(timestamp);
                    return SideTitleWidget(
                      meta: meta,
                      // axisSide: meta.axisSide,
                      child: Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
            ),
            borderData: FlBorderData(show: true),
            gridData: const FlGridData(show: true),
          ),
        ),
      ),
    );
  }
}
