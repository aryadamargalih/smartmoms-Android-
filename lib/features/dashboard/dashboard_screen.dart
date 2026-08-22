import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/common_widgets.dart';
import '../inbox/inbox_screen.dart';
import '../sleep/sleep_tracker.dart';
import '../mood/mood_tracker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/sleep_provider.dart';
import '../../core/providers/mood_provider.dart';
import '../../core/providers/inbox_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bpmPeriod = 0;
  int _bpPeriod = 0;
  int _activityPeriod = 0;
  bool _moodReminderShown = false;

  // getter BPM
  List<FlSpot> get _bpmSpots {
    final data = context.read<HealthProvider>().bpmChartData;
    return data
        .where((e) => e.bpm != null)
        .toList()
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.bpm!.toDouble()))
        .toList();
  }

  // getter TD Sistolik
  List<FlSpot> get _systolicSpots {
    final data = context.read<HealthProvider>().bpChartData;
    return data
        .where((e) => e.systolic != null)
        .toList()
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.systolic!.toDouble()))
        .toList();
  }

  // getter TD Diastolik
  List<FlSpot> get _diastolicSpots {
    final data = context.read<HealthProvider>().bpChartData;
    return data
        .where((e) => e.diastolic != null)
        .toList()
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.diastolic!.toDouble()))
        .toList();
  }

  // getter Aktivitas
  List<BarChartGroupData> get _activitySpots {
    final data = context.read<HealthProvider>().activityChartData;
    return data.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.steps?.toDouble() ?? 0,
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppColors.activityColor, AppColors.activityColorLight],
            ),
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<HealthProvider>().refreshAll();
      context.read<SleepProvider>().fetchToday();
      context.read<InboxProvider>().fetchMessages();

      // Tunggu mood selesai fetch dulu baru cek reminder
      await context.read<MoodProvider>().fetchToday();

      if (mounted && !_moodReminderShown) {
        final moodProvider = context.read<MoodProvider>();
        if (moodProvider.todayMood == null) {
          _showMoodReminder();
          setState(() => _moodReminderShown = true);
        }
      }
    });
  }

  void _showMoodReminder() {
    setState(() => _moodReminderShown = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MoodReminderDialog(
        onFill: () {
          Navigator.pop(context);
          _showMoodInput(context);
        },
        onSkip: () => Navigator.pop(context),
      ),
    );
  }

  void _showMoodInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoodInputSheet(
        onSave: (mood, note) async {
          await context.read<MoodProvider>().submitMood(
                mood: mood,
                note: note,
              );
        },
      ),
    );
  }

  void _showSleepInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SleepInputSheet(
        onSave: (bed, wake, quality, disturbances) async {
          final ok = await context.read<SleepProvider>().submitSleep(
                bedTime: bed,
                wakeTime: wake,
                quality: quality,
                disturbances: disturbances,
              );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ok
                  ? 'Data tidur berhasil disimpan'
                  : context.read<SleepProvider>().errorMessage ??
                      'Gagal menyimpan data tidur'),
              backgroundColor: ok ? AppColors.success : AppColors.danger,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final periods = ['Hari', 'Minggu', 'Bulan'];
    final health = context.watch<HealthProvider>();
    final user = context.watch<AuthProvider>().user;
    final sleep = context.watch<SleepProvider>();
    final mood = context.watch<MoodProvider>();
    final unreadCount = context.watch<InboxProvider>().unreadCount;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HealthProvider>().refreshAll(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                floating: true,
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                elevation: 0,
                title: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8)
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          AppAssets.splashLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.favorite,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Halo, ${user?.name.split(' ').first ?? 'Bunda'} 👋',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color:
                              isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const InboxScreen()),
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Pregnancy week banner
                    _PregnancyBanner(
                      isDark: isDark,
                      nifasDay: user?.nifasDay ?? 0,
                    ),
                    const SizedBox(height: 24),

                    // Quick stats
                    const SectionHeader(title: 'Ringkasan Hari Ini'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: AppStrings.heartRate,
                            value: health.isLoading
                                ? '---'
                                : '${health.summary?.bpm ?? '--'}',
                            unit: AppStrings.bpm,
                            icon: Icons.favorite_rounded,
                            color: AppColors.bpmColor,
                            status:
                                health.summary?.bpm != null ? 'Normal' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: AppStrings.bloodPressure,
                            value: health.isLoading
                                ? '---'
                                : health.summary?.systolic != null
                                    ? '${health.summary!.systolic}/${health.summary!.diastolic}'
                                    : '--/--',
                            unit: AppStrings.mmHg,
                            icon: Icons.monitor_heart_rounded,
                            color: AppColors.primary,
                            status: health.summary?.systolic != null
                                ? 'Normal'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StatCard(
                      title: AppStrings.physicalActivity,
                      value: health.isLoading
                          ? '---'
                          : health.summary?.steps != null
                              ? '${health.summary!.steps}'
                              : '--',
                      unit: AppStrings.steps,
                      icon: Icons.directions_walk_rounded,
                      color: AppColors.activityColor,
                      status:
                          health.summary?.steps != null ? '72% target' : null,
                    ),
                    const SizedBox(height: 12),
                    _SleepCard(
                      sleep: sleep.todaySleep,
                      isDark: isDark,
                      onInput: () => _showSleepInput(context),
                    ),
                    const SizedBox(height: 12),
                    _MoodCard(
                      mood: mood.todayMood,
                      isDark: isDark,
                      onInput: () => _showMoodInput(context),
                    ),
                    const SizedBox(height: 12),

                    // BPM Chart
                    _ChartCard(
                      title: AppStrings.heartRate,
                      subtitle: 'Detak jantung kamu',
                      icon: Icons.favorite_rounded,
                      iconColor: AppColors.bpmColor,
                      period: _bpmPeriod,
                      periods: periods,
                      onPeriodChanged: (i) {
                        setState(() => _bpmPeriod = i);
                        final p = ['day', 'week', 'month'];
                        context
                            .read<HealthProvider>()
                            .fetchBpmChartData(period: p[i]);
                      },
                      chart: _bpmSpots.isEmpty
                          ? _EmptyChart(isDark: isDark)
                          : _BpmLineChart(spots: _bpmSpots, isDark: isDark),
                    ),
                    const SizedBox(height: 20),

                    // Blood Pressure Chart
                    _ChartCard(
                      title: AppStrings.bloodPressure,
                      subtitle: 'Sistolik & Diastolik',
                      icon: Icons.monitor_heart_rounded,
                      iconColor: AppColors.primary,
                      period: _bpPeriod,
                      periods: periods,
                      onPeriodChanged: (i) {
                        setState(() => _bpPeriod = i);
                        final p = ['day', 'week', 'month'];
                        context
                            .read<HealthProvider>()
                            .fetchBpChartData(period: p[i]);
                      },
                      chart: _systolicSpots.isEmpty
                          ? _EmptyChart(isDark: isDark)
                          : _BloodPressureLineChart(
                              systolicSpots: _systolicSpots,
                              diastolicSpots: _diastolicSpots,
                              isDark: isDark,
                            ),
                      legend: _systolicSpots.isEmpty ? null : const _BpLegend(),
                    ),
                    const SizedBox(height: 20),

                    // Activity Chart
                    _ChartCard(
                      title: AppStrings.physicalActivity,
                      subtitle: 'Langkah per hari',
                      icon: Icons.directions_walk_rounded,
                      iconColor: AppColors.activityColor,
                      period: _activityPeriod,
                      periods: periods,
                      onPeriodChanged: (i) {
                        setState(() => _activityPeriod = i);
                        final p = ['day', 'week', 'month'];
                        context
                            .read<HealthProvider>()
                            .fetchActivityChartData(period: p[i]);
                      },
                      chart: _activitySpots.isEmpty
                          ? _EmptyChart(isDark: isDark)
                          : _ActivityBarChart(
                              groups: _activitySpots, isDark: isDark),
                    ),
                    const SizedBox(height: 20),

                    // AI Banner
                    _AiBanner(isDark: isDark),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pregnancy Banner ──────────────────────────────────────────────────────
class _PregnancyBanner extends StatelessWidget {
  final bool isDark;
  final int nifasDay;

  const _PregnancyBanner({
    required this.isDark,
    required this.nifasDay,
  });

  String get _nifasStatus {
    if (nifasDay <= 7) return 'Masa Nifas Awal';
    if (nifasDay <= 14) return 'Masa Nifas Minggu 2';
    if (nifasDay <= 21) return 'Masa Nifas Minggu 3';
    if (nifasDay <= 40) return 'Masa Nifas Minggu 4+';
    return 'Masa Nifas Selesai';
  }

  String get _nifasEmoji {
    if (nifasDay <= 7) return '🌸';
    if (nifasDay <= 14) return '💪';
    if (nifasDay <= 21) return '🌟';
    if (nifasDay <= 40) return '✨';
    return '🎉';
  }

  String get _nifasTip {
    if (nifasDay <= 7) return 'Istirahat yang cukup sangat penting';
    if (nifasDay <= 14) return 'Mulai aktivitas ringan perlahan';
    if (nifasDay <= 21) return 'Jaga pola makan bergizi';
    if (nifasDay <= 40) return 'Hampir selesai masa nifas!';
    return 'Masa nifas telah selesai';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (nifasDay / 40).clamp(0.0, 1.0);
    final sisaHari = (40 - nifasDay).clamp(0, 40);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryLight
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari ke-$nifasDay Nifas $_nifasEmoji',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nifasTip,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _nifasEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _nifasStatus,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.25),
              color: Colors.white,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // Stats
          Row(
            children: [
              _PregStat(label: 'Sudah', value: '$nifasDay hari'),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _PregStat(label: 'Sisa', value: '$sisaHari hari'),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _PregStat(label: 'Total', value: '40 hari'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PregStat extends StatelessWidget {
  final String label;
  final String value;
  const _PregStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Chart Card Wrapper ────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final int period;
  final List<String> periods;
  final ValueChanged<int> onPeriodChanged;
  final Widget chart;
  final Widget? legend;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.period,
    required this.periods,
    required this.onPeriodChanged,
    required this.chart,
    this.legend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: PeriodSelector(
              periods: periods,
              selected: period,
              onChanged: onPeriodChanged,
            ),
          ),
          if (legend != null) ...[
            const SizedBox(height: 12),
            legend!,
          ],
          const SizedBox(height: 16),
          SizedBox(height: 180, child: chart),
        ],
      ),
    );
  }
}

// ─── BPM Line Chart ────────────────────────────────────────────────────────
class _BpmLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final bool isDark;

  const _BpmLineChart({required this.spots, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: (isDark ? AppColors.darkDivider : AppColors.lightDivider)
                .withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
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
              interval: 10,
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
                  'Min',
                  'Minggu 2'
                ];
                final i = v.toInt();
                if (i < 0 || i >= days.length) return const SizedBox();
                return Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 60,
        maxY: 110,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.bpmColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.bpmColor,
                strokeWidth: 2,
                strokeColor: isDark ? AppColors.darkCard : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bpmColor.withOpacity(0.25),
                  AppColors.bpmColor.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Blood Pressure Line Chart ─────────────────────────────────────────────
class _BloodPressureLineChart extends StatelessWidget {
  final List<FlSpot> systolicSpots;
  final List<FlSpot> diastolicSpots;
  final bool isDark;

  const _BloodPressureLineChart({
    required this.systolicSpots,
    required this.diastolicSpots,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: (isDark ? AppColors.darkDivider : AppColors.lightDivider)
                .withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
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
              interval: 20,
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
                  'Min',
                  'W2'
                ];
                final i = v.toInt();
                if (i < 0 || i >= days.length) return const SizedBox();
                return Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 60,
        maxY: 150,
        lineBarsData: [
          // Systolic
          LineChartBarData(
            spots: systolicSpots,
            isCurved: true,
            color: AppColors.bloodPressureSystolic,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3.5,
                color: AppColors.bloodPressureSystolic,
                strokeWidth: 2,
                strokeColor: isDark ? AppColors.darkCard : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bloodPressureSystolic.withOpacity(0.15),
                  AppColors.bloodPressureSystolic.withOpacity(0.0),
                ],
              ),
            ),
          ),
          // Diastolic
          LineChartBarData(
            spots: diastolicSpots,
            isCurved: true,
            color: AppColors.bloodPressureDiastolic,
            barWidth: 2.5,
            dashArray: [5, 3],
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3.5,
                color: AppColors.bloodPressureDiastolic,
                strokeWidth: 2,
                strokeColor: isDark ? AppColors.darkCard : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class _BpLegend extends StatelessWidget {
  const _BpLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendDot(color: AppColors.bloodPressureSystolic, label: 'Sistolik'),
        const SizedBox(width: 16),
        _LegendDot(
            color: AppColors.bloodPressureDiastolic,
            label: 'Diastolik',
            isDashed: true),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;

  const _LegendDot(
      {required this.color, required this.label, this.isDashed = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 16,
          height: 2.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Activity Bar Chart ────────────────────────────────────────────────────
class _ActivityBarChart extends StatelessWidget {
  final List<BarChartGroupData> groups;
  final bool isDark;

  const _ActivityBarChart({required this.groups, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10000,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              '${rod.toY.toInt()} langkah',
              TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
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
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text(
                v >= 1000
                    ? '${(v / 1000).toStringAsFixed(0)}k'
                    : '${v.toInt()}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              interval: 2500,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const days = ['S', 'S', 'R', 'K', 'J', 'S', 'M', 'W2'];
                final i = v.toInt();
                if (i < 0 || i >= days.length) return const SizedBox();
                return Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: (isDark ? AppColors.darkDivider : AppColors.lightDivider)
                .withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
      ),
    );
  }
}

// ─── AI Banner ─────────────────────────────────────────────────────────────
class _AiBanner extends StatelessWidget {
  final bool isDark;
  const _AiBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.aiChat),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A1035), const Color(0xFF0F1A35)]
                : [const Color(0xFFF3E8FF), const Color(0xFFE8F0FF)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accent.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI SmartMoms',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chat & analisis risiko depresi postpartum',
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sleep Card ────────────────────────────────────────────────────────────
class _SleepCard extends StatelessWidget {
  final SleepRecord? sleep;
  final bool isDark;
  final VoidCallback onInput;

  const _SleepCard({
    required this.sleep,
    required this.isDark,
    required this.onInput,
  });

  Color _statusColor(String status) {
    if (status == 'Baik') return AppColors.success;
    if (status == 'Cukup') return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onInput,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF7C3AED).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bedtime_rounded,
                color: Color(0xFF7C3AED),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: sleep == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pemantauan Tidur',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                        Text(
                          'Tap untuk input jam tidur hari ini',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              sleep!.durationText,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(sleep!.status)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                sleep!.status,
                                style: TextStyle(
                                  color: _statusColor(sleep!.status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (sleep!.quality != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(sleep!.quality!.emoji,
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(sleep!.quality!.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: sleep!.quality!.color,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                            if (sleep!.disturbances.isNotEmpty &&
                                sleep!.disturbances.first !=
                                    SleepDisturbance.none)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${sleep!.disturbances.where((d) => d != SleepDisturbance.none).length} gangguan',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          'Tidur ${_formatTime(sleep!.bedTime)} — Bangun ${_formatTime(sleep!.wakeTime)}',
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
            Icon(
              Icons.edit_outlined,
              size: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Sleep Input Bottom Sheet ──────────────────────────────────────────────
class _SleepInputSheet extends StatefulWidget {
  final Function(
    DateTime bedTime,
    DateTime wakeTime,
    SleepQuality? quality,
    List<SleepDisturbance> disturbances,
  ) onSave;

  const _SleepInputSheet({required this.onSave});

  @override
  State<_SleepInputSheet> createState() => _SleepInputSheetState();
}

class _SleepInputSheetState extends State<_SleepInputSheet> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 0);
  SleepQuality? _selectedQuality;
  final Set<SleepDisturbance> _selectedDisturbances = {};

  DateTime _toDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  double _calculateDuration() {
    final bed = _toDateTime(_bedTime);
    var wake = _toDateTime(_wakeTime);
    if (wake.isBefore(bed)) {
      wake = wake.add(const Duration(days: 1));
    }
    return wake.difference(bed).inMinutes / 60;
  }

  String _statusFromHours(double hours) {
    if (hours >= 7) return 'Baik';
    if (hours >= 5) return 'Cukup';
    return 'Kurang';
  }

  Color _statusColor(String status) {
    if (status == 'Baik') return AppColors.success;
    if (status == 'Cukup') return AppColors.warning;
    return AppColors.danger;
  }

  Future<void> _pickTime(bool isBed) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBed ? _bedTime : _wakeTime,
    );
    if (picked != null) {
      setState(() {
        if (isBed)
          _bedTime = picked;
        else
          _wakeTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final duration = _calculateDuration();
    final status = _statusFromHours(duration);
    final h = duration.toInt();
    final m = ((duration - h) * 60).toInt();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Center(
              child: Text('Input Waktu Tidur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 20),

            // Duration preview — tetap sama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: const Color(0xFF7C3AED).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bedtime_rounded,
                      color: Color(0xFF7C3AED), size: 20),
                  const SizedBox(width: 8),
                  Text('${h}j ${m}m',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C3AED),
                      )),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(status,
                        style: TextStyle(
                          color: _statusColor(status),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Time pickers — tetap sama
            Row(
              children: [
                Expanded(
                    child: _TimePicker(
                  label: 'Jam Tidur',
                  icon: Icons.nights_stay_rounded,
                  time: _bedTime,
                  isDark: isDark,
                  onTap: () => _pickTime(true),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _TimePicker(
                  label: 'Jam Bangun',
                  icon: Icons.wb_sunny_rounded,
                  time: _wakeTime,
                  isDark: isDark,
                  onTap: () => _pickTime(false),
                )),
              ],
            ),
            const SizedBox(height: 24),

            // ── Kualitas Tidur ──────────────────────────────────────────
            const Text('Kualitas Tidur',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: SleepQuality.values.map((q) {
                final isSelected = _selectedQuality == q;
                return GestureDetector(
                  onTap: () => setState(() => _selectedQuality = q),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? q.color.withOpacity(0.15)
                          : (isDark
                              ? AppColors.darkCard
                              : AppColors.lightBackground),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? q.color
                            : (isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(q.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text('${q.value}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? q.color
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Gangguan Tidur ──────────────────────────────────────────
            const Text('Gangguan Tidur',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Boleh pilih lebih dari satu',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                )),
            const SizedBox(height: 10),
            ...SleepDisturbance.values.map((d) {
              final isSelected = _selectedDisturbances.contains(d);
              final isNone = d == SleepDisturbance.none;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isNone) {
                      // Kalau pilih "Tidak Ada Gangguan", clear yang lain
                      _selectedDisturbances.clear();
                      _selectedDisturbances.add(d);
                    } else {
                      // Kalau pilih gangguan lain, hapus "Tidak Ada"
                      _selectedDisturbances.remove(SleepDisturbance.none);
                      if (isSelected) {
                        _selectedDisturbances.remove(d);
                      } else {
                        _selectedDisturbances.add(d);
                      }
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isNone
                            ? AppColors.success.withOpacity(0.08)
                            : AppColors.danger.withOpacity(0.08))
                        : (isDark ? AppColors.darkCard : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (isNone ? AppColors.success : AppColors.danger)
                              .withOpacity(0.4)
                          : (isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        d.icon,
                        size: 18,
                        color: isSelected
                            ? (isNone ? AppColors.success : AppColors.danger)
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(d.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? (isNone
                                      ? AppColors.success
                                      : AppColors.danger)
                                  : (isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText),
                            )),
                      ),
                      if (isSelected)
                        Icon(
                          isNone
                              ? Icons.check_circle_rounded
                              : Icons.check_circle_rounded,
                          size: 18,
                          color: isNone ? AppColors.success : AppColors.danger,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Simpan
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF9F67FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedQuality == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pilih kualitas tidur dulu ya'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                      return;
                    }
                    var bed = _toDateTime(_bedTime);
                    var wake = _toDateTime(_wakeTime);
                    if (wake.isBefore(bed)) {
                      wake = wake.add(const Duration(days: 1));
                    }
                    widget.onSave(
                      bed,
                      wake,
                      _selectedQuality,
                      _selectedDisturbances.toList(),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final TimeOfDay time;
  final bool isDark;
  final VoidCallback onTap;

  const _TimePicker({
    required this.label,
    required this.icon,
    required this.time,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF7C3AED), size: 22),
            const SizedBox(height: 8),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
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
    );
  }
}

// ─── Mood Card ─────────────────────────────────────────────────────────────
class _MoodCard extends StatelessWidget {
  final MoodRecord? mood;
  final bool isDark;
  final VoidCallback onInput;

  const _MoodCard({
    required this.mood,
    required this.isDark,
    required this.onInput,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onInput,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mood != null
                ? mood!.mood.color.withOpacity(0.3)
                : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
            width: 1.5,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: (mood?.mood.color ?? AppColors.primary)
                        .withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (mood?.mood.color ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  mood?.mood.emoji ?? '🎭',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: mood == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mood Harian',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                        Text(
                          'Tap untuk isi mood hari ini',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              mood!.mood.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: mood!.mood.color,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: mood!.mood.isNegative
                                    ? AppColors.danger.withOpacity(0.1)
                                    : AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                mood!.mood.isNegative
                                    ? 'Perlu Perhatian'
                                    : 'Positif',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: mood!.mood.isNegative
                                      ? AppColors.danger
                                      : AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (mood!.note != null)
                          Text(
                            mood!.note!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            'Mood Hari Ini',
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
            Icon(
              Icons.edit_outlined,
              size: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mood Reminder Dialog ──────────────────────────────────────────────────
class _MoodReminderDialog extends StatelessWidget {
  final VoidCallback onFill;
  final VoidCallback onSkip;

  const _MoodReminderDialog({
    required this.onFill,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Text('🎭', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bagaimana Perasaanmu?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu belum mengisi mood hari ini. Yuk ceritakan perasaanmu sekarang!',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Isi Sekarang',
              onPressed: onFill,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Nanti Saja',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mood Input Bottom Sheet ───────────────────────────────────────────────
class _MoodInputSheet extends StatefulWidget {
  final Function(MoodType mood, String? note) onSave;

  const _MoodInputSheet({required this.onSave});

  @override
  State<_MoodInputSheet> createState() => _MoodInputSheetState();
}

class _MoodInputSheetState extends State<_MoodInputSheet> {
  MoodType? _selectedMood;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Center(
              child: Text(
                'Bagaimana Perasaanmu Hari Ini?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Pilih mood yang paling sesuai',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mood grid
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: MoodType.values.map((mood) {
                final isSelected = _selectedMood == mood;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? mood.color.withOpacity(0.12)
                          : (isDark
                              ? AppColors.darkCard
                              : AppColors.lightBackground),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? mood.color
                            : (isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 4),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected
                                ? mood.color
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Selected mood info
            if (_selectedMood != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _selectedMood!.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedMood!.color.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(_selectedMood!.emoji,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedMood!.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _selectedMood!.color,
                            ),
                          ),
                          Text(
                            _selectedMood!.isNegative
                                ? 'Mood ini akan dipantau oleh sistem'
                                : 'Pertahankan mood positif ini!',
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
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Catatan opsional
            Text(
              'Catatan (Opsional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              decoration: InputDecoration(
                hintText: 'Ceritakan lebih lanjut perasaanmu...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Simpan
            GradientButton(
              text: 'Simpan Mood',
              onPressed: _selectedMood == null
                  ? () {}
                  : () {
                      widget.onSave(
                        _selectedMood!,
                        _noteController.text.isEmpty
                            ? null
                            : _noteController.text,
                      );
                      Navigator.pop(context);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final bool isDark;
  const _EmptyChart({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 36,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada data',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
