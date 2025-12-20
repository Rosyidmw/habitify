import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    final cardColor = Theme.of(context).colorScheme.surface;

    final textColor = Theme.of(context).colorScheme.onSurface;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text(
            'Statistik',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: cardColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),

            color: textColor,
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF4F46E5),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF4F46E5),
            tabs: [
              Tab(text: 'Harian'),
              Tab(text: 'Mingguan'),
              Tab(text: 'Bulanan'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_DailyView(), _WeeklyView(), _MonthlyView()],
        ),
      ),
    );
  }
}

class _DailyView extends StatelessWidget {
  const _DailyView();

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final totalHabits = provider.habits.length;
        final completedHabits = provider.habits
            .where((h) => h.isCompleted)
            .length;

        final percentage = totalHabits == 0
            ? 0.0
            : (completedHabits / totalHabits);
        final percentageText = (percentage * 100).toStringAsFixed(0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),

                decoration: _cardDecoration(context),
                child: Column(
                  children: [
                    const Text(
                      "Progress Hari Ini",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 60,
                              startDegreeOffset: -90,
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFF10B981),
                                  value: completedHabits.toDouble(),
                                  radius: 25,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  value: (totalHabits - completedHabits)
                                      .toDouble(),
                                  radius: 25,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "$percentageText%",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const Text(
                                  "Selesai",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem("Total", "$totalHabits", Colors.blue),
                        _buildStatItem(
                          "Selesai",
                          "$completedHabits",
                          const Color(0xFF10B981),
                        ),
                        _buildStatItem(
                          "Sisa",
                          "${totalHabits - completedHabits}",
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _WeeklyView extends StatelessWidget {
  const _WeeklyView();

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final data = provider.weeklyData;

        final maxY =
            (data.values.isEmpty
                    ? 10
                    : data.values.reduce((a, b) => a > b ? a : b))
                .toDouble() +
            2;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Performa Minggu Ini",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.blueGrey,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              const days = [
                                'Sn',
                                'Sl',
                                'Rb',
                                'Km',
                                'Jm',
                                'Sb',
                                'Mg',
                              ];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  days[value.toInt()],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: List.generate(7, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: (data[index] ?? 0).toDouble(),
                              color: const Color(0xFF4F46E5),
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,

                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthlyView extends StatelessWidget {
  const _MonthlyView();

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final data = provider.monthlyData;
        final maxY =
            (data.values.isEmpty
                    ? 10
                    : data.values.reduce((a, b) => a > b ? a : b))
                .toDouble() +
            2;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 600,
            height: 400,
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Performa Bulan Ini",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int date = value.toInt();
                              if (date % 2 != 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  date.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: data.entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: const Color(0xFF10B981),
                              width: 8,
                              borderRadius: BorderRadius.circular(2),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
