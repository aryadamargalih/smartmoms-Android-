import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _deliveryDateController = TextEditingController();
  DateTime? _selectedDeliveryDate;

  bool _isLoading = false;
  int _currentStep = 0; // 0: personal info, 1: account info

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDeliveryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now()
          .subtract(const Duration(days: 60)), // maks 60 hari lalu
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Melahirkan',
      confirmText: 'Pilih',
      cancelText: 'Batal',
    );
    if (picked != null) {
      setState(() {
        _selectedDeliveryDate = picked;
        _deliveryDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buat Akun',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              Row(
                children: [
                  _StepDot(
                      step: 1, isActive: _currentStep >= 0, label: 'Data Diri'),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep >= 1
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider),
                    ),
                  ),
                  _StepDot(step: 2, isActive: _currentStep >= 1, label: 'Akun'),
                ],
              ),
              const SizedBox(height: 32),

              if (_currentStep == 0) ...[
                // Step 1: Personal info
                Text(
                  'Data Diri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lengkapi informasi pribadi kamu',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                AppTextField(
                  label: AppStrings.fullName,
                  hint: 'Nama lengkap kamu',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 18),

                AppTextField(
                  label: AppStrings.phoneNumber,
                  hint: '08xxxxxxxxxx',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Nomor telepon tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 18),

                // Pregnancy week field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Melahirkan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickDeliveryDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkDivider
                                    : AppColors.lightDivider,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.child_friendly_outlined,
                                    size: 20, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedDeliveryDate == null
                                      ? 'Pilih tanggal melahirkan'
                                      : '${_selectedDeliveryDate!.day.toString().padLeft(2, '0')}/${_selectedDeliveryDate!.month.toString().padLeft(2, '0')}/${_selectedDeliveryDate!.year}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _selectedDeliveryDate == null
                                        ? (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary)
                                        : (isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                // Step 2: Account info
                Text(
                  'Buat Akun',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Buat email dan password untuk masuk',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                AppTextField(
                  label: AppStrings.email,
                  hint: 'contoh@email.com',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Email tidak boleh kosong';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                AppTextField(
                  label: AppStrings.password,
                  hint: 'Minimal 8 karakter',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Password tidak boleh kosong';
                    if (v.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                AppTextField(
                  label: AppStrings.confirmPassword,
                  hint: 'Ulangi password kamu',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (v) {
                    if (v != _passwordController.text)
                      return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Terms
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (_) {},
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: RichText(
                          text: TextSpan(
                            text: 'Saya setuju dengan ',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontFamily: 'Poppins',
                            ),
                            children: const [
                              TextSpan(
                                text: 'Syarat & Ketentuan',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: ' dan '),
                              TextSpan(
                                text: 'Kebijakan Privasi',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Buttons
              if (_currentStep == 0)
                GradientButton(
                  text: 'Selanjutnya',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _currentStep = 1);
                    }
                  },
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep = 0),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        text: AppStrings.register,
                        isLoading: context.watch<AuthProvider>().isLoading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final authProvider = context.read<AuthProvider>();
                            final success = await authProvider.register(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              phone: _phoneController.text,
                              deliveryDate: _deliveryDateController.text,
                            );

                            if (success && mounted) {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.dashboard);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authProvider.errorMessage ??
                                      'Registrasi gagal'),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: AppStrings.alreadyHaveAccount,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int step;
  final bool isActive;
  final String label;

  const _StepDot(
      {required this.step, required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.lightDivider,
              width: 2,
            ),
          ),
          child: Center(
            child: isActive
                ? Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  )
                : Text(
                    '$step',
                    style: const TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
