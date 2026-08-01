import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Bagaimana cara menghubungkan smartwatch?',
      'answer':
          'Buka menu Kelola Smartwatch di halaman Profil, aktifkan Bluetooth, lalu pilih perangkat smartwatch kamu dari daftar yang tersedia.',
    },
    {
      'question': 'Apakah data kesehatan saya aman?',
      'answer':
          'Ya, semua data kesehatan kamu dienkripsi dan disimpan dengan aman. Kami tidak membagikan data pribadi kamu kepada pihak ketiga tanpa izin.',
    },
    {
      'question': 'Berapa kali sebaiknya mengisi kuesioner?',
      'answer':
          'Disarankan mengisi kuesioner minimal 1x seminggu agar AI dapat memberikan rekomendasi yang lebih akurat berdasarkan perkembangan kondisi kesehatanmu.',
    },
    {
      'question': 'Bagaimana cara kerja AI Health Assistant?',
      'answer':
          'AI kami menganalisis data kesehatan dari smartwatch (BPM, tekanan darah, aktivitas) dan hasil kuesioner untuk memberikan rekomendasi yang personal dan relevan.',
    },
    {
      'question': 'Apakah aplikasi ini bisa menggantikan dokter?',
      'answer':
          'Tidak. SmartMoms adalah alat bantu pemantauan kesehatan. Selalu konsultasikan kondisi kesehatanmu dengan dokter atau bidan yang terpercaya.',
    },
    {
      'question': 'Kenapa data BPM saya tidak terupdate?',
      'answer':
          'Pastikan smartwatch sudah terhubung dan Bluetooth aktif. Coba restart aplikasi atau periksa koneksi perangkat di menu Kelola Smartwatch.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan',
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
            // Banner
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
                          'Ada yang bisa kami bantu? 💬',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Temukan jawaban di FAQ atau hubungi tim kami',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.support_agent_rounded,
                      color: Colors.white, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FAQ
            _SectionLabel(label: 'Pertanyaan Umum (FAQ)', isDark: isDark),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: _faqs.asMap().entries.map((e) {
                  final i = e.key;
                  final faq = e.value;
                  final isExpanded = _expandedIndex == i;
                  final isLast = i == _faqs.length - 1;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () => setState(
                            () => _expandedIndex = isExpanded ? null : i),
                        borderRadius: BorderRadius.vertical(
                          top: i == 0 ? const Radius.circular(20) : Radius.zero,
                          bottom: isLast && !isExpanded
                              ? const Radius.circular(20)
                              : Radius.zero,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.help_outline_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  faq['question']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.lightText,
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              faq['answer']!,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          indent: 16,
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Hubungi Kami
            _SectionLabel(label: 'Hubungi Kami', isDark: isDark),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _ContactTile(
                    icon: Icons.email_outlined,
                    iconColor: AppColors.primary,
                    title: 'Email',
                    subtitle: 'smartmoms@abdurrab.ac.id',
                    isDark: isDark,
                    onTap: () {},
                    showDivider: true,
                  ),
                  _ContactTile(
                    icon: Icons.chat_outlined,
                    iconColor: AppColors.success,
                    title: 'WhatsApp',
                    subtitle: '+62 812-3456-7890',
                    isDark: isDark,
                    onTap: () {},
                    showDivider: true,
                  ),
                  _ContactTile(
                    icon: Icons.language_outlined,
                    iconColor: AppColors.accent,
                    title: 'Website',
                    subtitle: 'smartmoms.abdurrab.ac.id',
                    isDark: isDark,
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Versi app
            Center(
              child: Column(
                children: [
                  Text(
                    'SmartMoms v1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Universitas Abdurrab • Diktisaintek Berdampak',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary.withOpacity(0.5)
                          : AppColors.lightTextSecondary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

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

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;
  final bool showDivider;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          )),
                      Text(subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          )),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
      ],
    );
  }
}
