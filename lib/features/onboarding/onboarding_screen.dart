import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.favorite_rounded,
      iconColor: AppColors.bpmColor,
      title: 'Pantau Detak Jantung',
      subtitle:
          'Monitor BPM kamu secara real-time\nmelalui smartwatch yang terhubung',
    ),
    _OnboardingData(
        icon: Icons.monitor_heart_rounded,
        iconColor: AppColors.primary,
        title: 'Tekanan Darah Terkontrol',
        subtitle:
            'Rekam dan analisis tekanan darah\nharian untuk masa nifas yang sehat'),
    _OnboardingData(
      icon: Icons.directions_walk_rounded,
      iconColor: AppColors.accent,
      title: 'Aktivitas Fisik Optimal',
      subtitle: 'Lacak langkah dan aktivitas fisik\nsesuai kebutuhan ibu nifas',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) =>
                    _OnboardingPage(data: _pages[i], size: size),
              ),
            ),

            // Dots + Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightDivider),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  GradientButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Mulai Sekarang'
                        : 'Selanjutnya',
                    onPressed: () async {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('onboarding_done', true);
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
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

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Size size;

  const _OnboardingPage({required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder
          Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.iconColor.withOpacity(isDark ? 0.1 : 0.07),
            ),
            child: Center(
              child: Container(
                width: size.width * 0.35,
                height: size.width * 0.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.iconColor.withOpacity(isDark ? 0.15 : 0.1),
                ),
                child: Icon(
                  data.icon,
                  size: size.width * 0.18,
                  color: data.iconColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  _OnboardingData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}
