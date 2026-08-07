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
    final response = await ApiService.post('/sleep', body: {
      'bed_time': bedTime.toIso8601String(),
      'wake_time': wakeTime.toIso8601String(),
      'quality': quality?.value,
      'disturbances': disturbances.map((d) => d.name).toList(),
    });

    if (response['success'] == true) {
      _todaySleep = _fromJson(response['data']);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── Parse JSON ──────────────────────────────────────────────────────
  SleepRecord _fromJson(Map<String, dynamic> json) {
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
    List<SleepDisturbance> disturbances = [];
    if (json['disturbances'] != null) {
      final list = json['disturbances'] as List;
      disturbances = list.map((d) {
        return SleepDisturbance.values.firstWhere(
          (e) => e.name == d,
          orElse: () => SleepDisturbance.none,
        );
      }).toList();
    }

    return SleepRecord(
      id: json['id'].toString(),
      bedTime: DateTime.parse(json['bed_time']),
      wakeTime: DateTime.parse(json['wake_time']),
      date: DateTime.parse(json['date']),
      quality: quality,
      disturbances: disturbances,
    );
  }
}
