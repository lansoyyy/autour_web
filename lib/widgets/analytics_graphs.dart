import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';

// Helper for Y-axis labels with K
String _formatK(num value) {
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(0);
}

// Tourist Growth per Month for Top Aurora Destinations
class TouristGrowthLineChart extends StatelessWidget {
  const TouristGrowthLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = [
      'Sabang Beach',
      'Ditumabo Falls',
      'Dicasalarin\nCove'
    ];
    final List<List<FlSpot>> data = [
      [
        FlSpot(0, 400),
        FlSpot(1, 600),
        FlSpot(2, 900),
        FlSpot(3, 1200),
        FlSpot(4, 1100),
        FlSpot(5, 1300)
      ],
      [
        FlSpot(0, 200),
        FlSpot(1, 350),
        FlSpot(2, 500),
        FlSpot(3, 700),
        FlSpot(4, 800),
        FlSpot(5, 900)
      ],
      [
        FlSpot(0, 100),
        FlSpot(1, 200),
        FlSpot(2, 300),
        FlSpot(3, 400),
        FlSpot(4, 500),
        FlSpot(5, 600)
      ],
    ];
    final colors = [primary, Colors.green, Colors.orange];
    return Container(
      constraints: const BoxConstraints(minWidth: 380, maxWidth: 420),
      margin: const EdgeInsets.only(right: 12, left: 4, bottom: 8, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              'Tourist Growth per Month (by Destination)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 0),
            child: SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => Text(
                          _formatK(value),
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        interval: 500,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun'
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              months[value.toInt() % months.length],
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          );
                        },
                        reservedSize: 22,
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 5,
                  minY: 0,
                  maxY: 1500,
                  lineBarsData: List.generate(destinations.length, (i) {
                    return LineChartBarData(
                      spots: data[i],
                      isCurved: true,
                      color: colors[i],
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    );
                  }),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                  destinations.length,
                  (i) => Row(
                        children: [
                          Container(width: 12, height: 12, color: colors[i]),
                          const SizedBox(width: 4),
                          Text(destinations[i],
                              style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 10),
                        ],
                      )),
            ),
          ),
        ],
      ),
    );
  }
}

// Check-ins by Aurora Destination (Bar Chart)
class CheckinsBarChart extends StatelessWidget {
  const CheckinsBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final sites = [
      'Sabang Beach',
      'Ditumabo Falls',
      'Dicasalarin Cove',
      'Baler Church',
      'Ampere Beach',
    ];
    final values = [3200, 2100, 1800, 900, 700];
    return Container(
      constraints: const BoxConstraints(minWidth: 380, maxWidth: 420),
      margin: const EdgeInsets.only(right: 12, left: 4, bottom: 8, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              'Check-ins by Destination',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 0),
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => Text(
                          _formatK(value),
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        interval: 1000,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= sites.length)
                            return const SizedBox.shrink();
                          final label = sites[idx].length > 12
                              ? sites[idx].substring(0, 11) + '…'
                              : sites[idx];
                          return Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              label,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        reservedSize: 38,
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(sites.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i].toDouble(),
                          color: secondary,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Visitor Nationality Breakdown for Sabang Beach (Pie Chart)
class NationalityPieChart extends StatelessWidget {
  const NationalityPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'label': 'PH', 'value': 70.0, 'color': Colors.blue},
      {'label': 'KR', 'value': 10.0, 'color': Colors.redAccent},
      {'label': 'US', 'value': 8.0, 'color': Colors.green},
      {'label': 'JP', 'value': 7.0, 'color': Colors.orange},
      {'label': 'Other', 'value': 5.0, 'color': Colors.purple},
    ];
    return Container(
      constraints: const BoxConstraints(minWidth: 340, maxWidth: 360),
      margin: const EdgeInsets.only(right: 12, left: 4, bottom: 8, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              'Visitor Nationality (Sabang Beach)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: data.map((e) {
                    return PieChartSectionData(
                      color: e['color'] as Color,
                      value: e['value'] as double,
                      title: '${e['label']}',
                      radius: 48,
                      titleStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
