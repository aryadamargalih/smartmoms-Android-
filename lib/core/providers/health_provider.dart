import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class HealthSummary {
  final int? bpm;
  final int? systolic;
  final int? diastolic;
  final int? steps;
  final DateTime? recordedAt;

  HealthSummary({
    this.bpm,
    this.systolic,
    this.diastolic,
    this.steps,
    this.recordedAt,
  });

  factory HealthSummary.fromJson(Map<String, dynamic> json) {
    return HealthSummary(
      bpm: json['bpm'],
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      steps: json['steps'],
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'])
          : null,
    );
  }
}

class HealthChartData {
  final DateTime date;
  final int? bpm;
  final int? systolic;
  final int? diastolic;
  final int? steps;

  HealthChartData({
    required this.date,
    this.bpm,
    this.systolic,
    this.diastolic,
    this.steps,
  });

  factory HealthChartData.fromJson(Map<String, dynamic> json) {
    return HealthChartData(
      date: DateTime.parse(json['recorded_at']),
      bpm: json['bpm'],
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      steps: json['steps'],
    );
  }
}

class HealthProvider extends ChangeNotifier {
  HealthSummary? _summary;
  List<HealthChartData> _bpmChartData = [];
  List<HealthChartData> _bpChartData = [];
  List<HealthChartData> _activityChartData = [];
  bool _isLoading = false;
  String? _errorMessage;

  HealthSummary? get summary => _summary;
  List<HealthChartData> get bpmChartData => _bpmChartData;
  List<HealthChartData> get bpChartData => _bpChartData;
  List<HealthChartData> get activityChartData => _activityChartData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Fetch summary hari ini ──────────────────────────────────────────
  Future<void> fetchSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.get('/health-data/summary');

    _isLoading = false;

    if (response['success'] == true) {
      _summary = HealthSummary.fromJson(response['data']);
      await _checkHealthAlerts(_summary!); 
    } else {
      _errorMessage = response['message'];
    }
    notifyListeners();
  }

  // ── Cek ambang batas & kirim notifikasi lokal jika abnormal ──────────
  Future<void> _checkHealthAlerts(HealthSummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    final allOn = prefs.getBool(NotifPrefsKeys.all) ?? true;
    if (!allOn) return;

    const cooldown = Duration(minutes: 30); // biar ga spam tiap fetch
    final now = DateTime.now();

    // BPM: normal 60-100
    final bpmOn = prefs.getBool(NotifPrefsKeys.bpmAlert) ?? true;
    if (bpmOn &&
        summary.bpm != null &&
        (summary.bpm! < 60 || summary.bpm! > 100)) {
      final last = DateTime.tryParse(
          prefs.getString(NotifPrefsKeys.lastBpmAlertAt) ?? '');
      if (last == null || now.difference(last) > cooldown) {
        await NotificationService.instance.showInstant(
          id: NotifIds.bpmAlert,
          title: 'Detak Jantung Tidak Normal ⚠️',
          body:
              'BPM kamu saat ini ${summary.bpm} bpm, di luar rentang normal (60-100 bpm).',
        );
        await prefs.setString(
            NotifPrefsKeys.lastBpmAlertAt, now.toIso8601String());
      }
    }

    // Tekanan darah: hipertensi ≥140/90, hipotensi sistolik <90
    final bpOn = prefs.getBool(NotifPrefsKeys.bpAlert) ?? true;
    if (bpOn && summary.systolic != null && summary.diastolic != null) {
      final sys = summary.systolic!;
      final dia = summary.diastolic!;
      final isAbnormal = sys >= 140 || dia >= 90 || sys < 90;
      if (isAbnormal) {
        final last = DateTime.tryParse(
            prefs.getString(NotifPrefsKeys.lastBpAlertAt) ?? '');
        if (last == null || now.difference(last) > cooldown) {
          await NotificationService.instance.showInstant(
            id: NotifIds.bpAlert,
            title: 'Tekanan Darah Tidak Normal ⚠️',
            body: 'Tekanan darah kamu $sys/$dia mmHg, di luar rentang normal.',
          );
          await prefs.setString(
              NotifPrefsKeys.lastBpAlertAt, now.toIso8601String());
        }
      }
    }
  }

  // ── Fetch chart data per jenis (independen satu sama lain) ──────────
  Future<void> fetchBpmChartData({String period = 'week'}) async {
    final response = await ApiService.get('/health-data?period=$period');
    if (response['success'] == true) {
      _bpmChartData = (response['data'] as List)
          .map((e) => HealthChartData.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  Future<void> fetchBpChartData({String period = 'week'}) async {
    final response = await ApiService.get('/health-data?period=$period');
    if (response['success'] == true) {
      _bpChartData = (response['data'] as List)
          .map((e) => HealthChartData.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  Future<void> fetchActivityChartData({String period = 'week'}) async {
    final response = await ApiService.get('/health-data?period=$period');
    if (response['success'] == true) {
      _activityChartData = (response['data'] as List)
          .map((e) => HealthChartData.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  // ── Refresh semua ───────────────────────────────────────────────────
  Future<void> refreshAll() async {
    await Future.wait([
      fetchSummary(),
      fetchBpmChartData(),
      fetchBpChartData(),
      fetchActivityChartData(),
    ]);
  }
}
