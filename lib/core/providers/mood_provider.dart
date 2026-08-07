import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../../features/mood/mood_tracker.dart';

class MoodProvider extends ChangeNotifier {
  MoodRecord? _todayMood;
  List<MoodRecord> _moodHistory = [];
  bool _isLoading = false;

  MoodRecord? get todayMood => _todayMood;
  List<MoodRecord> get moodHistory => _moodHistory;
  bool get isLoading => _isLoading;

  // ── Fetch mood hari ini ─────────────────────────────────────────────
  Future<void> fetchToday() async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.get('/mood/today');

    _isLoading = false;

    if (response['success'] == true && response['data'] != null) {
      _todayMood = _fromJson(response['data']);
    } else {
      _todayMood = null;
    }
    notifyListeners();
  }

  // ── Fetch history ───────────────────────────────────────────────────
  Future<void> fetchHistory({String period = 'week'}) async {
    final response = await ApiService.get('/mood?period=$period');

    if (response['success'] == true) {
      _moodHistory =
          (response['data'] as List).map((e) => _fromJson(e)).toList();
      notifyListeners();
    }
  }

  // ── Submit mood ─────────────────────────────────────────────────────
  Future<bool> submitMood({
    required MoodType mood,
    String? note,
  }) async {
    final response = await ApiService.post('/mood', body: {
      'mood': mood.name,
      'note': note,
    });

    if (response['success'] == true) {
      _todayMood = _fromJson(response['data']);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── Parse JSON ──────────────────────────────────────────────────────
  MoodRecord _fromJson(Map<String, dynamic> json) {
    final moodType = MoodType.values.firstWhere(
      (e) => e.name == json['mood'],
      orElse: () => MoodType.calm,
    );

    return MoodRecord(
      id: json['id'].toString(),
      date: DateTime.parse(json['date']),
      mood: moodType,
      note: json['note'],
    );
  }
}
