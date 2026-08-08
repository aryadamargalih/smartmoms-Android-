import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../sleep/sleep_tracker.dart';
import '../mood/mood_tracker.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/statistics_provider.dart';
import '../../core/providers/sleep_provider.dart';
import '../../core/providers/mood_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().fetchAll();
      context.read<SleepProvider>().fetchHistory();
      context.read<MoodProvider>().fetchHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = context.watch<StatisticsProvider>();
    final sleep = context.watch<SleepProvider>();
    final mood = context.watch<MoodProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Mingguan'),
            Tab(text: 'Bulanan'),
          ],
          onTap: (i) {
            final period = i == 0 ? 'week' : 'month';
            context.read<StatisticsProvider>().fetchAll(period: period);
            context.read<SleepProvider>().fetchHistory(period: period);
            context.read<MoodProvider>().fetchHistory(period: period);
          },
        ),
      ),
      body: stats.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () => context
                  .read<StatisticsProvider>()
                  .fetchAll(period: stats.currentPeriod),
              color: AppColors.primary,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildContent(isDark, stats, sleep, mood),
                  _buildContent(isDark, stats, sleep, mood),
                ],
              ),
            ),
    );
  }

  Widget _buildContent(
    bool isDark,
    StatisticsProvider stats,
    SleepProvider sleep,
    MoodProvider mood,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Rata-rata BPM',
                  value: stats.summary?.avgBpm.toStringAsFixed(0) ?? '--',
                  unit: 'bpm',
                  icon: Icons.favorite_rounded,
                  color: AppColors.bpmColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Rata-rata TD',
                  value: stats.summary != null
                      ? '${stats.summary!.avgSystolic.toStringAsFixed(0)}/${stats.summary!.avgDiastolic.toStringAsFixed(0)}'
                      : '--/--',
                  unit: 'mmHg',
                  icon: Icons.monitor_heart_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatCard(
            title: 'Total Langkah',
            value: stats.summary?.totalSteps.toString() ?? '--',
            unit: 'langkah',
            icon: Icons.directions_walk_rounded,
            color: AppColors.activityColor,
          ),
          const SizedBox(height: 12),
          StatCard(
            title: 'Rata-rata Tidur',
            value: stats.summary?.avgSleep.toStringAsFixed(1) ?? '--',
            unit: 'jam',
            icon: Icons.bedtime_rounded,
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 24),

          // BPM Chart
          const SectionHeader(title: 'Tren Detak Jantung'),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: stats.healthHistory.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= stats.healthHistory.length) {
                                return const SizedBox();
                              }
                              final date = stats.healthHistory[i].date;
                              return Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 60,
                      maxY: 110,
                      lineBarsData: [
                        LineChartBarData(
                          spots: stats.healthHistory
                              .asMap()
                              .entries
                              .where((e) => e.value.bpm != null)
                              .map((e) => FlSpot(
                                    e.key.toDouble(),
                                    e.value.bpm!.toDouble(),
                                  ))
                              .toList(),
                          isCurved: true,
                          color: AppColors.bpmColor,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.bpmColor.withOpacity(0.2),
                                AppColors.bpmColor.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // Riwayat kesehatan
          const SectionHeader(title: 'Riwayat Pengukuran'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: stats.healthHistory.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Belum ada data',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: stats.healthHistory.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value;
                      final isLast = i == stats.healthHistory.length - 1;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    '${item.date.day}/${item.date.month}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _HistoryItem(
                                        icon: Icons.favorite_rounded,
                                        color: AppColors.bpmColor,
                                        value: item.bpm != null
                                            ? '${item.bpm} bpm'
                                            : '--',
                                      ),
                                      _HistoryItem(
                                        icon: Icons.monitor_heart_rounded,
                                        color: AppColors.primary,
                                        value: item.systolic != null
                                            ? '${item.systolic}/${item.diastolic}'
                                            : '--/--',
                                      ),
                                      _HistoryItem(
                                        icon: Icons.directions_walk_rounded,
                                        color: AppColors.activityColor,
                                        value: item.steps != null
                                            ? '${item.steps}'
                                            : '--',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 16,
                              color: isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightDivider,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 24),

          // Sleep history
          const SectionHeader(title: 'Pemantauan Tidur'),
          const SizedBox(height: 12),
          StatCard(
            title: 'Rata-rata Tidur',
            value: stats.summary?.avgSleep.toStringAsFixed(1) ?? '--',
            unit: 'jam',
            icon: Icons.bedtime_rounded,
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: sleep.sleepHistory.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Belum ada data tidur',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: sleep.sleepHistory.asMap().entries.map((e) {
                      final i = e.key;
                      final s = e.value;
                      final isLast = i == sleep.sleepHistory.length - 1;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7C3AED)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.bedtime_rounded,
                                      color: Color(0xFF7C3AED), size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${s.date.day}/${s.date.month}/${s.date.year}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.darkText
                                              : AppColors.lightText,
                                        ),
                                      ),
                                      Text(
                                        '${s.bedTime.hour.toString().padLeft(2, '0')}:${s.bedTime.minute.toString().padLeft(2, '0')} — ${s.wakeTime.hour.toString().padLeft(2, '0')}:${s.wakeTime.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      s.durationText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (s.status == 'Baik'
                                                ? AppColors.success
                                                : s.status == 'Cukup'
                                                    ? AppColors.warning
                                                    : AppColors.danger)
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        s.status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: s.status == 'Baik'
                                              ? AppColors.success
                                              : s.status == 'Cukup'
                                                  ? AppColors.warning
                                                  : AppColors.danger,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 56,
                              color: isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightDivider,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 24),

          // Mood history
          const SectionHeader(title: 'Riwayat Mood'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: mood.moodHistory.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Belum ada data mood',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: mood.moodHistory.asMap().entries.map((e) {
                      final i = e.key;
                      final m = e.value;
                      final isLast = i == mood.moodHistory.length - 1;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Text(m.mood.emoji,
                                    style: const TextStyle(fontSize: 28)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.mood.label,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: m.mood.color,
                                        ),
                                      ),
                                      if (m.note != null)
                                        Text(
                                          m.note!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.lightTextSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${m.date.day}/${m.date.month}/${m.date.year}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: m.mood.isNegative
                                            ? AppColors.danger.withOpacity(0.1)
                                            : AppColors.success
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        m.mood.isNegative
                                            ? 'Negatif'
                                            : 'Positif',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: m.mood.isNegative
                                              ? AppColors.danger
                                              : AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 56,
                              color: isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightDivider,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;

  const _HistoryItem(
      {required this.icon, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
