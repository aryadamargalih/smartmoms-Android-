import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/profile_provider.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _pregnancyWeekController = TextEditingController();
  String _selectedBloodType = 'A';

  final List<String> _bloodTypes = ['A', 'B', 'AB', 'O'];

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data user yang sudah ada
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _ageController.text = user.age?.toString() ?? '';
      _weightController.text = user.weight?.toString() ?? '';
      _heightController.text = user.height?.toString() ?? '';
      _pregnancyWeekController.text = user.nifasDay?.toString() ?? '';
      if (user.bloodType != null) {
        _selectedBloodType = user.bloodType!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _pregnancyWeekController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider = context.read<ProfileProvider>();
    final success = await profileProvider.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      age: int.tryParse(_ageController.text) ?? 0,
      bloodType: _selectedBloodType,
      weight: double.tryParse(_weightController.text) ?? 0,
      height: double.tryParse(_heightController.text) ?? 0,
      deliveryDate: _pregnancyWeekController.text,
    );

    if (mounted) {
      if (success) {
        // Refresh data user di AuthProvider
        await context.read<AuthProvider>().fetchMe();
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data berhasil disimpan!'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pribadi',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _toggleEdit,
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
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: const Text(
                        'S',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section: Informasi Umum
              _SectionLabel(label: 'Informasi Umum', isDark: isDark),
              const SizedBox(height: 12),

              _DataField(
                label: 'Nama Lengkap',
                controller: _nameController,
                prefixIcon: Icons.person_outline_rounded,
                isEditing: _isEditing,
                isDark: isDark,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 14),

              _DataField(
                label: 'Email',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                isEditing: _isEditing,
                isDark: isDark,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                  if (!v.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _DataField(
                label: 'Nomor Telepon',
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                isEditing: _isEditing,
                isDark: isDark,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Nomor telepon tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 14),

              _DataField(
                label: 'Usia (tahun)',
                controller: _ageController,
                prefixIcon: Icons.cake_outlined,
                isEditing: _isEditing,
                isDark: isDark,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Usia tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),

              // Section: Data Fisik
              _SectionLabel(label: 'Data Fisik', isDark: isDark),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _DataField(
                      label: 'Berat (kg)',
                      controller: _weightController,
                      prefixIcon: Icons.monitor_weight_outlined,
                      isEditing: _isEditing,
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DataField(
                      label: 'Tinggi (cm)',
                      controller: _heightController,
                      prefixIcon: Icons.height_rounded,
                      isEditing: _isEditing,
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Golongan darah
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Golongan Darah',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _bloodTypes.map((type) {
                      final isSelected = _selectedBloodType == type;
                      return GestureDetector(
                        onTap: _isEditing
                            ? () => setState(() => _selectedBloodType = type)
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightBackground),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              type,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkText
                                        : AppColors.lightText),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: Data Kehamilan
              _SectionLabel(label: 'Data Kehamilan', isDark: isDark),
              const SizedBox(height: 12),

              _DataField(
                label: 'Hari ke- Masa Nifas',
                controller: _pregnancyWeekController,
                prefixIcon: Icons.child_friendly_outlined,
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
              const SizedBox(height: 32),

              // Tombol simpan
              if (_isEditing)
                GradientButton(
                  text: 'Simpan Perubahan',
                  isLoading: context.watch<ProfileProvider>().isSaving,
                  onPressed: _save,
                ),
            ],
          ),
        ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Data Field ────────────────────────────────────────────────────────────
class _DataField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool isEditing;
  final bool isDark;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _DataField({
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
        // Mode view: tampilkan sebagai container biasa
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
        // Mode edit: tampilkan TextFormField
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
