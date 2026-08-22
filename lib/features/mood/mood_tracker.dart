import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum MoodType {
  happy,
  calm,
  tired,
  anxious,
  sad,
  angry,
  lostInterest,
}

extension MoodTypeExt on MoodType {
  String get label {
    switch (this) {
      case MoodType.happy:
        return 'Bahagia';
      case MoodType.calm:
        return 'Tenang';
      case MoodType.tired:
        return 'Lelah';
      case MoodType.anxious:
        return 'Cemas';
      case MoodType.sad:
        return 'Sedih';
      case MoodType.angry:
        return 'Mudah Marah';
      case MoodType.lostInterest:
        return 'Kehilangan Minat';
    }
  }

  String get emoji {
    switch (this) {
      case MoodType.happy:
        return '😊';
      case MoodType.calm:
        return '😌';
      case MoodType.tired:
        return '😩';
      case MoodType.anxious:
        return '😰';
      case MoodType.sad:
        return '😢';
      case MoodType.angry:
        return '😠';
      case MoodType.lostInterest:
        return '😶';
    }
  }

  Color get color {
    switch (this) {
      case MoodType.happy:
        return AppColors.success;
      case MoodType.calm:
        return AppColors.primary;
      case MoodType.tired:
        return AppColors.warning;
      case MoodType.anxious:
        return const Color(0xFFF97316);
      case MoodType.sad:
        return const Color(0xFF6366F1);
      case MoodType.angry:
        return AppColors.danger;
      case MoodType.lostInterest:
        return AppColors.lightTextSecondary;
    }
  }

  // Apakah mood ini termasuk negatif (untuk AI risk)
  bool get isNegative {
    switch (this) {
      case MoodType.happy:
      case MoodType.calm:
        return false;
      default:
        return true;
    }
  }
}

class MoodRecord {
  final String id;
  final DateTime date;
  final MoodType mood;
  final String? note;

  MoodRecord({
    required this.id,
    required this.date,
    required this.mood,
    this.note,
  });
}
