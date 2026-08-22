import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/questionnaire_provider.dart' as qp;
import '../../core/services/api_service.dart';

// 7 pertanyaan kualitatif hardcode
const List<Map<String, dynamic>> _qualitativeQuestions = [
  {
    'number': 1,
    'question':
        'Sebelum menggunakan SmartMoms, bagaimana Ibu memahami atau memandang depresi postpartum?',
  },
  {
    'number': 2,
    'question':
        'Bagaimana pengalaman Ibu selama menggunakan aplikasi SmartMoms dan smartwatch?',
  },
  {
    'number': 3,
    'question':
        'Setelah menggunakan SmartMoms, apakah ada perubahan dalam cara Ibu memahami kondisi emosional selama masa nifas?',
  },
  {
    'number': 4,
    'question':
        'Menurut Ibu, manfaat apa yang paling dirasakan dari penggunaan SmartMoms dan smartwatch?',
  },
  {
    'number': 5,
    'question':
        'Apakah SmartMoms sesuai dengan kebutuhan Ibu selama masa nifas? Mengapa?',
  },
  {
    'number': 6,
    'question': 'Apa saja kendala yang Ibu alami selama menggunakan SmartMoms?',
  },
  {
    'number': 7,
    'question':
        'Menurut Ibu, apa yang perlu diperbaiki agar SmartMoms menjadi lebih baik?',
  },
];

class CsqScreen extends StatefulWidget {
  final int questionnaireId;
  final String title;

  const CsqScreen({
    super.key,
    required this.questionnaireId,
    required this.title,
  });

  @override
  State<CsqScreen> createState() => _CsqScreenState();
}

class _CsqScreenState extends State<CsqScreen> {
  int _step = 0; // 0: loading, 1: CSQ-8, 2: kualitatif, 3: hasil
  bool _isLoading = true;
  bool _isSubmitting = false;

  // CSQ-8
  List<qp.QuestionModel> _questions = [];
  final Map<int, int> _answers = {}; // questionId: value
  final TextEditingController _commentController = TextEditingController();

  // Kualitatif
  final List<TextEditingController> _qualitativeControllers =
      List.generate(7, (_) => TextEditingController());

  // Hasil
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _commentController.dispose();
    for (final c in _qualitativeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    final response = await ApiService.get(
        '/questionnaires/${widget.questionnaireId}/questions');

    if (mounted) {
      if (response['success'] == true) {
        final data = response['data'];
        final questionsList = data['questions'] ?? data;
        setState(() {
          _questions = (questionsList as List)
              .map((q) => qp.QuestionModel.fromJson(q))
              .toList();
          _isLoading = false;
          _step = 1;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  bool get _allAnswered => _questions.every((q) => _answers.containsKey(q.id));

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final qualitativeResponses = _qualitativeQuestions
        .asMap()
        .entries
        .where((e) => _qualitativeControllers[e.key].text.trim().isNotEmpty)
        .map((e) => {
              'question_number': e.value['number'],
              'question': e.value['question'],
              'answer': _qualitativeControllers[e.key].text.trim(),
            })
        .toList();

    final response = await ApiService.post(
      '/questionnaires/${widget.questionnaireId}/submit',
      body: {
        'answers': _answers.entries
            .map((e) => {'question_id': e.key, 'value': e.value})
            .toList(),
        'comment': _commentController.text,
        'qualitative_responses': qualitativeResponses,
      },
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (response['success'] == true) {
        setState(() {
          _result = response['data'];
          _step = 3;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal submit'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (_step == 2) {
              setState(() => _step = 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _step == 1
              ? _buildCsqStep(isDark)
              : _step == 2
                  ? _buildQualitativeStep(isDark)
                  : _buildResult(isDark),
    );
  }

  // ─── Step Indicator ────────────────────────────────────────────────
  Widget _buildStepIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Step 1
          _StepDot(
            number: 1,
            label: 'CSQ-8',
            isActive: _step >= 1,
            isDark: isDark,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: _step >= 2
                  ? AppColors.primary
                  : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
            ),
          ),
          // Step 2
          _StepDot(
            number: 2,
            label: 'Kualitatif',
            isActive: _step >= 2,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ─── Step 1: CSQ-8 ────────────────────────────────────────────────
  Widget _buildCsqStep(bool isDark) {
    return Column(
      children: [
        _buildStepIndicator(isDark),
        const SizedBox(height: 16),

        // Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_answers.length} dari ${_questions.length} soal dijawab',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${((_answers.length / (_questions.isEmpty ? 1 : _questions.length)) * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _answers.length /
                  (_questions.isEmpty ? 1 : _questions.length),
              backgroundColor:
                  isDark ? AppColors.darkDivider : AppColors.lightDivider,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Soal
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _questions.length + 1, // +1 untuk kolom komentar
            itemBuilder: (_, i) {
              if (i == _questions.length) {
                // Kolom komentar di bawah semua soal
                return _buildCommentField(isDark);
              }

              final q = _questions[i];
              final selected = _answers[q.id];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected != null
                        ? AppColors.primary.withOpacity(0.3)
                        : (isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider),
                    width: selected != null ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nomor soal
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Soal ${i + 1}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (selected != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Pertanyaan
                    Text(
                      q.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pilihan jawaban
                    ...q.options.map((option) {
                      final isSelected = selected == option.value;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _answers[q.id] = option.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.08)
                                : (isDark
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Radio button
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Emoji
                              Text(option.emoji,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              // Label
                              Expanded(
                                child: Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText),
                                  ),
                                ),
                              ),
                              // Nilai
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${option.value}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),

        // Tombol Next
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
          ),
          child: Column(
            children: [
              if (!_allAnswered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Jawab semua soal untuk melanjutkan',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              GradientButton(
                text: 'Lanjut ke Pertanyaan Kualitatif',
                onPressed:
                    _allAnswered ? () => setState(() => _step = 2) : () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentField(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Komentar',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Opsional',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Ada komentar atau masukan tambahan?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _commentController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
            decoration: InputDecoration(
              hintText: 'Tulis komentar atau masukan kamu...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Kualitatif ────────────────────────────────────────────
  Widget _buildQualitativeStep(bool isDark) {
    return Column(
      children: [
        _buildStepIndicator(isDark),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pertanyaan ini bersifat opsional. Jawab sesuai pengalaman Ibu.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _qualitativeQuestions.length,
            itemBuilder: (_, i) {
              final q = _qualitativeQuestions[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _qualitativeControllers[i].text.isNotEmpty
                        ? AppColors.primary.withOpacity(0.3)
                        : (isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pertanyaan ${q['number']}',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      q['question'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _qualitativeControllers[i],
                      maxLines: 4,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tulis jawaban Ibu di sini...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Tombol Submit
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
          ),
          child: GradientButton(
            text: 'Submit Kuesioner',
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }

  // ─── Step 3: Hasil ─────────────────────────────────────────────────
  Widget _buildResult(bool isDark) {
    final totalScore = _result?['total_score'] ?? 0;
    final maxScore = _result?['max_score'] ?? 32;
    final percentage = (_result?['percentage'] ?? 0).toDouble();

    final color = percentage >= 75
        ? AppColors.success
        : percentage >= 50
            ? AppColors.warning
            : AppColors.danger;

    final emoji = percentage >= 75
        ? '🎉'
        : percentage >= 50
            ? '👍'
            : '💪';

    final message = percentage >= 75
        ? 'Terima kasih! Kepuasan Ibu sangat berarti bagi kami.'
        : percentage >= 50
            ? 'Terima kasih! Kami akan terus meningkatkan layanan.'
            : 'Terima kasih! Masukan Ibu sangat berharga untuk perbaikan kami.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                const Text(
                  'Kuesioner Selesai!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Skor
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ResultStat(
                        label: 'Total Skor',
                        value: '$totalScore',
                        color: color,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: color.withOpacity(0.3),
                      ),
                      _ResultStat(
                        label: 'Maks Skor',
                        value: '$maxScore',
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: color.withOpacity(0.3),
                      ),
                      _ResultStat(
                        label: 'Persentase',
                        value: '${percentage.toStringAsFixed(1)}%',
                        color: color,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor:
                        isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    color: color,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tombol kembali
          GradientButton(
            text: 'Kembali ke Daftar Kuesioner',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ─── Widget Pendukung ──────────────────────────────────────────────────────
class _StepDot extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isDark;

  const _StepDot({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? AppColors.primary
                  : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isActive
                ? AppColors.primary
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
