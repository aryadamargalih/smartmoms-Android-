import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../sleep/sleep_tracker.dart';
import '../mood/mood_tracker.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data mingguan
  final List<FlSpot> _weeklyBpm = [
    FlSpot(0, 82),
    FlSpot(1, 79),
    FlSpot(2, 85),
    FlSpot(3, 88),
    FlSpot(4, 81),
    FlSpot(5, 84),
    FlSpot(6, 83),
  ];

  // Dummy riwayat
  final List<Map<String, String>> _history = [
    {'date': 'Hari ini', 'bpm': '84', 'bp': '120/78', 'steps': '5.430'},
    {'date': 'Kemarin', 'bpm': '81', 'bp': '118/76', 'steps': '6.210'},
    {'date': 'Senin', 'bpm': '86', 'bp': '122/80', 'steps': '4.890'},
    {'date': 'Minggu', 'bpm': '79', 'bp': '116/74', 'steps': '7.100'},
    {'date': 'Sabtu', 'bpm': '83', 'bp': '119/77', 'steps': '3.200'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.lightTextSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Mingguan'),
            Tab(text: 'Bulanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContent(isDark),
          _buildContent(isDark), // ganti data untuk bulanan nanti
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
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
                value: '83',
                unit: 'bpm',
                icon: Icons.favorite_rounded,
                color: AppColors.bpmColor,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: StatCard(
                title: 'Rata-rata TD',
                value: '119/77',
                unit: 'mmHg',
                icon: Icons.monitor_heart_rounded,
                color: AppColors.primary,
              )),
            ],
          ),
          const SizedBox(height: 12),
          StatCard(
            title: 'Total Langkah Minggu Ini',
            value: '36.830',
            unit: 'langkah',
            icon: Icons.directions_walk_rounded,
            color: AppColors.activityColor,
          ),

          const SizedBox(height: 24),
          const SectionHeader(title: 'Pemantauan Tidur'),
          const SizedBox(height: 12),

          StatCard(
            title: 'Rata-rata Tidur Minggu Ini',
            value: '6.8',
            unit: 'jam',
            icon: Icons.bedtime_rounded,
            color: Color(0xFF7C3AED),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 12,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${rod.toY.toStringAsFixed(1)} jam',
                      TextStyle(
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}j',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      interval: 3,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = [
                          'Sen',
                          'Sel',
                          'Rab',
                          'Kam',
                          'Jum',
                          'Sab',
                          'Min'
                        ];
                        final i = v.toInt();
                        if (i < 0 || i >= days.length) return const SizedBox();
                        return Text(days[i],
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: (isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider)
                        .withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: dummySleepRecords.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.durationHours,
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF7C3AED), Color(0xFF9F67FF)],
                        ),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

// Riwayat tidur
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: dummySleepRecords.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                final isLast = i == dummySleepRecords.length - 1;
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
                              color: const Color(0xFF7C3AED).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.bedtime_rounded,
                                color: Color(0xFF7C3AED), size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (s.quality != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(s.quality!.emoji,
                                        style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: 3),
                                    Text(s.quality!.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: s.quality!.color,
                                          fontWeight: FontWeight.w500,
                                        )),
                                  ],
                                ),
                              ],
                              if (s.disturbances.isNotEmpty &&
                                  s.disturbances.first != SleepDisturbance.none)
                                Text(
                                  s.disturbances
                                      .where((d) => d != SleepDisturbance.none)
                                      .map((d) => d.label)
                                      .join(', '),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.danger.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.end,
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
          const SectionHeader(title: 'Riwayat Mood'),
          const SizedBox(height: 12),

          // Mood chart (7 hari)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  dummyMoodRecords.reversed.toList().asMap().entries.map((e) {
                final record = e.value;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(record.mood.emoji,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      '${record.date.day}/${record.date.month}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

// Mood list
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: dummyMoodRecords.asMap().entries.map((e) {
                final i = e.key;
                final m = e.value;
                final isLast = i == dummyMoodRecords.length - 1;
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: m.mood.isNegative
                                      ? AppColors.danger.withOpacity(0.1)
                                      : AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  m.mood.isNegative ? 'Negatif' : 'Positif',
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

          // BPM Chart
          const SizedBox(height: 24),
          const SectionHeader(title: 'Tren Detak Jantung'),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: LineChart(LineChartData(
              // gunakan _weeklyBpm, styling sama seperti di dashboard
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: const TextStyle(fontSize: 10)),
                )),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    const days = [
                      'Sen',
                      'Sel',
                      'Rab',
                      'Kam',
                      'Jum',
                      'Sab',
                      'Min'
                    ];
                    final i = v.toInt();
                    if (i < 0 || i >= days.length) return const SizedBox();
                    return Text(days[i], style: const TextStyle(fontSize: 10));
                  },
                )),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: 60, maxY: 110,
              lineBarsData: [
                LineChartBarData(
                  spots: _weeklyBpm,
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
            )),
          ),
          const SizedBox(height: 24),

          // Riwayat tabel
          const SectionHeader(title: 'Riwayat Pengukuran'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: _history.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: i < _history.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightDivider,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(item['date']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            )),
                      ),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _HistoryItem(
                              icon: Icons.favorite_rounded,
                              color: AppColors.bpmColor,
                              value: '${item['bpm']} bpm'),
                          _HistoryItem(
                              icon: Icons.monitor_heart_rounded,
                              color: AppColors.primary,
                              value: item['bp']!),
                          _HistoryItem(
                              icon: Icons.directions_walk_rounded,
                              color: AppColors.activityColor,
                              value: item['steps']!),
                        ],
                      )),
                    ],
                  ),
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
