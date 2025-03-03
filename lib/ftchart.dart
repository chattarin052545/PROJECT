import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatelessWidget {
  final List<FlSpot> spots;

  ChartScreen({required this.spots});

  @override
  Widget build(BuildContext context) {
    // Validate spots to remove invalid data
    final validSpots = spots.where((spot) {
      return spot.x.isFinite && spot.y.isFinite;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sucking Force Graph'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              // rightTitles: AxisTitles(
              //   sideTitles: SideTitles(showTitles: false, reservedSize: 40),
              // ),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    // Validate the value before converting to text
                    if (value.isNaN || value.isInfinite) {
                      return Text('');
                    }
                    // Display labels only for multiples of 5
                    if (value % 1 == 0) {
                      return Text('${value.toInt()}',
                          style: const TextStyle(fontSize: 12));
                    }
                    return const SizedBox.shrink(); // Skip other labels
                    // return Text('${value.toInt()}s',
                    //     style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: validSpots,
                isCurved: true,
                color: Colors.blue,
                barWidth: 1,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
