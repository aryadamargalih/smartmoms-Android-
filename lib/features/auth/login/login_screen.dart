import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Top decorative header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.32,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                      AppColors.primaryLight
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  AppAssets.splashLogo,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Selamat Datang 👋',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Masuk untuk memantau kesehatanmu',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form card
            Positioned(
              top: size.height * 0.28,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Masuk Akun',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Masukkan email dan password kamu',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),

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
                          hint: '••••••••',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Password tidak boleh kosong';
                            if (v.length < 6)
                              return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style:
                                TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: const Text(
                              AppStrings.forgotPassword,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        GradientButton(
                          text: AppStrings.login,
                          isLoading: context.watch<AuthProvider>().isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final authProvider = context.read<AuthProvider>();
                              final success = await authProvider.login(
                                _emailController.text,
                                _passwordController.text,
                              );

                              if (success && mounted) {
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.dashboard);
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authProvider.errorMessage ??
                                        'Login gagal'),
                                    backgroundColor: AppColors.danger,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: isDark
                                        ? AppColors.darkDivider
                                        : AppColors.lightDivider)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'atau',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: isDark
                                        ? AppColors.darkDivider
                                        : AppColors.lightDivider)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Register prompt
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: AppStrings.dontHaveAccount,
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
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.register);
                                    },
                                    child: const Text(
                                      'Daftar',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
