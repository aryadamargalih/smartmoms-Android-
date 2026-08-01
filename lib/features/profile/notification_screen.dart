import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Toggle state
  bool _allNotifications = true;
  bool _bpmAlert = true;
  bool _bloodPressureAlert = true;
  bool _activityReminder = true;
  bool _medicineReminder = false;
  bool _checkupReminder = true;
  bool _weeklyReport = true;
  bool _aiInsight = false;

  // Jam reminder
  TimeOfDay _activityTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _medicineTime = const TimeOfDay(hour: 8, minute: 0);

  Future<void> _pickTime(BuildContext context, TimeOfDay current,
      ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master toggle
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: _allNotifications
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _allNotifications
                    ? null
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(20),
                boxShadow: _allNotifications
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(_allNotifications ? 0.2 : 0.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      color:
                          _allNotifications ? Colors.white : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semua Notifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _allNotifications
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText),
                          ),
                        ),
                        Text(
                          _allNotifications ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            fontSize: 13,
                            color: _allNotifications
                                ? Colors.white.withOpacity(0.8)
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _allNotifications,
                    onChanged: (v) => setState(() {
                      _allNotifications = v;
                      if (!v) {
                        _bpmAlert = false;
                        _bloodPressureAlert = false;
                        _activityReminder = false;
                        _medicineReminder = false;
                        _checkupReminder = false;
                        _weeklyReport = false;
                        _aiInsight = false;
                      }
                    }),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Alert Kesehatan
            _SectionLabel(label: 'Alert Kesehatan', isDark: isDark),
            const SizedBox(height: 12),
            _NotifCard(
              isDark: isDark,
              children: [
                _NotifTile(
                  icon: Icons.favorite_rounded,
                  iconColor: AppColors.bpmColor,
                  title: 'Alert Detak Jantung',
                  subtitle: 'Notifikasi jika BPM tidak normal',
                  value: _bpmAlert && _allNotifications,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _bpmAlert = v)
                      : null,
                  isDark: isDark,
                ),
                _Divider(isDark: isDark),
                _NotifTile(
                  icon: Icons.monitor_heart_rounded,
                  iconColor: AppColors.primary,
                  title: 'Alert Tekanan Darah',
                  subtitle: 'Notifikasi jika TD di luar batas normal',
                  value: _bloodPressureAlert && _allNotifications,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _bloodPressureAlert = v)
                      : null,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Pengingat Harian
            _SectionLabel(label: 'Pengingat Harian', isDark: isDark),
            const SizedBox(height: 12),
            _NotifCard(
              isDark: isDark,
              children: [
                _NotifTile(
                  icon: Icons.directions_walk_rounded,
                  iconColor: AppColors.activityColor,
                  title: 'Pengingat Aktivitas',
                  subtitle: 'Ingatkan untuk bergerak setiap hari',
                  value: _activityReminder && _allNotifications,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _activityReminder = v)
                      : null,
                  isDark: isDark,
                  trailing: _activityReminder && _allNotifications
                      ? _TimeChip(
                          time: _activityTime,
                          onTap: () => _pickTime(
                            context,
                            _activityTime,
                            (t) => setState(() => _activityTime = t),
                          ),
                        )
                      : null,
                ),
                _Divider(isDark: isDark),
                _NotifTile(
                  icon: Icons.medication_outlined,
                  iconColor: AppColors.accent,
                  title: 'Pengingat Vitamin',
                  subtitle: 'Ingatkan minum vitamin kehamilan',
                  value: _medicineReminder && _allNotifications,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _medicineReminder = v)
                      : null,
                  isDark: isDark,
                  trailing: _medicineReminder && _allNotifications
                      ? _TimeChip(
                          time: _medicineTime,
                          onTap: () => _pickTime(
                            context,
                            _medicineTime,
                            (t) => setState(() => _medicineTime = t),
                          ),
                        )
                      : null,
                ),
                _Divider(isDark: isDark),
                _NotifTile(
                  icon: Icons.local_hospital_outlined,
                  iconColor: AppColors.success,
                  title: 'Pengingat Pemeriksaan',
                  subtitle: 'Ingatkan jadwal kontrol ke dokter',
                  value: _checkupReminder && _allNotifications,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _checkupReminder = v)
                      : null,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Laporan & AI
            _SectionLabel(label: 'Laporan & AI', isDark: isDark),
            const SizedBox(height: 12),
            _NotifCard(
              isDark: isDark,
              children: [
                _NotifTile(
                  icon: Icons.bar_chart_rounded,
                  iconColor: AppColors.primary,
                  title: 'Laporan Mingguan',
                  subtitle: 'Ringkasan kesehatan setiap minggu',
                  value: _weeklyReport && _allNotifications,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _weeklyReport = v)
                      : null,
                  isDark: isDark,
                ),
                _Divider(isDark: isDark),
                _NotifTile(
                  icon: Icons.auto_awesome_rounded,
                  iconColor: AppColors.accent,
                  title: 'Insight dari AI',
                  subtitle: 'Saran kesehatan otomatis dari AI',
                  value: _aiInsight && _allNotifications,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _aiInsight = v)
                      : null,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Widget Pendukung ──────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _NotifCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _NotifCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDark;
  final Widget? trailing;

  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onChanged == null
                          ? (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)
                          : (isDark ? AppColors.darkText : AppColors.lightText),
                    )),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    )),
                if (trailing != null) ...[
                  const SizedBox(height: 6),
                  trailing!,
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeChip({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time_rounded,
                size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }
}
