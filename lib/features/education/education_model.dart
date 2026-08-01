import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum EducationCategory {
  mentalHealth,
  sleepManagement,
  physicalRecovery,
  nutrition,
  babyBlues,
  socialSupport,
}

extension EducationCategoryExt on EducationCategory {
  String get label {
    switch (this) {
      case EducationCategory.mentalHealth:
        return 'Kesehatan Mental';
      case EducationCategory.sleepManagement:
        return 'Manajemen Tidur';
      case EducationCategory.physicalRecovery:
        return 'Pemulihan Fisik';
      case EducationCategory.nutrition:
        return 'Nutrisi';
      case EducationCategory.babyBlues:
        return 'Baby Blues';
      case EducationCategory.socialSupport:
        return 'Dukungan Sosial';
    }
  }

  Color get color {
    switch (this) {
      case EducationCategory.mentalHealth:
        return const Color(0xFF6366F1);
      case EducationCategory.sleepManagement:
        return const Color(0xFF7C3AED);
      case EducationCategory.physicalRecovery:
        return AppColors.primary;
      case EducationCategory.nutrition:
        return AppColors.success;
      case EducationCategory.babyBlues:
        return AppColors.warning;
      case EducationCategory.socialSupport:
        return AppColors.accent;
    }
  }

  IconData get icon {
    switch (this) {
      case EducationCategory.mentalHealth:
        return Icons.psychology_outlined;
      case EducationCategory.sleepManagement:
        return Icons.bedtime_outlined;
      case EducationCategory.physicalRecovery:
        return Icons.self_improvement_rounded;
      case EducationCategory.nutrition:
        return Icons.restaurant_outlined;
      case EducationCategory.babyBlues:
        return Icons.favorite_outline_rounded;
      case EducationCategory.socialSupport:
        return Icons.people_outline_rounded;
    }
  }
}

// Tag risiko — artikel ini direkomendasikan untuk risiko apa
enum RiskTag { all, low, moderate, high }

class EducationArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final EducationCategory category;
  final List<RiskTag> riskTags; // artikel ini relevan untuk risiko apa
  final int readMinutes;
  final bool isImportant;

  EducationArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.riskTags,
    required this.readMinutes,
    this.isImportant = false,
  });
}

// Dummy articles
final List<EducationArticle> allArticles = [
  EducationArticle(
    id: '1',
    title: 'Mengenali Tanda Awal Depresi Postpartum',
    summary:
        'Pelajari tanda-tanda awal depresi postpartum agar bisa segera ditangani.',
    content:
        '''Depresi postpartum adalah kondisi kesehatan mental yang umum dialami ibu setelah melahirkan. Berbeda dengan baby blues yang biasanya hilang dalam 2 minggu, depresi postpartum bisa berlangsung lebih lama dan membutuhkan penanganan profesional.

Tanda-tanda awal yang perlu diwaspadai:
- Perasaan sedih yang mendalam dan terus-menerus
- Kehilangan minat pada aktivitas yang biasanya disukai
- Perubahan nafsu makan atau pola tidur yang signifikan
- Kesulitan berkonsentrasi atau membuat keputusan
- Perasaan tidak berharga atau rasa bersalah berlebihan
- Kelelahan ekstrem yang tidak membaik dengan istirahat

Jika kamu mengalami beberapa tanda di atas selama lebih dari 2 minggu, segera konsultasikan dengan bidan atau dokter. Penanganan dini sangat penting untuk pemulihan yang optimal.''',
    category: EducationCategory.mentalHealth,
    riskTags: [RiskTag.moderate, RiskTag.high],
    readMinutes: 5,
    isImportant: true,
  ),
  EducationArticle(
    id: '2',
    title: 'Tips Tidur Berkualitas untuk Ibu Nifas',
    summary: 'Gangguan tidur sangat umum di masa nifas. Ini cara mengatasinya.',
    content:
        '''Kurang tidur adalah salah satu tantangan terbesar di masa nifas. Namun kualitas tidur yang buruk dapat memperburuk kondisi kesehatan mental dan fisik.

Tips untuk tidur lebih berkualitas:
- Tidur ketika bayi tidur, jangan gunakan waktu itu untuk pekerjaan rumah
- Minta bantuan pasangan atau keluarga untuk bergantian menjaga bayi di malam hari
- Ciptakan lingkungan tidur yang nyaman — gelap, sejuk, dan tenang
- Hindari kafein setelah jam 14.00
- Lakukan rutinitas relaksasi sebelum tidur seperti mandi air hangat atau membaca
- Batasi penggunaan gadget minimal 1 jam sebelum tidur

Ingat, tidur yang cukup bukan kemewahan — ini kebutuhan dasar untuk pemulihanmu.''',
    category: EducationCategory.sleepManagement,
    riskTags: [RiskTag.all],
    readMinutes: 4,
  ),
  EducationArticle(
    id: '3',
    title: 'Memahami Baby Blues vs Depresi Postpartum',
    summary:
        'Apa perbedaan baby blues dan depresi postpartum? Kenali keduanya.',
    content:
        '''Banyak ibu baru mengalami perubahan emosi setelah melahirkan. Penting untuk memahami perbedaan antara baby blues dan depresi postpartum.

Baby Blues:
- Terjadi pada 70-80% ibu baru
- Muncul dalam 2-3 hari setelah melahirkan
- Gejala: menangis tanpa sebab, mudah lelah, cemas ringan
- Biasanya hilang sendiri dalam 1-2 minggu
- Tidak membutuhkan penanganan medis khusus

Depresi Postpartum:
- Terjadi pada 10-15% ibu baru
- Bisa muncul kapan saja dalam setahun pertama
- Gejala lebih berat dan berlangsung lebih lama
- Mempengaruhi kemampuan merawat diri dan bayi
- Membutuhkan penanganan profesional

Jika perasaan negatif tidak membaik setelah 2 minggu atau semakin parah, segera cari bantuan profesional.''',
    category: EducationCategory.babyBlues,
    riskTags: [RiskTag.all],
    readMinutes: 6,
  ),
  EducationArticle(
    id: '4',
    title: 'Nutrisi Penting untuk Pemulihan Nifas',
    summary:
        'Asupan gizi yang tepat mempercepat pemulihan dan menjaga kesehatan mental.',
    content:
        '''Nutrisi yang baik sangat penting untuk pemulihan fisik dan mental di masa nifas.

Nutrisi yang perlu diperhatikan:
- Protein — untuk perbaikan jaringan: daging, ikan, telur, kacang-kacangan
- Zat besi — untuk mencegah anemia: daging merah, bayam, kacang merah
- Kalsium — untuk kesehatan tulang: susu, yogurt, keju, ikan teri
- Omega-3 — untuk kesehatan otak dan mood: ikan salmon, chia seeds, walnut
- Vitamin D — untuk mood dan imunitas: paparan sinar matahari pagi, susu fortifikasi
- Air putih — minimal 8 gelas per hari untuk hidrasi optimal

Hindari diet ketat di masa nifas. Tubuhmu membutuhkan energi ekstra untuk pemulihan.''',
    category: EducationCategory.nutrition,
    riskTags: [RiskTag.all],
    readMinutes: 5,
  ),
  EducationArticle(
    id: '5',
    title: 'Pentingnya Dukungan Sosial di Masa Nifas',
    summary:
        'Dukungan dari orang terdekat berperan besar dalam pemulihan ibu nifas.',
    content:
        '''Dukungan sosial adalah salah satu faktor terpenting dalam mencegah dan mengatasi depresi postpartum.

Bentuk dukungan yang dibutuhkan:
- Dukungan emosional — didengarkan, dipahami, dan tidak dihakimi
- Dukungan praktis — bantuan memasak, membersihkan rumah, menjaga bayi
- Dukungan informasi — informasi yang benar tentang perawatan ibu dan bayi
- Dukungan sosial — tetap terhubung dengan teman dan keluarga

Cara meminta bantuan:
- Jangan ragu untuk meminta tolong — meminta bantuan bukan tanda kelemahan
- Spesifik dalam meminta bantuan: "Bisakah kamu memasak makan malam Selasa?"
- Bergabung dengan komunitas ibu baru untuk berbagi pengalaman
- Komunikasikan perasaanmu kepada pasangan secara terbuka

Kamu tidak harus melewati masa nifas sendirian.''',
    category: EducationCategory.socialSupport,
    riskTags: [RiskTag.moderate, RiskTag.high],
    readMinutes: 5,
    isImportant: true,
  ),
  EducationArticle(
    id: '6',
    title: 'Olahraga Ringan yang Aman di Masa Nifas',
    summary: 'Aktivitas fisik ringan membantu pemulihan dan meningkatkan mood.',
    content:
        '''Olahraga ringan di masa nifas sangat bermanfaat untuk pemulihan fisik dan kesehatan mental.

Olahraga yang aman:
- Jalan kaki — mulai dari 10-15 menit, tingkatkan bertahap
- Senam nifas — gerakan khusus untuk memperkuat otot dasar panggul
- Yoga ringan — membantu relaksasi dan fleksibilitas
- Peregangan ringan — mengurangi ketegangan otot

Panduan penting:
- Mulai olahraga setelah mendapat izin dari dokter/bidan (biasanya setelah 6 minggu)
- Dengarkan tubuhmu — berhenti jika merasa sakit atau tidak nyaman
- Hindari olahraga berat hingga masa nifas selesai
- Pastikan cukup minum air sebelum, saat, dan setelah olahraga

Olahraga ringan terbukti meningkatkan mood dan mengurangi risiko depresi postpartum.''',
    category: EducationCategory.physicalRecovery,
    riskTags: [RiskTag.all],
    readMinutes: 4,
  ),
  EducationArticle(
    id: '7',
    title: 'Teknik Relaksasi untuk Mengelola Stres',
    summary:
        'Teknik relaksasi sederhana yang bisa dilakukan kapan saja untuk mengurangi stres.',
    content:
        '''Stres adalah hal yang wajar di masa nifas, namun penting untuk mengelolanya dengan baik.

Teknik relaksasi yang efektif:
- Pernapasan dalam — tarik napas 4 hitungan, tahan 4, buang 6 hitungan
- Meditasi mindfulness — fokus pada momen saat ini, 5-10 menit per hari
- Progressive muscle relaxation — tegangkan dan rilekskan kelompok otot secara bergantian
- Journaling — tulis perasaan dan pikiran di buku harian
- Mendengarkan musik — musik yang menenangkan terbukti mengurangi stres

Tips tambahan:
- Tetapkan batas — tidak apa-apa untuk menolak tamu saat butuh istirahat
- Batasi konsumsi berita atau media sosial yang memicu stres
- Luangkan waktu untuk diri sendiri minimal 15 menit per hari

Merawat diri sendiri bukan egois — ini cara terbaik untuk bisa merawat orang lain.''',
    category: EducationCategory.mentalHealth,
    riskTags: [RiskTag.moderate, RiskTag.high],
    readMinutes: 6,
    isImportant: true,
  ),
];

// Filter artikel berdasarkan risk level
List<EducationArticle> getRecommendedArticles(String riskLevel) {
  final tag = riskLevel == 'high'
      ? RiskTag.high
      : riskLevel == 'moderate'
          ? RiskTag.moderate
          : RiskTag.low;

  return allArticles
      .where(
          (a) => a.riskTags.contains(tag) || a.riskTags.contains(RiskTag.all))
      .toList();
}
