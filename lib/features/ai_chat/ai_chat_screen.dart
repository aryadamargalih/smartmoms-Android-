import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'package:smartmoms/main.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  // Suggestion chips
  final List<String> _suggestions = [
    'BPM saya normal?',
    'Tekanan darah saya aman?',
    'Tips pemulihan nifas',
    'Hasil EPDS saya',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _messages.add(
      _ChatMessage(
        text: AppStrings.aiWelcome,
        isAi: true,
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages
          .add(_ChatMessage(text: text, isAi: false, time: DateTime.now()));
      _inputController.clear();
      _isTyping = true;
    });
    _scrollToBottom();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            text: _getAiResponse(text),
            isAi: true,
            time: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  String _getAiResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('bpm') || lower.contains('detak')) {
      return 'Berdasarkan data BPM kamu hari ini (84 BPM), detak jantungmu berada dalam kisaran normal untuk ibu nifas (60-100 BPM). Ini tanda pemulihan yang baik! 💗\n\nPastikan kamu cukup istirahat dan tidak melakukan aktivitas berat selama masa nifas.';
    }
    if (lower.contains('tekanan') || lower.contains('darah')) {
      return 'Tekanan darah kamu hari ini 120/78 mmHg tergolong normal. 🩺\n\nPada masa nifas, penting memantau tekanan darah secara rutin karena risiko hipertensi pasca melahirkan. Segera hubungi dokter jika merasa pusing atau sakit kepala hebat.';
    }
    if (lower.contains('aktivitas') || lower.contains('langkah')) {
      return 'Aktivitas fisikmu hari ini sudah mencapai 5,430 langkah. 🚶‍♀️\n\nUntuk ibu nifas, aktivitas ringan seperti jalan kaki sangat dianjurkan untuk mempercepat pemulihan. Hindari aktivitas berat hingga masa nifas selesai (40 hari).';
    }
    if (lower.contains('epds') ||
        lower.contains('depresi') ||
        lower.contains('sedih')) {
      return 'Kesehatan mental di masa nifas sangat penting. 💙\n\nBerdasarkan hasil kuesioner EPDS kamu, kondisimu perlu terus dipantau. Jangan ragu untuk berbicara dengan dokter atau bidan jika kamu merasa sedih, cemas, atau tidak seperti biasanya.';
    }
    return 'Berdasarkan data kesehatan kamu minggu ini, kondisi pemulihan nifasmu secara umum baik. BPM dan tekanan darah dalam batas normal. 🌸\n\nTerus pantau kesehatanmu dan jangan lupa istirahat yang cukup. Konsultasi rutin dengan bidan atau dokter tetap diperlukan ya!';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI SmartMoms',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            context.findAncestorStateOfType<MainScreenState>()?.setIndex(0);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 18),
              text: 'Chat',
            ),
            Tab(
              icon: Icon(Icons.analytics_outlined, size: 18),
              text: 'Analisis Risiko',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Chat ──────────────────────────────────────────────
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _messages.length && _isTyping) {
                      return _TypingIndicator(isDark: isDark);
                    }
                    return _MessageBubble(
                      message: _messages[i],
                      isDark: isDark,
                    );
                  },
                ),
              ),
              if (_messages.isNotEmpty && _messages.last.isAi && !_isTyping)
                _SuggestionChips(
                  suggestions: _suggestions,
                  onSelected: _sendMessage,
                  isDark: isDark,
                ),
              _InputBar(
                controller: _inputController,
                isDark: isDark,
                onSend: () => _sendMessage(_inputController.text),
              ),
            ],
          ),

          // ── Tab 2: Analisis Risiko ────────────────────────────────────
          _RiskAnalysisTab(
            isDark: isDark,
            onChatTap: () => _tabController.animateTo(0),
          ),
        ],
      ),
    );
  }
}

class _RiskAnalysisTab extends StatelessWidget {
  final bool isDark;
  final VoidCallback onChatTap;

  const _RiskAnalysisTab({
    required this.isDark,
    required this.onChatTap,
  });

  // Dummy risk level: 'low', 'moderate', 'high'
  static const String _riskLevel = 'moderate';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Risk Level Card ───────────────────────────────────────────
          _RiskLevelCard(riskLevel: _riskLevel, isDark: isDark),
          const SizedBox(height: 24),

          // ── Indikator ─────────────────────────────────────────────────
          _SectionLabel(label: 'Indikator Analisis', isDark: isDark),
          const SizedBox(height: 12),
          _IndicatorCard(
            icon: Icons.assignment_outlined,
            label: 'Skor EPDS',
            value: '12/30',
            detail: 'Skor 10-12 menunjukkan kemungkinan depresi ringan',
            color: AppColors.warning,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _IndicatorCard(
            icon: Icons.mood_rounded,
            label: 'Pola Mood 7 Hari',
            value: '4 hari negatif',
            detail: 'Dominan lelah, cemas, dan sedih',
            color: AppColors.warning,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _IndicatorCard(
            icon: Icons.bedtime_rounded,
            label: 'Kualitas Tidur',
            value: 'Rata-rata 5.8 jam',
            detail: 'Di bawah rekomendasi 7 jam untuk ibu nifas',
            color: AppColors.warning,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _IndicatorCard(
            icon: Icons.favorite_rounded,
            label: 'Detak Jantung',
            value: '84 BPM',
            detail: 'Normal untuk ibu nifas',
            color: AppColors.success,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _IndicatorCard(
            icon: Icons.monitor_heart_rounded,
            label: 'Tekanan Darah',
            value: '120/78 mmHg',
            detail: 'Normal, tidak ada tanda hipertensi',
            color: AppColors.success,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _IndicatorCard(
            icon: Icons.directions_walk_rounded,
            label: 'Aktivitas Fisik',
            value: '5.430 langkah/hari',
            detail: '72% dari target harian',
            color: AppColors.primary,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // ── Rekomendasi ───────────────────────────────────────────────
          _SectionLabel(label: 'Rekomendasi', isDark: isDark),
          const SizedBox(height: 12),
          _RecommendationCard(
            riskLevel: _riskLevel,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // ── Tombol tanya AI ───────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onChatTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    color: Colors.white, size: 18),
                label: const Text(
                  'Diskusikan dengan AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Terakhir dianalisis
          Center(
            child: Text(
              'Terakhir dianalisis: Hari ini, 08:30',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Risk Level Card ───────────────────────────────────────────────────────
class _RiskLevelCard extends StatelessWidget {
  final String riskLevel;
  final bool isDark;

  const _RiskLevelCard({required this.riskLevel, required this.isDark});

  Color get _color {
    switch (riskLevel) {
      case 'high':
        return AppColors.danger;
      case 'moderate':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  String get _label {
    switch (riskLevel) {
      case 'high':
        return 'Risiko Tinggi';
      case 'moderate':
        return 'Risiko Sedang';
      default:
        return 'Risiko Rendah';
    }
  }

  String get _emoji {
    switch (riskLevel) {
      case 'high':
        return '⚠️';
      case 'moderate':
        return '🔶';
      default:
        return '✅';
    }
  }

  String get _description {
    switch (riskLevel) {
      case 'high':
        return 'Kamu menunjukkan beberapa tanda risiko tinggi depresi postpartum. Segera hubungi bidan atau dokter untuk penanganan lebih lanjut.';
      case 'moderate':
        return 'Kamu menunjukkan beberapa tanda yang perlu diperhatikan. Disarankan untuk konsultasi dengan bidan dalam waktu dekat.';
      default:
        return 'Kondisi kesehatanmu secara umum baik. Tetap pantau kesehatanmu setiap hari dan lakukan gaya hidup sehat.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _color.withOpacity(isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(
            _label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Risk meter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rendah',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      )),
                  Text('Tinggi',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      )),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: riskLevel == 'high'
                      ? 0.9
                      : riskLevel == 'moderate'
                          ? 0.55
                          : 0.2,
                  backgroundColor:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  color: _color,
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Indicator Card ────────────────────────────────────────────────────────
class _IndicatorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;
  final bool isDark;

  const _IndicatorCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary.withOpacity(0.7)
                        : AppColors.lightTextSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recommendation Card ───────────────────────────────────────────────────
class _RecommendationCard extends StatelessWidget {
  final String riskLevel;
  final bool isDark;

  const _RecommendationCard({
    required this.riskLevel,
    required this.isDark,
  });

  List<Map<String, dynamic>> get _recommendations {
    switch (riskLevel) {
      case 'high':
        return [
          {
            'icon': Icons.local_hospital_outlined,
            'text': 'Segera konsultasi dengan dokter atau psikiater',
            'color': AppColors.danger
          },
          {
            'icon': Icons.phone_outlined,
            'text': 'Hubungi bidan pendamping secepatnya',
            'color': AppColors.danger
          },
          {
            'icon': Icons.people_outline_rounded,
            'text': 'Minta dukungan dari keluarga terdekat',
            'color': AppColors.warning
          },
          {
            'icon': Icons.self_improvement_rounded,
            'text': 'Hindari sendirian, selalu ada pendamping',
            'color': AppColors.warning
          },
        ];
      case 'moderate':
        return [
          {
            'icon': Icons.calendar_today_outlined,
            'text': 'Jadwalkan konsultasi dengan bidan dalam 3 hari',
            'color': AppColors.warning
          },
          {
            'icon': Icons.bedtime_rounded,
            'text': 'Tingkatkan kualitas tidur minimal 7 jam/malam',
            'color': AppColors.primary
          },
          {
            'icon': Icons.mood_rounded,
            'text': 'Isi mood tracker setiap hari untuk pemantauan',
            'color': AppColors.primary
          },
          {
            'icon': Icons.directions_walk_rounded,
            'text': 'Lakukan aktivitas ringan 30 menit setiap hari',
            'color': AppColors.success
          },
        ];
      default:
        return [
          {
            'icon': Icons.check_circle_outline_rounded,
            'text': 'Pertahankan pola hidup sehat saat ini',
            'color': AppColors.success
          },
          {
            'icon': Icons.assignment_outlined,
            'text': 'Isi kuesioner EPDS rutin setiap minggu',
            'color': AppColors.primary
          },
          {
            'icon': Icons.bedtime_rounded,
            'text': 'Jaga kualitas tidur tetap optimal',
            'color': AppColors.primary
          },
          {
            'icon': Icons.favorite_outlined,
            'text': 'Tetap aktif dan jaga kesehatan mental',
            'color': AppColors.success
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: _recommendations.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          final isLast = i == _recommendations.length - 1;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (r['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(r['icon'] as IconData,
                        color: r['color'] as Color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      r['text'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Section Label ─────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ─── Message Bubble ────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool isDark;

  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isAi = message.isAi;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAi) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isAi
                        ? (isDark ? AppColors.darkCard : AppColors.lightCard)
                        : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isAi ? 4 : 16),
                      bottomRight: Radius.circular(isAi ? 16 : 4),
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: (isAi ? Colors.black : AppColors.primary)
                                  .withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isAi
                          ? (isDark ? AppColors.darkText : AppColors.lightText)
                          : Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isAi) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Typing Indicator ──────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  final bool isDark;
  const _TypingIndicator({required this.isDark});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentLight],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final offset = (i / 3);
                  final phase = (_controller.value + offset) % 1.0;
                  final opacity = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withOpacity(0.3 + opacity * 0.7),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Suggestion Chips ──────────────────────────────────────────────────────
class _SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;
  final bool isDark;

  const _SuggestionChips({
    required this.suggestions,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: suggestions.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => onSelected(suggestions[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                suggestions[i],
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Input Bar ─────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isDark,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.aiChatHint,
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color:
                        isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color:
                        isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor:
                    isDark ? AppColors.darkCard : AppColors.lightBackground,
              ),
              onSubmitted: (_) => onSend(),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat Message Model ────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isAi;
  final DateTime time;

  _ChatMessage({required this.text, required this.isAi, required this.time});
}
