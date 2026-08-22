import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../../features/sleep/sleep_tracker.dart';

class SleepProvider extends ChangeNotifier {
  SleepRecord? _todaySleep;
  List<SleepRecord> _sleepHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  SleepRecord? get todaySleep => _todaySleep;
  List<SleepRecord> get sleepHistory => _sleepHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Fetch tidur hari ini ────────────────────────────────────────────
  Future<void> fetchToday() async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.get('/sleep/today');

    _isLoading = false;

    if (response['success'] == true && response['data'] != null) {
      _todaySleep = _fromJson(response['data']);
    } else {
      _todaySleep = null;
    }
    notifyListeners();
  }

  // ── Fetch history ───────────────────────────────────────────────────
  Future<void> fetchHistory({String period = 'week'}) async {
    final response = await ApiService.get('/sleep?period=$period');

    if (response['success'] == true) {
      _sleepHistory =
          (response['data'] as List).map((e) => _fromJson(e)).toList();
      notifyListeners();
    }
  }

  // ── Submit tidur ────────────────────────────────────────────────────
  Future<bool> submitSleep({
    required DateTime bedTime,
    required DateTime wakeTime,
    SleepQuality? quality,
    List<SleepDisturbance> disturbances = const [],
  }) async {
    String hhmm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    const disturbanceApiValue = {
      SleepDisturbance.frequentWaking: 'frequent_waking',
      SleepDisturbance.difficultyFallingAsleep: 'difficulty_sleeping',
      SleepDisturbance.nightmare: 'nightmare',
      SleepDisturbance.nightSweats: 'night_sweats',
      SleepDisturbance.none: 'none',
    };

    final response = await ApiService.post('/sleep', body: {
      'bed_time': hhmm(bedTime),
      'wake_time': hhmm(wakeTime),
      'quality': quality?.value,
      'disturbances': disturbances.map((d) => disturbanceApiValue[d]).toList(),
    });

    if (response['success'] == true) {
      _todaySleep = _fromJson(response['data']);
      notifyListeners();
      return true;
    }
    print('[Sleep] submit failed: ${response['message']}, '
        'errors: ${response['errors']}');
    _errorMessage = response['message'];
    notifyListeners();
    return false;
  }

  // ── Parse JSON ──────────────────────────────────────────────────────
  SleepRecord _fromJson(Map<String, dynamic> json) {
    // Helper parse time string jadi DateTime
    DateTime parseTime(String? timeStr, DateTime baseDate) {
      if (timeStr == null) return baseDate;
      try {
        // Coba parse full datetime dulu
        return DateTime.parse(timeStr);
      } catch (e) {
        // Kalau gagal, berarti format HH:mm:ss
        final parts = timeStr.split(':');
        return DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          int.tryParse(parts[0]) ?? 0,
          int.tryParse(parts[1]) ?? 0,
          int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0,
        );
      }
    }

    final date = DateTime.parse(json['date']);
    final bedTime = parseTime(json['bed_time'], date);
    var wakeTime = parseTime(json['wake_time'], date);

    // Kalau wake time lebih awal dari bed time, berarti bangun keesokan harinya
    if (wakeTime.isBefore(bedTime)) {
      wakeTime = wakeTime.add(const Duration(days: 1));
    }

    // Parse quality
    SleepQuality? quality;
    if (json['quality'] != null) {
      final q = json['quality'] as int;
      quality = SleepQuality.values.firstWhere(
        (e) => e.value == q,
        orElse: () => SleepQuality.neutral,
      );
    }

    // Parse disturbances
    const disturbanceFromApi = {
      'frequent_waking': SleepDisturbance.frequentWaking,
      'difficulty_sleeping': SleepDisturbance.difficultyFallingAsleep,
      'nightmare': SleepDisturbance.nightmare,
      'night_sweats': SleepDisturbance.nightSweats,
      'none': SleepDisturbance.none,
    };
    List<SleepDisturbance> disturbances = [];
    if (json['disturbances'] != null) {
      final list = json['disturbances'] as List;
      disturbances = list
          .map((d) => disturbanceFromApi[d] ?? SleepDisturbance.none)
          .toList();
    }

    return SleepRecord(
      id: json['id'].toString(),
      bedTime: bedTime,
      wakeTime: wakeTime,
      date: date,
      quality: quality,
      disturbances: disturbances,
    );
  }
}
