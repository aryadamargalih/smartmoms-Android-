import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import 'questionnaire_model.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  // Index kuesioner yang sedang aktif
  int _activeQuestionnaire = 0;
  // Index pertanyaan yang sedang aktif
  int _currentQuestion = 0;
  // Simpan jawaban: {questionId: value}
  final Map<String, int> _answers = {};
  // State halaman: 'list', 'quiz', 'result'
  String _page = 'list';

  QuestionnaireModel get _currentQuestionnaire =>
      dummyQuestionnaires[_activeQuestionnaire];

  QuestionModel get _question =>
      _currentQuestionnaire.questions[_currentQuestion];

  int get _totalQuestions => _currentQuestionnaire.questions.length;

  double get _progress => (_currentQuestion + 1) / _totalQuestions;

  int get _totalScore {
    int score = 0;
    for (final q in _currentQuestionnaire.questions) {
      score += _answers[q.id] ?? 0;
    }
    return score;
  }

  int get _maxScore => _totalQuestions * 5;

  String get _scoreCategory {
    final percent = _totalScore / _maxScore;
    if (percent >= 0.8) return 'Sangat Baik';
    if (percent >= 0.6) return 'Baik';
    if (percent >= 0.4) return 'Cukup';
    return 'Perlu Perhatian';
  }

  Color get _scoreColor {
    final percent = _totalScore / _maxScore;
    if (percent >= 0.8) return AppColors.success;
    if (percent >= 0.6) return AppColors.primary;
    if (percent >= 0.4) return AppColors.warning;
    return AppColors.danger;
  }

  void _startQuestionnaire(int index) {
    setState(() {
      _activeQuestionnaire = index;
      _currentQuestion = 0;
      _answers.clear();
      _page = 'quiz';
    });
  }

  void _next() {
    if (_answers[_question.id] == null) return; // wajib jawab dulu
    if (_currentQuestion < _totalQuestions - 1) {
      setState(() => _currentQuestion++);
    } else {
      setState(() => _page = 'result');
    }
  }

  void _prev() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    } else {
      setState(() => _page = 'list');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_page == 'quiz') return _buildQuiz(context);
    if (_page == 'result') return _buildResult(context);
    return _buildList(context);
  }

  // ─── Halaman List Kuesioner ───────────────────────────────────────────────
  Widget _buildList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuesioner Kesehatan',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner info
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cek Kesehatan Kamu 📋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jawab kuesioner untuk mendapat rekomendasi kesehatan yang personal',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.assignment_outlined,
                      color: Colors.white, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Pilih Kuesioner'),
            const SizedBox(height: 12),

            ...dummyQuestionnaires.asMap().entries.map((e) {
              final i = e.key;
              final q = e.value;
              return _QuestionnaireCard(
                questionnaire: q,
                isDark: isDark,
                onTap: () => _startQuestionnaire(i),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── Halaman Quiz ─────────────────────────────────────────────────────────
  Widget _buildQuiz(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedAnswer = _answers[_question.id];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentQuestionnaire.category,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _prev,
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pertanyaan ${_currentQuestion + 1} dari $_totalQuestions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor:
                        isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Konten pertanyaan
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: SingleChildScrollView(
                key: ValueKey(_currentQuestion),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Pertanyaan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Q${_currentQuestion + 1}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _question.question,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pilihan jawaban
                    Text(
                      'Pilih jawaban yang paling sesuai:',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._question.options.map((option) {
                      final isSelected = selectedAnswer == option.value;
                      return GestureDetector(
                        onTap: () => setState(
                            () => _answers[_question.id] = option.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Nilai 1-5
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkBackground
                                          : AppColors.lightBackground),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${option.value}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                option.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 15,
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
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Tombol navigasi
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: Row(
              children: [
                if (_currentQuestion > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prev,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sebelumnya',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (_currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    text: _currentQuestion == _totalQuestions - 1
                        ? 'Lihat Hasil'
                        : 'Selanjutnya',
                    onPressed: selectedAnswer != null ? _next : () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Halaman Hasil ────────────────────────────────────────────────────────
  Widget _buildResult(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percent = _totalScore / _maxScore;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Kuesioner',
            style: TextStyle(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _scoreColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    percent >= 0.8
                        ? '🎉'
                        : percent >= 0.6
                            ? '👍'
                            : percent >= 0.4
                                ? '💪'
                                : '⚠️',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _scoreCategory,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _scoreColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Skor kamu: $_totalScore / $_maxScore',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Progress circle simulasi
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                      color: _scoreColor,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _scoreColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ringkasan per jawaban
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ringkasan Jawaban',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  ..._currentQuestionnaire.questions.asMap().entries.map((e) {
                    final i = e.key;
                    final q = e.value;
                    final answer = _answers[q.id] ?? 0;
                    final option = q.options.firstWhere(
                        (o) => o.value == answer,
                        orElse: () => q.options.first);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(q.question,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                        height: 1.4)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(option.emoji,
                                        style: const TextStyle(fontSize: 14)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${option.value} - ${option.label}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getAnswerColor(option.value),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rekomendasi
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1A1035), const Color(0xFF0F1A35)]
                      : [const Color(0xFFF3E8FF), const Color(0xFFE8F0FF)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.accent.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentLight]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rekomendasi AI',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          _getRecommendation(),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol aksi
            GradientButton(
              text: 'Tanya AI Lebih Lanjut',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/ai-chat');
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _page = 'list'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kembali ke Daftar',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAnswerColor(int value) {
    if (value >= 4) return AppColors.success;
    if (value == 3) return AppColors.warning;
    return AppColors.danger;
  }

  String _getRecommendation() {
    final percent = _totalScore / _maxScore;
    if (percent >= 0.8) {
      return 'Luar biasa! Kondisi kesehatanmu sangat baik. Pertahankan pola hidup sehat ini dan tetap rutin periksa ke dokter/bidan ya!';
    } else if (percent >= 0.6) {
      return 'Kondisi kesehatanmu sudah cukup baik. Ada beberapa aspek yang masih bisa ditingkatkan. Coba konsultasikan dengan AI untuk saran lebih lanjut.';
    } else if (percent >= 0.4) {
      return 'Ada beberapa hal yang perlu perhatian lebih. Disarankan untuk berkonsultasi dengan dokter/bidan dan tingkatkan pola hidup sehatmu.';
    }
    return 'Kondisi kesehatanmu memerlukan perhatian serius. Segera konsultasikan dengan tenaga medis dan gunakan fitur AI Chat untuk mendapat panduan lebih lanjut.';
  }
}

// ─── Card Kuesioner ────────────────────────────────────────────────────────
class _QuestionnaireCard extends StatelessWidget {
  final QuestionnaireModel questionnaire;
  final bool isDark;
  final VoidCallback onTap;

  const _QuestionnaireCard({
    required this.questionnaire,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.assignment_outlined,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(questionnaire.category,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(questionnaire.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      )),
                  const SizedBox(height: 6),
                  Text(
                    '${questionnaire.questions.length} pertanyaan',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
