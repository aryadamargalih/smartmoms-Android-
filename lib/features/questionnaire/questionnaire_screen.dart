import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import 'questionnaire_model.dart';
import 'package:provider/provider.dart';
import '../../core/providers/questionnaire_provider.dart' as qp;
import 'csq_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  // Index pertanyaan yang sedang aktif
  int _currentQuestion = 0;
  // Simpan jawaban: {questionId: value}
  final Map<String, int> _answers = {};
  // State halaman: 'list', 'quiz', 'result'
  String _page = 'list';

  qp.QuestionnaireResult? _result;

  void _startQuestionnaire(int index, int questionnaireId) async {
    setState(() {
      _currentQuestion = 0;
      _answers.clear();
      _page = 'loading';
    });

    await context
        .read<qp.QuestionnaireProvider>()
        .fetchQuestions(questionnaireId);

    setState(() => _page = 'quiz');
  }

  void _next() async {
    final provider = context.read<qp.QuestionnaireProvider>();
    final questions = provider.activeQuestionnaire?.questions ?? [];

    if (_answers[questions[_currentQuestion].id.toString()] == null) return;

    if (_currentQuestion < questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      // Submit ke API
      setState(() => _page = 'loading');
      final result = await provider.submitAnswers(
        questionnaireId: provider.activeQuestionnaire!.id,
        answers: _answers,
      );

      if (result != null) {
        _result = result;
        setState(() => _page = 'result');
      } else {
        setState(() => _page = 'quiz');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal submit, coba lagi'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
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
    if (_page == 'loading') return _buildLoading();
    if (_page == 'quiz') return _buildQuiz(context);
    if (_page == 'result') return _buildResult(context);
    return _buildList(context);
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<qp.QuestionnaireProvider>().fetchQuestionnaires();
    });
  }

  // ─── Halaman List Kuesioner ───────────────────────────────────────────────
  Widget _buildList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<qp.QuestionnaireProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuesioner Kesehatan',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner tetap sama
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

                  // List dari API
                  ...provider.questionnaires.asMap().entries.map((e) {
                    final i = e.key;
                    final q = e.value;
                    return _QuestionnaireCard(
                      // Sesuaikan dengan model baru dari API
                      questionnaire: QuestionnaireModel(
                        id: q.id.toString(),
                        category: q.title,
                        description: q.description,
                        questionsCount: q.questionsCount,
                        questions: [], // kosong dulu, diload saat tap
                      ),
                      isDark: isDark,
                      onTap: () {
                        final q = provider.questionnaires[i];

                        // Cek apakah CSQ-8 berdasarkan category atau title
                        if (q.category == 'csq' ||
                            q.title.toLowerCase().contains('csq')) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CsqScreen(
                                questionnaireId: q.id,
                                title: q.title,
                              ),
                            ),
                          );
                        } else {
                          _startQuestionnaire(i, q.id);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
    );
  }

  // ─── Halaman Quiz ─────────────────────────────────────────────────────────
  Widget _buildQuiz(BuildContext context) {
    final provider = context.watch<qp.QuestionnaireProvider>();
    final questions = provider.activeQuestionnaire?.questions ?? [];

    if (questions.isEmpty) return _buildLoading();

    final question = questions[_currentQuestion];
    final selectedAnswer = _answers[question.id.toString()];
    final totalQuestions = questions.length;
    final progress = (_currentQuestion + 1) / totalQuestions;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.activeQuestionnaire?.title ?? '',
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
                      'Pertanyaan ${_currentQuestion + 1} dari $totalQuestions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
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
                    value: progress,
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
                            question.question,
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

                    // Pilihan dari API
                    ...question.options.map((option) {
                      final isSelected = selectedAnswer == option.value;
                      return GestureDetector(
                        onTap: () => setState(() =>
                            _answers[question.id.toString()] = option.value),
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
                    text: _currentQuestion == totalQuestions - 1
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
    if (_result == null) return _buildLoading();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percent = _result!.percentage;
    final scoreColor = percent >= 0.8
        ? AppColors.success
        : percent >= 0.6
            ? AppColors.primary
            : percent >= 0.4
                ? AppColors.warning
                : AppColors.danger;
    final scoreCategory = _result!.scoreCategory;

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
                  color: scoreColor.withOpacity(0.3),
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
                    scoreCategory,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Skor kamu: ${_result!.totalScore} / ${_result!.maxScore}',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                      color: scoreColor,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol aksi
            GradientButton(
              text: 'Tanya AI Lebih Lanjut',
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/ai-chat'),
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
                    '${questionnaire.questionsCount} pertanyaan',
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
