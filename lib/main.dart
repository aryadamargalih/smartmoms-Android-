import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login/login_screen.dart';
import 'features/auth/register/register_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/ai_chat/ai_chat_screen.dart';
import 'features/statistics/statistics_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/questionnaire/questionnaire_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/education/education_screen.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/health_provider.dart';
import 'core/providers/sleep_provider.dart';
import 'core/providers/mood_provider.dart';
import 'core/providers/questionnaire_provider.dart';
import 'core/providers/inbox_provider.dart';
import 'core/providers/education_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/statistics_provider.dart';
import 'core/services/api_service.dart';
import 'features/video/video_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// di routes:
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => QuestionnaireProvider()),
        ChangeNotifierProvider(create: (_) => InboxProvider()),
        ChangeNotifierProvider(create: (_) => EducationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: const SmartMomsApp(),
    ),
  );
}

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggle() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();

class SmartMomsApp extends StatefulWidget {
  const SmartMomsApp({super.key});

  @override
  State<SmartMomsApp> createState() => _SmartMomsAppState();
}

class _SmartMomsAppState extends State<SmartMomsApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (_, __) => MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeNotifier.themeMode,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.dashboard: (_) => const MainScreen(),
          AppRoutes.aiChat: (_) => const AiChatScreen(),
          '/statistics': (_) => const StatisticsScreen(),
          '/profile': (_) => const ProfileScreen(),
          AppRoutes.questionnaire: (_) => const QuestionnaireScreen(),
          AppRoutes.education: (_) => const EducationScreen(),
          AppRoutes.video: (_) => const VideoScreen(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int? _sessionId;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const StatisticsScreen(),
    const AiChatScreen(),
    const ProfileScreen(),
  ];

  void setIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start Session
    _startSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App kembali ke foreground
        _startSession();
        _refreshOnResume();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App ke background atau tidak aktif
        _endSession();
        break;
      default:
        break;
    }
  }

  // ── Start Session ───────────────────────────────────────────────────
  Future<void> _startSession() async {
    try {
      final response = await ApiService.post('/user/session/start');
      if (response['success'] == true) {
        _sessionId = response['data']['session_id'];
      }
    } catch (e) {
      // Silent fail — jangan crash app
      debugPrint('Session start error: $e');
    }
  }

  // ── End Session ─────────────────────────────────────────────────────
  Future<void> _endSession() async {
    if (_sessionId == null) return; // skip kalau belum ada sesi aktif

    try {
      await ApiService.post(
        '/user/session/end',
        body: {'session_id': _sessionId},
      );
      _sessionId = null; // reset session id
    } catch (e) {
      // Silent fail — jangan crash app
      debugPrint('Session end error: $e');
    }
  }

  // ── Refresh data saat resume ────────────────────────────────────────
  Future<void> _refreshOnResume() async {
    if (!mounted) return;
    context.read<HealthProvider>().refreshAll();
    context.read<SleepProvider>().fetchToday();
    context.read<InboxProvider>().fetchMessages();
    await context.read<MoodProvider>().fetchToday();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAiChat = _currentIndex == 2;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: isAiChat
          ? null
          : Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    width: 1,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                selectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                ),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart_outlined),
                    activeIcon: Icon(Icons.bar_chart_rounded),
                    label: 'Statistik',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.auto_awesome_outlined),
                    activeIcon: Icon(Icons.auto_awesome_rounded),
                    label: 'AI Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    activeIcon: Icon(Icons.person_rounded),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
    );
  }
}
