import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// kualitas tidur
enum SleepQuality {
  veryBad,
  bad,
  neutral,
  good,
  veryGood,
}

extension SleepQualityExt on SleepQuality {
  String get label {
    switch (this) {
      case SleepQuality.veryBad:
        return 'Sangat Buruk';
      case SleepQuality.bad:
        return 'Buruk';
      case SleepQuality.neutral:
        return 'Cukup';
      case SleepQuality.good:
        return 'Baik';
      case SleepQuality.veryGood:
        return 'Sangat Baik';
    }
  }

  String get emoji {
    switch (this) {
      case SleepQuality.veryBad:
        return '😴';
      case SleepQuality.bad:
        return '😕';
      case SleepQuality.neutral:
        return '😐';
      case SleepQuality.good:
        return '🙂';
      case SleepQuality.veryGood:
        return '😊';
    }
  }

  int get value {
    switch (this) {
      case SleepQuality.veryBad:
        return 1;
      case SleepQuality.bad:
        return 2;
      case SleepQuality.neutral:
        return 3;
      case SleepQuality.good:
        return 4;
      case SleepQuality.veryGood:
        return 5;
    }
  }

  Color get color {
    switch (this) {
      case SleepQuality.veryBad:
        return AppColors.danger;
      case SleepQuality.bad:
        return AppColors.warning;
      case SleepQuality.neutral:
        return AppColors.accent;
      case SleepQuality.good:
        return AppColors.primary;
      case SleepQuality.veryGood:
        return AppColors.success;
    }
  }
}

// Tambah enum gangguan tidur
enum SleepDisturbance {
  frequentWaking,
  difficultyFallingAsleep,
  nightmare,
  nightSweats,
  none,
}

extension SleepDisturbanceExt on SleepDisturbance {
  String get label {
    switch (this) {
      case SleepDisturbance.frequentWaking:
        return 'Sering Terbangun';
      case SleepDisturbance.difficultyFallingAsleep:
        return 'Susah Tidur';
      case SleepDisturbance.nightmare:
        return 'Mimpi Buruk';
      case SleepDisturbance.nightSweats:
        return 'Keringat Malam';
      case SleepDisturbance.none:
        return 'Tidak Ada Gangguan';
    }
  }

  IconData get icon {
    switch (this) {
      case SleepDisturbance.frequentWaking:
        return Icons.loop_rounded;
      case SleepDisturbance.difficultyFallingAsleep:
        return Icons.hourglass_empty_rounded;
      case SleepDisturbance.nightmare:
        return Icons.thunderstorm_outlined;
      case SleepDisturbance.nightSweats:
        return Icons.water_drop_outlined;
      case SleepDisturbance.none:
        return Icons.check_circle_outline_rounded;
    }
  }
}

// Update class SleepRecord — tambah field baru
class SleepRecord {
  final String id;
  final DateTime bedTime;
  final DateTime wakeTime;
  final DateTime date;
  final SleepQuality? quality;
  final List<SleepDisturbance> disturbances;

  SleepRecord({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    required this.date,
    this.quality,
    this.disturbances = const [],
  });

  Duration get duration => wakeTime.difference(bedTime);

  double get durationHours => duration.inMinutes / 60;

  String get durationText {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    return '${h}j ${m}m';
  }

  String get status {
    if (durationHours >= 7) return 'Baik';
    if (durationHours >= 5) return 'Cukup';
    return 'Kurang';
  }
}

// Update dummy data
final List<SleepRecord> dummySleepRecords = [
  SleepRecord(
    id: '1',
    bedTime: DateTime.now().subtract(const Duration(hours: 8)),
    wakeTime: DateTime.now().subtract(const Duration(hours: 1)),
    date: DateTime.now(),
    quality: SleepQuality.good,
    disturbances: [SleepDisturbance.frequentWaking],
  ),
  SleepRecord(
    id: '2',
    bedTime: DateTime.now().subtract(const Duration(days: 1, hours: 7)),
    wakeTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
    date: DateTime.now().subtract(const Duration(days: 1)),
    quality: SleepQuality.neutral,
    disturbances: [
      SleepDisturbance.difficultyFallingAsleep,
      SleepDisturbance.nightmare
    ],
  ),
  SleepRecord(
    id: '3',
    bedTime: DateTime.now().subtract(const Duration(days: 2, hours: 9)),
    wakeTime: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
    date: DateTime.now().subtract(const Duration(days: 2)),
    quality: SleepQuality.veryGood,
    disturbances: [SleepDisturbance.none],
  ),
  SleepRecord(
    id: '4',
    bedTime: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
    wakeTime: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
    date: DateTime.now().subtract(const Duration(days: 3)),
    quality: SleepQuality.bad,
    disturbances: [
      SleepDisturbance.nightSweats,
      SleepDisturbance.frequentWaking
    ],
  ),
  SleepRecord(
    id: '5',
    bedTime: DateTime.now().subtract(const Duration(days: 4, hours: 8)),
    wakeTime: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
    date: DateTime.now().subtract(const Duration(days: 4)),
    quality: SleepQuality.good,
    disturbances: [SleepDisturbance.none],
  ),
  SleepRecord(
    id: '6',
    bedTime: DateTime.now().subtract(const Duration(days: 5, hours: 5)),
    wakeTime: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
    date: DateTime.now().subtract(const Duration(days: 5)),
    quality: SleepQuality.veryBad,
    disturbances: [
      SleepDisturbance.nightmare,
      SleepDisturbance.difficultyFallingAsleep,
      SleepDisturbance.nightSweats
    ],
  ),
  SleepRecord(
    id: '7',
    bedTime: DateTime.now().subtract(const Duration(days: 6, hours: 7)),
    wakeTime: DateTime.now().subtract(const Duration(days: 6, hours: 1)),
    date: DateTime.now().subtract(const Duration(days: 6)),
    quality: SleepQuality.neutral,
    disturbances: [SleepDisturbance.frequentWaking],
  ),
];
