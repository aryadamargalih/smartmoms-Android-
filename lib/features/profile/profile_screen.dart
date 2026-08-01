import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'personal_data_screen.dart';
import 'pregnancy_info_screen.dart';
import 'notification_screen.dart';
import 'help_screen.dart';
import '../../main.dart';
import '../education/education_screen.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Profil', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {}, // nanti buat edit profile screen
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'Nama User',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? 'email@email.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      )),
                  const SizedBox(height: 16),
                  // Pregnancy info
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('🤱 Minggu ke-24',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Menu list
            Container(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Data Pribadi',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PersonalDataScreen()),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.child_care_rounded,
                    label: 'Info Kehamilan',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PregnancyInfoScreen()),
                    ),
                  ),
                  // _ProfileMenuItem(
                  //   icon: Icons.watch_outlined,
                  //   label: 'Kelola Smartwatch',
                  //   onTap: () {},
                  // ),
                  _ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifikasi',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationScreen()),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.menu_book_outlined,
                    label: 'Edukasi Kesehatan',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EducationScreen()),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.assignment_outlined,
                    label: 'Kuesioner Kesehatan',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.questionnaire),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    label: isDark ? 'Mode Terang' : 'Mode Gelap',
                    onTap: () => themeNotifier.toggle(),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Bantuan',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Keluar',
                    color: AppColors.danger,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Keluar'),
                          content: const Text('Yakin ingin keluar dari akun?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Keluar',
                                  style: TextStyle(color: AppColors.danger)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.login);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemColor =
        color ?? (isDark ? AppColors.darkText : AppColors.lightText);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: itemColor))),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}
