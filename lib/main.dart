import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/app_usage_repository.dart';
import 'data/repositories/progression_repository.dart';
import 'data/repositories/question_repository.dart';
import 'data/repositories/user_preferences_repository.dart';
import 'providers/challenge_provider.dart';
import 'providers/progression_provider.dart';
import 'providers/usage_tracking_provider.dart';
import 'ui/screens/dashboard/dashboard_screen.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final notificationService = NotificationService(prefs);
  final userPreferencesRepo = UserPreferencesRepository(prefs);
  final appUsageRepo = AppUsageRepository(prefs);
  final progressionRepo = ProgressionRepository(prefs);
  final questionRepo = QuestionRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NotificationService>.value(value: notificationService),
        Provider<UserPreferencesRepository>.value(value: userPreferencesRepo),
        Provider<AppUsageRepository>.value(value: appUsageRepo),
        Provider<ProgressionRepository>.value(value: progressionRepo),
        Provider<QuestionRepository>.value(value: questionRepo),
        ChangeNotifierProvider<UsageTrackingProvider>(
          create: (_) => UsageTrackingProvider(appUsageRepo, notificationService: notificationService),
        ),
        ChangeNotifierProvider<ProgressionProvider>(
          create: (_) => ProgressionProvider(progressionRepo),
        ),
        ChangeNotifierProxyProvider2<ProgressionProvider, UsageTrackingProvider, ChallengeProvider>(
          create: (ctx) => ChallengeProvider(
            questionRepo,
            ctx.read<ProgressionProvider>(),
            ctx.read<UsageTrackingProvider>(),
            notificationService: notificationService,
          ),
          update: (ctx, progression, usage, previous) =>
              previous ?? ChallengeProvider(questionRepo, progression, usage, notificationService: notificationService),
        ),
      ],
      child: const CodeToUnlockApp(),
    ),
  );
}

class CodeToUnlockApp extends StatefulWidget {
  const CodeToUnlockApp({super.key});

  @override
  State<CodeToUnlockApp> createState() => _CodeToUnlockAppState();
}

class _CodeToUnlockAppState extends State<CodeToUnlockApp> {
  late bool _isOnboardingComplete;

  @override
  void initState() {
    super.initState();
    final prefsRepo = context.read<UserPreferencesRepository>();
    _isOnboardingComplete = prefsRepo.isOnboardingComplete;
  }

  void _finishOnboarding() {
    setState(() {
      _isOnboardingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code to Unlock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _isOnboardingComplete
          ? const DashboardScreen()
          : OnboardingScreen(onFinish: _finishOnboarding),
    );
  }
}
