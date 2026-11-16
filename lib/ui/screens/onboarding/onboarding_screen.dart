import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/platform/app_usage_bridge.dart';
import '../../../data/repositories/user_preferences_repository.dart';
import '../../../providers/usage_tracking_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glassmorphic_card.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form states
  final Set<String> _selectedGoals = {
    'Reduce social media usage',
    'Improve DSA skills',
    'Prepare for technical interviews',
  };
  String _selectedLanguage = 'Python';
  int _dailyCodingGoal = 2; // problems
  int _dailyScreenTimeGoal = 90; // minutes
  final Set<String> _selectedAppPackages = {
    'com.google.android.youtube',
    'com.instagram.android',
    'com.reddit.frontpage',
  };

  final List<String> _availableGoals = [
    'Reduce social media usage',
    'Improve DSA skills',
    'Prepare for technical interviews',
    'Build daily coding consistency',
    'Improve productivity & focus',
  ];

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefsRepo = context.read<UserPreferencesRepository>();
    final usageProvider = context.read<UsageTrackingProvider>();

    await prefsRepo.setPreferredLanguage(_selectedLanguage);
    await prefsRepo.setSelectedGoals(_selectedGoals.toList());
    await prefsRepo.setDailyCodingGoal(_dailyCodingGoal);
    await prefsRepo.setOnboardingComplete(true);

    // Update app protection states
    for (final app in usageProvider.managedApps) {
      final isSelected = _selectedAppPackages.contains(app.packageName);
      await usageProvider.toggleProtection(app.packageName, isSelected);
    }

    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primary
                            : AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildGoalsPage(),
                  _buildLanguagePage(),
                  _buildDailyTargetsPage(),
                  _buildPermissionsPage(),
                  _buildAppSelectionPage(),
                ],
              ),
            ),

            // Bottom Navigation Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage > 0) ...[
                    OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: CustomGradientButton(
                      text: _currentPage == 5 ? 'Get Started' : 'Continue',
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Screen 1: Welcome ---
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(90),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.code, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(
            AppConstants.appName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.appTagline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 20),
          GlassmorphicCard(
            padding: const EdgeInsets.all(20),
            child: Text(
              AppConstants.appPhilosophy,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Screen 2: Choose Goals ---
  Widget _buildGoalsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are your goals?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Personalize your digital detox and coding journey.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _availableGoals.length,
              itemBuilder: (context, index) {
                final goal = _availableGoals[index];
                final isSelected = _selectedGoals.contains(goal);
                return GlassmorphicCard(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGoals.remove(goal);
                      } else {
                        _selectedGoals.add(goal);
                      }
                    });
                  },
                  margin: const EdgeInsets.only(bottom: 12),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 1.5)
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          goal,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Screen 3: Preferred Language ---
  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferred Language',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your primary language for solving challenges. You can change this at any time.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          ...AppConstants.supportedLanguages.map((lang) {
            final isSelected = _selectedLanguage == lang;
            return GlassmorphicCard(
              onTap: () => setState(() => _selectedLanguage = lang),
              margin: const EdgeInsets.only(bottom: 12),
              border: isSelected
                  ? Border.all(color: AppColors.secondary, width: 1.5)
                  : null,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondary.withAlpha(40)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        lang == 'JavaScript' ? 'JS' : (lang == 'Python' ? 'PY' : (lang == 'Java' ? 'JV' : 'C++')),
                        style: TextStyle(
                          color: isSelected ? AppColors.secondary : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    lang,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check, color: AppColors.secondary),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Screen 4: Daily Goals ---
  Widget _buildDailyTargetsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set Daily Targets',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Form healthy screen-time habits and steady coding discipline.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          GlassmorphicCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily Coding Target',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$_dailyCodingGoal Problems / Day',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _dailyCodingGoal.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (val) => setState(() => _dailyCodingGoal = val.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassmorphicCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Target Screen Time',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$_dailyScreenTimeGoal Minutes',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _dailyScreenTimeGoal.toDouble(),
                  min: 30,
                  max: 240,
                  divisions: 7,
                  onChanged: (val) => setState(() => _dailyScreenTimeGoal = val.round()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Screen 5: Grant Permissions ---
  Widget _buildPermissionsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grant Permissions',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We strictly protect your privacy. Required permissions are used locally to enforce your chosen app limits.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          _buildPermissionItem(
            icon: Icons.data_usage,
            title: 'Usage Access',
            description: 'Accurately measures active screen time for selected applications.',
            onTap: AppUsageBridge.requestUsagePermission,
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            icon: Icons.accessibility_new,
            title: 'Accessibility Service',
            description: 'Enables instant detection of restricted apps to present the unlock challenge.',
            onTap: AppUsageBridge.requestAccessibilityPermission,
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            icon: Icons.notifications_active,
            title: 'Notifications',
            description: 'Alerts you when an application allowance is close to expiring.',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GlassmorphicCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: const Text('Enable', style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }

  // --- Screen 6: Application Selection ---
  Widget _buildAppSelectionPage() {
    final apps = context.watch<UsageTrackingProvider>().managedApps;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Target Apps',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose the applications you want to manage with programming challenges.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final isSelected = _selectedAppPackages.contains(app.packageName);

                return GlassmorphicCard(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedAppPackages.remove(app.packageName);
                      } else {
                        _selectedAppPackages.add(app.packageName);
                      }
                    });
                  },
                  margin: const EdgeInsets.only(bottom: 10),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 1.5)
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          app.appName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${app.dailyLimitMinutes} min limit',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
