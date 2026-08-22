class QuestionnaireModel {
  final String id;
  final String category;
  final String description;
  final int questionsCount;
  final List<QuestionModel> questions;

  QuestionnaireModel({
    required this.id,
    required this.category,
    required this.description,
    required this.questionsCount,
    required this.questions,
  });
}

class QuestionModel {
  final String id;
  final String question;
  final List<AnswerOption> options;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
  });
}

class AnswerOption {
  final int value;
  final String label;
  final String emoji;

  AnswerOption({required this.value, required this.label, required this.emoji});
}
