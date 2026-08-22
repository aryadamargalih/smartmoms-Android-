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
