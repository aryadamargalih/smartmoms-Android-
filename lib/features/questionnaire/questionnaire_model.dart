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

// Default skala 1-5
final List<AnswerOption> defaultOptions = [
  AnswerOption(value: 1, label: 'Tidak Pernah', emoji: '😞'),
  AnswerOption(value: 2, label: 'Jarang', emoji: '😕'),
  AnswerOption(value: 3, label: 'Kadang-kadang', emoji: '😐'),
  AnswerOption(value: 4, label: 'Sering', emoji: '🙂'),
  AnswerOption(value: 5, label: 'Selalu', emoji: '😊'),
];

// Dummy data — nanti diganti dari API
final List<QuestionnaireModel> dummyQuestionnaires = [
  QuestionnaireModel(
    id: 'q1',
    category: 'Kesehatan Fisik',
    description: 'Kuesioner Edinburgh untuk deteksi depresi pasca melahirkan',
    questionsCount: 5,
    questions: [
      QuestionModel(
        id: 'q1_1',
        question:
            'Apakah kamu rutin berolahraga ringan seperti jalan kaki setiap hari?',
        options: defaultOptions,
      ),
      QuestionModel(
        id: 'q1_2',
        question: 'Apakah kamu mengonsumsi vitamin kehamilan secara rutin?',
        options: defaultOptions,
      ),
      QuestionModel(
        id: 'q1_3',
        question: 'Apakah kamu tidur minimal 7-8 jam per malam?',
        options: defaultOptions,
      ),
      QuestionModel(
        id: 'q1_4',
        question: 'Apakah kamu minum air putih minimal 8 gelas per hari?',
        options: defaultOptions,
      ),
      QuestionModel(
        id: 'q1_5',
        question:
            'Apakah kamu rutin melakukan pemeriksaan kehamilan ke dokter/bidan?',
        options: defaultOptions,
      ),
    ],
  ),
  QuestionnaireModel(
    id: 'q2',
    category: 'Kesehatan Mental',
    description: 'Pertanyaan seputar kondisi emosional dan mental',
    questionsCount: 4,
    questions: [
      QuestionModel(
        id: 'q2_1',
        question:
            'Apakah kamu merasa tenang dan tidak cemas berlebihan tentang kehamilan?',
        options: defaultOptions,
      ),
      QuestionModel(
        id: 'q2_2',
        question:
            'Apakah kamu mendapat dukungan emosional dari keluarga atau pasangan?',
        options: defaultOptions,
      ),
      QuestionModel(
        id: 'q2_3',
        question: 'Apakah kamu dapat mengelola stres dengan baik sehari-hari?',
        options: defaultOptions,
      ),
      QuestionModel(
        id: 'q2_4',
        question:
            'Apakah kamu merasa bahagia dan bersemangat menjalani kehamilan?',
        options: defaultOptions,
      ),
    ],
  ),
  QuestionnaireModel(
    id: 'q3',
    category: 'Nutrisi & Pola Makan',
    description: 'Pertanyaan seputar asupan gizi selama kehamilan',
    questionsCount: 3,
    questions: [
      QuestionModel(
        id: 'q3_1',
        question:
            'Apakah kamu mengonsumsi makanan bergizi seimbang setiap hari?',
        options: defaultOptions,
      ),
      QuestionModel(
        id: 'q3_2',
        question:
            'Apakah kamu menghindari makanan yang tidak aman untuk ibu hamil?',
        options: defaultOptions,
      ),
      QuestionModel(
        id: 'q3_3',
        question: 'Apakah kamu rutin mengonsumsi buah dan sayuran setiap hari?',
        options: defaultOptions,
      ),
    ],
  ),
];
