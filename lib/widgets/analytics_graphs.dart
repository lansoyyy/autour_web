import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final now = DateTime.now();
    // Last 6 months windows
    final monthStarts = List<DateTime>.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i), 1);
      return m;
    });
    final monthLabels =
        monthStarts.map((d) => monthNames[d.month - 1]).toList();
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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('scans')
                    .where(
                      'scannedAt',
                      isGreaterThan: Timestamp.fromDate(
                        DateTime(now.year, now.month - 5, 1),
                      ),
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading data'));
                  }
                  final docs = snapshot.data?.docs ?? const [];
                  // Aggregate counts per destination per month index
                  final Map<String, List<int>> series = {};
                  for (final d in docs) {
                    final data = d.data();
                    final ts = data['scannedAt'];
                    if (ts == null || ts is! Timestamp) continue;
                    final dt = ts.toDate();
                    // find month index (0..5)
                    int idx = -1;
                    for (int i = 0; i < monthStarts.length; i++) {
                      if (dt.year == monthStarts[i].year &&
                          dt.month == monthStarts[i].month) {
                        idx = i;
                        break;
                      }
                    }
                    if (idx < 0) continue;
                    final dest =
                        (data['destinationName'] ?? 'Unknown').toString();
                    series.putIfAbsent(dest, () => List<int>.filled(6, 0));
                    series[dest]![idx] += 1;
                  }

                  if (series.isEmpty) {
                    // Show empty chart (axes only) instead of a 'No data' text
                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) => Text(
                                _formatK(value),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              interval: 5,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= monthLabels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    monthLabels[i],
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                );
                              },
                              reservedSize: 22,
                            ),
                          ),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 5,
                        minY: 0,
                        lineBarsData: const [],
                      ),
                    );
                  }

                  // pick top 3 destinations by total
                  final top = series.entries.toList()
                    ..sort((a, b) => b.value
                        .reduce((p, c) => p + c)
                        .compareTo(a.value.reduce((p, c) => p + c)));
                  final top3 = top.take(3).toList();

                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) => Text(
                              _formatK(value),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                            interval: 5,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= monthLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  monthLabels[i],
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              );
                            },
                            reservedSize: 22,
                          ),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 5,
                      minY: 0,
                      lineBarsData: List.generate(top3.length, (i) {
                        final values = top3[i].value;
                        return LineChartBarData(
                          spots: List<FlSpot>.generate(
                              6,
                              (x) =>
                                  FlSpot(x.toDouble(), values[x].toDouble())),
                          isCurved: true,
                          color: colors[i % colors.length],
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('scans')
                  .where(
                    'scannedAt',
                    isGreaterThan: Timestamp.fromDate(
                      DateTime(now.year, now.month - 5, 1),
                    ),
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }
                final docs = snapshot.data!.docs;
                final Map<String, int> totals = {};
                for (final d in docs) {
                  final dest =
                      (d.data()['destinationName'] ?? 'Unknown').toString();
                  totals[dest] = (totals[dest] ?? 0) + 1;
                }
                final entries = totals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final top3 = entries.take(3).toList();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                      top3.length,
                      (i) => Row(
                            children: [
                              Container(
                                  width: 12,
                                  height: 12,
                                  color: colors[i % colors.length]),
                              const SizedBox(width: 4),
                              Text(top3[i].key,
                                  style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 10),
                            ],
                          )),
                );
              },
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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('scans')
                    .where(
                      'scannedAt',
                      isGreaterThan: Timestamp.fromDate(
                        DateTime(
                            DateTime.now().year, DateTime.now().month - 6, 1),
                      ),
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading data'));
                  }
                  final docs = snapshot.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    // Show empty bar chart (axes only) instead of a 'No data' text
                    return BarChart(
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
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              interval: 5,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: const [],
                      ),
                    );
                  }
                  final Map<String, int> counts = {};
                  for (final d in docs) {
                    final dest =
                        (d.data()['destinationName'] ?? 'Unknown').toString();
                    counts[dest] = (counts[dest] ?? 0) + 1;
                  }
                  final entries = counts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final topN = entries.take(5).toList();

                  return BarChart(
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
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                            interval: 5,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= topN.length)
                                return const SizedBox.shrink();
                              final label = topN[idx].key.length > 12
                                  ? topN[idx].key.substring(0, 11) + '…'
                                  : topN[idx].key;
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
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: List.generate(topN.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: topN[i].value.toDouble(),
                              color: secondary,
                              width: 18,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        );
                      }),
                    ),
                  );
                },
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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('scans')
                    .where('destinationName', isEqualTo: 'Sabang Beach')
                    .where(
                      'scannedAt',
                      isGreaterThan: Timestamp.fromDate(
                        DateTime(
                            DateTime.now().year, DateTime.now().month - 6, 1),
                      ),
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Center(child: Text('Error loading data'));
                  }
                  final docs = snapshot.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.grey.shade300,
                            value: 1,
                            title: '',
                            radius: 48,
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 32,
                      ),
                    );
                  }
                  final Map<String, double> counts = {};
                  for (final d in docs) {
                    final data = d.data();
                    final profile =
                        (data['userProfile'] as Map<String, dynamic>?) ?? {};
                    final nationality =
                        (profile['nationality'] ?? 'Unknown').toString();
                    counts[nationality] = (counts[nationality] ?? 0) + 1;
                  }
                  // Sort and take top 4, summarize others
                  final entries = counts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final top = entries.take(4).toList();
                  final otherTotal =
                      entries.skip(4).fold<double>(0, (p, e) => p + e.value);
                  if (otherTotal > 0) {
                    top.add(MapEntry('Other', otherTotal));
                  }
                  final palette = [
                    Colors.blue,
                    Colors.redAccent,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                  ];

                  return PieChart(
                    PieChartData(
                      sections: List.generate(top.length, (i) {
                        final e = top[i];
                        return PieChartSectionData(
                          color: palette[i % palette.length],
                          value: e.value,
                          title: e.key,
                          radius: 48,
                          titleStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                      sectionsSpace: 2,
                      centerSpaceRadius: 32,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
