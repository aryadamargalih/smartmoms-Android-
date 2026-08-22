import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _loading = true;

  bool _allNotifications = true;
  bool _bpmAlert = true;
  bool _bloodPressureAlert = true;
  bool _activityReminder = true;
  bool _medicineReminder = false;
  bool _checkupReminder = true;

  TimeOfDay _activityTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _medicineTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allNotifications = prefs.getBool(NotifPrefsKeys.all) ?? true;
      _bpmAlert = prefs.getBool(NotifPrefsKeys.bpmAlert) ?? true;
      _bloodPressureAlert = prefs.getBool(NotifPrefsKeys.bpAlert) ?? true;
      _activityReminder =
          prefs.getBool(NotifPrefsKeys.activityReminder) ?? true;
      _medicineReminder =
          prefs.getBool(NotifPrefsKeys.vitaminReminder) ?? false;
      _checkupReminder = prefs.getBool(NotifPrefsKeys.checkupReminder) ?? true;
      _activityTime =
          _parseTime(prefs.getString(NotifPrefsKeys.activityTime)) ??
              _activityTime;
      _medicineTime = _parseTime(prefs.getString(NotifPrefsKeys.vitaminTime)) ??
          _medicineTime;
      _loading = false;
    });
  }

  TimeOfDay? _parseTime(String? raw) {
    if (raw == null || !raw.contains(':')) return null;
    final p = raw.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveTime(String key, TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, _formatTime(time));
  }

  Future<void> _onAllChanged(bool v) async {
    setState(() {
      _allNotifications = v;
      if (!v) {
        _bpmAlert = false;
        _bloodPressureAlert = false;
        _activityReminder = false;
        _medicineReminder = false;
        _checkupReminder = false;
      }
    });
    await _saveBool(NotifPrefsKeys.all, v);
    if (!v) {
      await _saveBool(NotifPrefsKeys.bpmAlert, false);
      await _saveBool(NotifPrefsKeys.bpAlert, false);
      await _saveBool(NotifPrefsKeys.activityReminder, false);
      await _saveBool(NotifPrefsKeys.vitaminReminder, false);
      await _saveBool(NotifPrefsKeys.checkupReminder, false);
      await NotificationService.instance.cancel(NotifIds.activityReminder);
      await NotificationService.instance.cancel(NotifIds.vitaminReminder);
    } else {
      if (_activityReminder) await _scheduleActivity();
      if (_medicineReminder) await _scheduleVitamin();
    }
  }

  Future<void> _onBpmAlertChanged(bool v) async {
    setState(() => _bpmAlert = v);
    await _saveBool(NotifPrefsKeys.bpmAlert, v);
  }

  Future<void> _onBpAlertChanged(bool v) async {
    setState(() => _bloodPressureAlert = v);
    await _saveBool(NotifPrefsKeys.bpAlert, v);
  }

  Future<void> _onActivityChanged(bool v) async {
    setState(() => _activityReminder = v);
    await _saveBool(NotifPrefsKeys.activityReminder, v);
    if (v) {
      await _scheduleActivity();
    } else {
      await NotificationService.instance.cancel(NotifIds.activityReminder);
    }
  }

  Future<void> _onVitaminChanged(bool v) async {
    setState(() => _medicineReminder = v);
    await _saveBool(NotifPrefsKeys.vitaminReminder, v);
    if (v) {
      await _scheduleVitamin();
    } else {
      await NotificationService.instance.cancel(NotifIds.vitaminReminder);
    }
  }

  Future<void> _onCheckupChanged(bool v) async {
    setState(() => _checkupReminder = v);
    await _saveBool(NotifPrefsKeys.checkupReminder, v);
    // Catatan: belum ada sumber tanggal checkup dari API,
    // jadi ini baru tersimpan sebagai preferensi (belum ada jadwal otomatis).
  }

  Future<void> _scheduleActivity() async {
    await NotificationService.instance.scheduleDaily(
      id: NotifIds.activityReminder,
      title: 'Waktunya Bergerak 🚶‍♀️',
      body: 'Yuk lakukan aktivitas fisik ringan hari ini.',
      time: _activityTime,
    );
  }

  Future<void> _scheduleVitamin() async {
    await NotificationService.instance.scheduleDaily(
      id: NotifIds.vitaminReminder,
      title: 'Waktunya Minum Vitamin 💊',
      body: 'Jangan lupa minum vitamin kehamilan/nifas kamu.',
      time: _medicineTime,
    );
  }

  Future<void> _pickTime(
      TimeOfDay current, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

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
                    onChanged: _onAllChanged,
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
                  subtitle: 'Notifikasi jika BPM di luar 60-100',
                  value: _bpmAlert && _allNotifications,
                  onChanged: _allNotifications ? _onBpmAlertChanged : null,
                  isDark: isDark,
                ),
                _Divider(isDark: isDark),
                _NotifTile(
                  icon: Icons.monitor_heart_rounded,
                  iconColor: AppColors.primary,
                  title: 'Alert Tekanan Darah',
                  subtitle: 'Notifikasi jika TD ≥140/90 atau sistolik <90',
                  value: _bloodPressureAlert && _allNotifications,
                  onChanged: _allNotifications ? _onBpAlertChanged : null,
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
                  onChanged: _allNotifications ? _onActivityChanged : null,
                  isDark: isDark,
                  trailing: _activityReminder && _allNotifications
                      ? _TimeChip(
                          time: _activityTime,
                          onTap: () => _pickTime(_activityTime, (t) async {
                            setState(() => _activityTime = t);
                            await _saveTime(NotifPrefsKeys.activityTime, t);
                            if (_activityReminder) await _scheduleActivity();
                          }),
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
                  onChanged: _allNotifications ? _onVitaminChanged : null,
                  isDark: isDark,
                  trailing: _medicineReminder && _allNotifications
                      ? _TimeChip(
                          time: _medicineTime,
                          onTap: () => _pickTime(_medicineTime, (t) async {
                            setState(() => _medicineTime = t);
                            await _saveTime(NotifPrefsKeys.vitaminTime, t);
                            if (_medicineReminder) await _scheduleVitamin();
                          }),
                        )
                      : null,
                ),
                _Divider(isDark: isDark),
                _NotifTile(
                  icon: Icons.local_hospital_outlined,
                  iconColor: AppColors.success,
                  title: 'Pengingat Pemeriksaan',
                  subtitle: 'Preferensi tersimpan (jadwal otomatis belum ada)',
                  value: _checkupReminder && _allNotifications,
                  onChanged: _allNotifications ? _onCheckupChanged : null,
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

// ─── Widget Pendukung (SAMA seperti file lama, tidak ada perubahan) ───────
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
