import 'dart:math';

import 'package:flutter/material.dart';
import 'package:visualizer/data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dogs Benchmarks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BenchmarkView(),
    );
  }
}

class BenchmarkView extends StatelessWidget {
  const BenchmarkView({super.key});

  @override
  Widget build(BuildContext context) {
    var data = loadBenchmarkEntries();
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: GridView.extent(
            maxCrossAxisExtent: 600,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: data.map((e) => _buildBenchmark(e)).toList(),))
        ],
      ),
    );
  }

  double computeMaxY(List<int> values) {
    // Everything more than 2 sec diff to smallest is considered an outlier
    const maxDiffToSmallest = 20000 * 1000;
    var smallest = values.reduce(min);
    var filtered = values
        .where((element) => element - smallest < maxDiffToSmallest);
    var meanValue = values
        .where((element) => element - smallest < maxDiffToSmallest)
        .reduce((a, b) => a + b) ~/ values.length;
    return filtered.last.toDouble() * 1.2;
  }

  Widget _buildBenchmark(BenchmarkEntry entry) {
    var sortedEntries = entry.times.entries
        .sortedBy<num>((element) => element.value).toList();

    var values = entry.times.values.toList();
    values.sort();
    var maxY = computeMaxY(values);

    return Card(
      child: Column(
        children: [
          Text(entry.name),
          Expanded(
            child: SizedBox(
              height: 200,
              child: BarChart(BarChartData(
                maxY: maxY,
                barGroups: sortedEntries
                    .mapIndexed((i, e) {
                      Color color = Color.alphaBlend(Colors.black38, Colors.white);
                      if (e.value > maxY) {
                        color = Colors.red;
                      }
                      if (e.key == "dogs") {
                        color = Colors.blue;
                      }
                      /*
                      if (e.key == "native") {
                        color = Color.alphaBlend(Colors.black26, Colors.white);
                      }
                       */
                      return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                                toY: min(e.value.toDouble(), maxY),
                                width: 32,
                                color: color,
                                borderRadius: BorderRadius.zero),
                          ],
                        );
                    })
                    .toList(),
                gridData: const FlGridData(show: true),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      var item = sortedEntries.elementAt(group.x.toInt());
                      return BarTooltipItem(
                        "${item.key}\n${(item.value / 1000.0).toStringAsFixed(2)}ms",
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            var mapEntry = sortedEntries.elementAt(value.toInt());
                            return Text(
                                "${mapEntry.key}\n"
                                    "${(mapEntry.value / 1000.0).toStringAsFixed(2)}ms",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              );
                          })),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                                  "${value.toInt() ~/ 1000.0}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                          ))),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
