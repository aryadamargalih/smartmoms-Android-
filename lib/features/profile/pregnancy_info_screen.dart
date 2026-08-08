import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/profile_provider.dart';

class PregnancyInfoScreen extends StatefulWidget {
  const PregnancyInfoScreen({super.key});

  @override
  State<PregnancyInfoScreen> createState() => _PregnancyInfoScreenState();
}

class _PregnancyInfoScreenState extends State<PregnancyInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isSaving = false;

  final _hplController = TextEditingController();
  final _hphtController = TextEditingController();
  final _weekController = TextEditingController();
  final _doctorController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _weekController.text = user.nifasDay?.toString() ?? '0';
      _doctorController.text = user.doctorName ?? '';
      _hospitalController.text = user.hospitalName ?? '';
      _hplController.text = user.deliveryDate ?? '';

      // Update milestone done status berdasarkan nifasDay
      final nifasDay = user.nifasDay ?? 0;
      for (var m in _milestones) {
        m['done'] = (m['day'] as int) <= nifasDay;
        if ((m['day'] as int) == nifasDay) {
          m['icon'] = Icons.radio_button_checked;
        } else if ((m['day'] as int) < nifasDay) {
          m['icon'] = Icons.check_circle_rounded;
        } else {
          m['icon'] = Icons.radio_button_unchecked;
        }
      }
    }
  }

  // Milestone kehamilan
  final List<Map<String, dynamic>> _milestones = [
    {
      'day': 1,
      'title': 'Hari Pertama Nifas',
      'done': true,
      'icon': Icons.check_circle_rounded
    },
    {
      'day': 3,
      'title': 'Pemeriksaan Pertama',
      'done': true,
      'icon': Icons.check_circle_rounded
    },
    {
      'day': 7,
      'title': 'Kontrol Minggu Pertama',
      'done': true,
      'icon': Icons.check_circle_rounded
    },
    {
      'day': 14,
      'title': 'Hari Ini',
      'done': true,
      'icon': Icons.radio_button_checked
    },
    {
      'day': 20,
      'title': 'Kontrol Minggu Ketiga',
      'done': false,
      'icon': Icons.radio_button_unchecked
    },
    {
      'day': 30,
      'title': 'Pemeriksaan Akhir Nifas',
      'done': false,
      'icon': Icons.radio_button_unchecked
    },
    {
      'day': 40,
      'title': 'Selesai Masa Nifas',
      'done': false,
      'icon': Icons.radio_button_unchecked
    },
  ];

  @override
  void dispose() {
    _hplController.dispose();
    _hphtController.dispose();
    _weekController.dispose();
    _doctorController.dispose();
    _hospitalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider = context.read<ProfileProvider>();
    final success = await profileProvider.updateNifasInfo(
      doctorName: _doctorController.text,
      hospitalName: _hospitalController.text,
      deliveryDate: _hplController.text,
    );

    if (mounted) {
      if (success) {
        await context.read<AuthProvider>().fetchMe();
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data kehamilan berhasil disimpan!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileProvider.errorMessage ?? 'Gagal menyimpan'),
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
    final currentWeek = int.tryParse(_weekController.text) ?? 24;
    final progress = currentWeek / 40;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Kehamilan',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? 'Batal' : 'Edit',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Progress Kehamilan ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Minggu ke-$currentWeek',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Text('🤱', style: TextStyle(fontSize: 28)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Progress bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress Kehamilan',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        color: Colors.white,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats bawah
                    Row(
                      children: [
                        _ProgressStat(
                          label: 'Sudah dilalui',
                          value: '$currentWeek minggu',
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.3),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _ProgressStat(
                          label: 'Sisa',
                          value: '${40 - currentWeek} minggu',
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.3),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _ProgressStat(
                          label: 'Total',
                          value: '40 minggu',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Milestone Timeline ──────────────────────────────────────
              _SectionLabel(label: 'Timeline Kehamilan', isDark: isDark),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: _milestones.asMap().entries.map((e) {
                    final i = e.key;
                    final m = e.value;
                    final isLast = i == _milestones.length - 1;
                    final isCurrent = m['title'] == 'Minggu Saat Ini';

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline line + dot
                        Column(
                          children: [
                            Icon(
                              m['icon'] as IconData,
                              color: m['done'] as bool
                                  ? (isCurrent
                                      ? AppColors.accent
                                      : AppColors.primary)
                                  : (isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider),
                              size: 22,
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 32,
                                color: m['done'] as bool
                                    ? AppColors.primary.withOpacity(0.3)
                                    : (isDark
                                        ? AppColors.darkDivider
                                        : AppColors.lightDivider),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      m['title'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isCurrent
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isCurrent
                                            ? AppColors.accent
                                            : (m['done'] as bool
                                                ? (isDark
                                                    ? AppColors.darkText
                                                    : AppColors.lightText)
                                                : (isDark
                                                    ? AppColors
                                                        .darkTextSecondary
                                                    : AppColors
                                                        .lightTextSecondary)),
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Sekarang',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  'Minggu ${m['week']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // ── Data Kehamilan ──────────────────────────────────────────
              _SectionLabel(label: 'Data Kehamilan', isDark: isDark),
              const SizedBox(height: 12),

              // Trimester selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trimester',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _PregnancyField(
                label: 'Usia Kehamilan (minggu)',
                controller: _weekController,
                prefixIcon: Icons.calendar_today_outlined,
                isEditing: _isEditing,
                isDark: isDark,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  final n = int.tryParse(v);
                  if (n == null || n < 0 || n > 42) return 'Masukkan 0-42';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _PregnancyField(
                label: 'Hari Perkiraan Lahir (HPL)',
                controller: _hplController,
                prefixIcon: Icons.child_friendly_outlined,
                isEditing: _isEditing,
                isDark: isDark,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // ── Data Dokter ─────────────────────────────────────────────
              _SectionLabel(label: 'Data Dokter & RS', isDark: isDark),
              const SizedBox(height: 12),

              _PregnancyField(
                label: 'Nama Dokter / Bidan',
                controller: _doctorController,
                prefixIcon: Icons.medical_services_outlined,
                isEditing: _isEditing,
                isDark: isDark,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              _PregnancyField(
                label: 'Rumah Sakit / Klinik',
                controller: _hospitalController,
                prefixIcon: Icons.local_hospital_outlined,
                isEditing: _isEditing,
                isDark: isDark,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // ── Catatan ─────────────────────────────────────────────────
              _SectionLabel(label: 'Catatan', isDark: isDark),
              const SizedBox(height: 12),

              if (!_isEditing)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                  ),
                  child: Text(
                    _notesController.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                )
              else
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tambahkan catatan kehamilan...',
                  ),
                ),

              const SizedBox(height: 32),

              if (_isEditing)
                GradientButton(
                  text: 'Simpan Perubahan',
                  isLoading: _isSaving,
                  onPressed: _save,
                ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widget Pendukung ──────────────────────────────────────────────────────
class _ProgressStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProgressStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _PregnancyField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool isEditing;
  final bool isDark;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _PregnancyField({
    required this.label,
    required this.controller,
    required this.prefixIcon,
    required this.isEditing,
    required this.isDark,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        if (!isEditing)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Row(
              children: [
                Icon(prefixIcon, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  controller.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
          )
        else
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon, size: 18, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
