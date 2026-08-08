import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuestionnaireModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final int questionsCount;
  final List<QuestionModel> questions;

  QuestionnaireModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.questionsCount,
    this.questions = const [],
  });

  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      questionsCount: json['questions_count'] ?? 0,
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => QuestionModel.fromJson(q))
              .toList()
          : [],
    );
  }
}

class QuestionModel {
  final int id;
  final String question;
  final List<AnswerOptionModel> options;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      question: json['question'],
      options: json['answer_options'] != null
          ? (json['answer_options'] as List)
              .map((o) => AnswerOptionModel.fromJson(o))
              .toList()
          : [],
    );
  }
}

class AnswerOptionModel {
  final int id;
  final String label;
  final String emoji;
  final int value;

  AnswerOptionModel({
    required this.id,
    required this.label,
    required this.emoji,
    required this.value,
  });

  factory AnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return AnswerOptionModel(
      id: json['id'],
      label: json['label'],
      emoji: json['emoji'] ?? '😐', // fallback emoji kalau null
      value: json['value'],
    );
  }
}

class QuestionnaireResult {
  final int id;
  final int questionnaireId;
  final String questionnaireTitle;
  final int totalScore;
  final int maxScore;
  final DateTime submittedAt;
  final Map<int, int> answers; // questionId: value

  QuestionnaireResult({
    required this.id,
    required this.questionnaireId,
    required this.questionnaireTitle,
    required this.totalScore,
    required this.maxScore,
    required this.submittedAt,
    required this.answers,
  });

  double get percentage => totalScore / maxScore;

  String get scoreCategory {
    if (percentage >= 0.8) return 'Sangat Baik';
    if (percentage >= 0.6) return 'Baik';
    if (percentage >= 0.4) return 'Cukup';
    return 'Perlu Perhatian';
  }

  factory QuestionnaireResult.fromJson(Map<String, dynamic> json) {
    final answersMap = <int, int>{};
    if (json['question_answers'] != null) {
      for (final a in json['question_answers'] as List) {
        answersMap[a['question_id']] = a['value'];
      }
    }

    return QuestionnaireResult(
      id: json['id'],
      questionnaireId: json['questionnaire_id'],
      questionnaireTitle: json['questionnaire']?['title'] ?? '',
      totalScore: json['total_score'],
      maxScore: json['max_score'],
      submittedAt: DateTime.parse(json['submitted_at']),
      answers: answersMap,
    );
  }
}

class QuestionnaireProvider extends ChangeNotifier {
  List<QuestionnaireModel> _questionnaires = [];
  QuestionnaireModel? _activeQuestionnaire;
  List<QuestionnaireResult> _results = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<QuestionnaireModel> get questionnaires => _questionnaires;
  QuestionnaireModel? get activeQuestionnaire => _activeQuestionnaire;
  List<QuestionnaireResult> get results => _results;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // ── Fetch list kuesioner ────────────────────────────────────────────
  Future<void> fetchQuestionnaires() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.get('/questionnaires');

    _isLoading = false;
    if (response['success'] == true) {
      _questionnaires = (response['data'] as List)
          .map((q) => QuestionnaireModel.fromJson(q))
          .toList();
    } else {
      _errorMessage = response['message'];
    }
    notifyListeners();
  }

  // ── Fetch soal per kuesioner ────────────────────────────────────────
  Future<void> fetchQuestions(int questionnaireId) async {
    _isLoading = true;
    notifyListeners();

    final response =
        await ApiService.get('/questionnaires/$questionnaireId/questions');

    _isLoading = false;

    if (response['success'] == true) {
      _activeQuestionnaire = QuestionnaireModel.fromJson(response['data']);
    }
    notifyListeners();
  }

  // ── Submit jawaban ──────────────────────────────────────────────────
  Future<QuestionnaireResult?> submitAnswers({
    required int questionnaireId,
    required Map<String, int> answers, // questionId: value
  }) async {
    _isSubmitting = true;
    notifyListeners();

    final response = await ApiService.post(
      '/questionnaires/$questionnaireId/submit',
      body: {'answers': answers},
    );

    _isSubmitting = false;

    if (response['success'] == true) {
      final result = QuestionnaireResult.fromJson(response['data']);
      notifyListeners();
      return result;
    }
    notifyListeners();
    return null;
  }

  // ── Fetch hasil kuesioner ───────────────────────────────────────────
  Future<void> fetchResults(int questionnaireId) async {
    final response =
        await ApiService.get('/questionnaires/$questionnaireId/results');

    if (response['success'] == true) {
      _results = (response['data'] as List)
          .map((r) => QuestionnaireResult.fromJson(r))
          .toList();
      notifyListeners();
    }
  }
}
