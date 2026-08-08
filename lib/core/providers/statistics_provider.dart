import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StatisticsSummary {
  final double avgBpm;
  final double avgSystolic;
  final double avgDiastolic;
  final int totalSteps;
  final double avgSleep;
  final int totalQuestionnaires;

  StatisticsSummary({
    required this.avgBpm,
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.totalSteps,
    required this.avgSleep,
    required this.totalQuestionnaires,
  });

  factory StatisticsSummary.fromJson(Map<String, dynamic> json) {
    return StatisticsSummary(
      avgBpm: (json['avg_bpm'] ?? 0).toDouble(),
      avgSystolic: (json['avg_systolic'] ?? 0).toDouble(),
      avgDiastolic: (json['avg_diastolic'] ?? 0).toDouble(),
      totalSteps: json['total_steps'] ?? 0,
      avgSleep: (json['avg_sleep'] ?? 0).toDouble(),
      totalQuestionnaires: json['total_questionnaires'] ?? 0,
    );
  }
}

class HealthHistoryItem {
  final DateTime date;
  final int? bpm;
  final int? systolic;
  final int? diastolic;
  final int? steps;

  HealthHistoryItem({
    required this.date,
    this.bpm,
    this.systolic,
    this.diastolic,
    this.steps,
  });

  factory HealthHistoryItem.fromJson(Map<String, dynamic> json) {
    return HealthHistoryItem(
      date: DateTime.parse(json['recorded_at']),
      bpm: json['bpm'],
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      steps: json['steps'],
    );
  }
}

class StatisticsProvider extends ChangeNotifier {
  StatisticsSummary? _summary;
  List<HealthHistoryItem> _healthHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentPeriod = 'week';

  StatisticsSummary? get summary => _summary;
  List<HealthHistoryItem> get healthHistory => _healthHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentPeriod => _currentPeriod;

  // ── Fetch semua data statistik ──────────────────────────────────────
  Future<void> fetchAll({String period = 'week'}) async {
    _isLoading = true;
    _currentPeriod = period;
    _errorMessage = null;
    notifyListeners();

    await Future.wait([
      _fetchSummary(period),
      _fetchHealthHistory(period),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchSummary(String period) async {
    final response =
        await ApiService.get('/health-data/summary?period=$period');
    if (response['success'] == true) {
      _summary = StatisticsSummary.fromJson(response['data']);
    }
  }

  Future<void> _fetchHealthHistory(String period) async {
    final response = await ApiService.get('/health-data?period=$period');
    if (response['success'] == true) {
      _healthHistory = (response['data'] as List)
          .map((e) => HealthHistoryItem.fromJson(e))
          .toList();
    }
  }
}
