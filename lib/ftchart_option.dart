import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FsrChartScreen extends StatefulWidget {
  List<int> fsrDatas = [];
  FsrChartScreen({Key? key, required this.fsrDatas}) : super(key: key);
  @override
  _FsrChartScreenState createState() => _FsrChartScreenState();
}

class _FsrChartScreenState extends State<FsrChartScreen> {
  List<double> chDatas = [];

  @override
  void initState() {
    super.initState();
    chDatas = widget.fsrDatas.map((e) => e.toDouble()).toList();
    // generateSampleData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การดูดจุกนมของทารก'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text(
            //   'Max[] Min Conunt : ${widget.fsrDatas.length}',
            //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            SizedBox(
                height: 250, child: buildLineChart(chDatas, chDatas.length)),
          ],
        ),
      ),
    );
  }

  LineChart buildLineChart(List<double> data, int durationInSeconds) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: Colors.blueAccent,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.x.toStringAsFixed(0)}s, '
                  '${touchedSpot.y.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              // interval: durationInSeconds > 10 ? 5 : 2,
              interval: durationInSeconds >= 900
                  ? 20
                  : durationInSeconds >= 600
                      ? 10
                      : durationInSeconds >= 300
                          ? 5
                          : 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} s',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((entry) => FlSpot(
                    entry.key * 0.1, // Multiply by 0.2 to match 200ms intervals
                    entry.value))
                .toList(),
            isCurved: true,
            // colors: [Colors.blue],
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
