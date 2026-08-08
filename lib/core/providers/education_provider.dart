import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../../features/education/education_model.dart';

class EducationProvider extends ChangeNotifier {
  List<EducationArticle> _articles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EducationArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Fetch articles ──────────────────────────────────────────────────
  Future<void> fetchArticles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.get('/education');

    _isLoading = false;

    if (response['success'] == true) {
      final data = response['data'];
      final List articles = data['articles'] ?? [];

      _articles = articles.map((a) => _fromJson(a)).toList();
    } else {
      _errorMessage = response['message'];
    }

    notifyListeners();
  }

  EducationCategory _parseCategory(String? cat) {
    if (cat == null) return EducationCategory.mentalHealth;

    final camelCase = cat.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (m) => m.group(1)!.toUpperCase(),
    );

    return EducationCategory.values.firstWhere(
      (c) => c.name == camelCase,
      orElse: () => EducationCategory.mentalHealth,
    );
  }

  // ── Parse JSON ──────────────────────────────────────────────────────
  EducationArticle _fromJson(Map<String, dynamic> json) {
    // Parse category
    final category = _parseCategory(json['category']);

    // Parse risk tags
    List<RiskTag> riskTags = [];
    if (json['risk_tags'] != null) {
      final tags = json['risk_tags'] as List;
      riskTags = tags.map((t) {
        return RiskTag.values.firstWhere(
          (r) => r.name == t,
          orElse: () => RiskTag.all,
        );
      }).toList();
    }
    if (riskTags.isEmpty) riskTags = [RiskTag.all];

    return EducationArticle(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      category: category,
      riskTags: riskTags,
      readMinutes: json['read_minutes'] ?? 5,
      isImportant: json['is_important'] ?? false,
    );
  }
}
