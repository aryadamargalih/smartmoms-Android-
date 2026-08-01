import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  List<HealthChartData> _chartData = [];
  bool _isLoading = false;
  String? _errorMessage;

  HealthSummary? get summary => _summary;
  List<HealthChartData> get chartData => _chartData;
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
    } else {
      _errorMessage = response['message'];
    }
    notifyListeners();
  }

  // ── Fetch chart data ────────────────────────────────────────────────
  Future<void> fetchChartData({String period = 'week'}) async {
    final response = await ApiService.get('/health-data?period=$period');

    if (response['success'] == true) {
      _chartData = (response['data'] as List)
          .map((e) => HealthChartData.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  // ── Refresh semua ───────────────────────────────────────────────────
  Future<void> refreshAll() async {
    await Future.wait([
      fetchSummary(),
      fetchChartData(),
    ]);
  }
}
