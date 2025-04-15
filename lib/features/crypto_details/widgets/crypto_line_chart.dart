import 'package:brasil_cripto/core/models/crypto_grafic_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CryptoLineChart extends StatelessWidget {
  final List<CryptoGraficModel> data;

  const CryptoLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Sem dados para exibir o gráfico'));
    }

    final spots =
        data.map((e) => FlSpot(e.time.toDouble(), e.price.toDouble())).toList();

    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              spots: spots,
              color: Colors.blueAccent,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
              isStrokeCapRound: true,
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
