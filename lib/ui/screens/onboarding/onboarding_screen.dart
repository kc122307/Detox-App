import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/platform/app_usage_bridge.dart';
import '../../../data/repositories/user_preferences_repository.dart';
import '../../../providers/usage_tracking_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glassmorphic_card.dart';
import '../app_management/app_limit_dialog.dart';

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
  String _selectedLanguage = 'Python';
  final Map<String, int> _appLimits = {};
  // All apps are OFF / unrestricted by default!
  // User must explicitly switch ON only the apps they want to restrict.
  final Set<String> _enabledAppPackages = {};
  String _appSearchQuery = '';
  bool _showOnlyEnabledApps = false;

  @override
  void initState() {
    super.initState();
    // Default baseline limits when an app is switched ON
    _appLimits['com.google.android.youtube'] = 60; // 1 hour
    _appLimits['com.instagram.android'] = 60; // 1 hour
    _appLimits['com.reddit.frontpage'] = 30; // 30 minutes
    _appLimits['com.facebook.katana'] = 30;
    _appLimits['com.snapchat.android'] = 30;
    _appLimits['com.twitter.android'] = 30;
    _appLimits['com.whatsapp'] = 120; // 2 hours
  }

  void _nextPage() {
    if (_currentPage < 4) {
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
    await prefsRepo.setOnboardingComplete(true);

    // Save individual per-app configuration
    for (final app in usageProvider.managedApps) {
      final isProtected = _enabledAppPackages.contains(app.packageName);
      await usageProvider.toggleProtection(app.packageName, isProtected);

      final customLimit = _appLimits[app.packageName];
      if (customLimit != null) {
        await usageProvider.updateAppLimit(app.packageName, customLimit);
      }
    }

    widget.onFinish();
  }

  String _formatLimitText(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMins = minutes % 60;
      if (remainingMins == 0) {
        return '$hours hr${hours > 1 ? "s" : ""}';
      }
      return '$hours hr $remainingMins min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(5, (index) {
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
                  _buildLanguagePage(),
                  _buildPermissionsPage(),
                  _buildAppConfigPage(),
                  _buildHowUnlocksWorkPage(),
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
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: CustomGradientButton(
                      text: _currentPage == 4 ? 'Get Started' : 'Continue',
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

  // --- Screen 1: Welcome & Philosophy ---
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(90),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.code, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text(
            AppConstants.appName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.appTagline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 24),
          GlassmorphicCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  AppConstants.appPhilosophy,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.surfaceBorder, height: 1),
                const SizedBox(height: 16),
                _buildPhilosophyPill(
                  Icons.tune,
                  'Individual App Limits',
                  'Set 1h for Instagram, 2h for YouTube, or turn off detox for apps you choose.',
                ),
                const SizedBox(height: 12),
                _buildPhilosophyPill(
                  Icons.lock_clock,
                  'Earn Screen Time',
                  'When an app limit is exhausted, solve coding interview problems to unlock 20 minutes.',
                ),
                const SizedBox(height: 12),
                _buildPhilosophyPill(
                  Icons.trending_up,
                  'Daily Escalation',
                  'Unlocks double in challenge count each time (1 → 2 → 4 → 8...).',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophyPill(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Screen 2: Language Selection ---
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
            'Choose your primary programming language for solving coding interview challenges.',
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondary.withAlpha(40)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        lang == 'JavaScript'
                            ? 'JS'
                            : (lang == 'Python'
                                ? 'PY'
                                : (lang == 'Java' ? 'JV' : 'C++')),
                        style: TextStyle(
                          color: isSelected ? AppColors.secondary : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                    const Icon(Icons.check_circle, color: AppColors.secondary),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Screen 3: Permissions ---
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
            'These permissions run 100% locally on your device to track your foreground app usage and enforce your custom limits.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          _buildPermissionItem(
            icon: Icons.data_usage,
            title: 'Usage Access Permission',
            description: 'Accurately tracks active screen time per application locally.',
            onTap: AppUsageBridge.requestUsagePermission,
          ),
          const SizedBox(height: 14),
          _buildPermissionItem(
            icon: Icons.accessibility_new,
            title: 'Accessibility Service',
            description: 'Enforces restriction overlay when an app exhausts its allowance.',
            onTap: AppUsageBridge.requestAccessibilityPermission,
          ),
          const SizedBox(height: 14),
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
            child: Icon(icon, color: AppColors.primaryLight, size: 24),
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
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.secondary,
            ),
            child: const Text('Enable', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Screen 4: Individual App Limits (Star Screen) ---
  Widget _buildAppConfigPage() {
    final usageProvider = context.watch<UsageTrackingProvider>();
    final allApps = usageProvider.managedApps;

    final filteredApps = allApps.where((app) {
      if (_showOnlyEnabledApps && !_enabledAppPackages.contains(app.packageName)) {
        return false;
      }
      if (_appSearchQuery.isEmpty) return true;
      return app.appName.toLowerCase().contains(_appSearchQuery.toLowerCase()) ||
          app.packageName.toLowerCase().contains(_appSearchQuery.toLowerCase()) ||
          app.category.toLowerCase().contains(_appSearchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configure Individual Apps',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'All apps on your phone are unrestricted by default. Switch ON detox only for the apps you want to limit, and set their allowed time (e.g. 1 hour, 2 hours).',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          // Search Box
          TextField(
            onChanged: (val) => setState(() => _appSearchQuery = val),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search installed applications...',
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceBorder),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Row: All Apps vs Switched ON
          Row(
            children: [
              _buildFilterBadge('All Apps (${allApps.length})', !_showOnlyEnabledApps, () {
                setState(() => _showOnlyEnabledApps = false);
              }),
              const SizedBox(width: 8),
              _buildFilterBadge('Switched ON (${_enabledAppPackages.length})', _showOnlyEnabledApps, () {
                setState(() => _showOnlyEnabledApps = true);
              }),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: filteredApps.isEmpty
                ? Center(
                    child: Text(
                      _showOnlyEnabledApps
                          ? 'No apps switched ON yet.\nToggle the switch for apps you want to limit.'
                          : 'No matching installed applications found.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = filteredApps[index];
                      final isEnabled = _enabledAppPackages.contains(app.packageName);
                      final currentLimit = _appLimits[app.packageName] ?? app.dailyLimitMinutes;

                      return GlassmorphicCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        border: isEnabled
                            ? Border.all(color: AppColors.primary.withAlpha(140), width: 1.5)
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: App Name + Switch
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isEnabled
                                        ? AppColors.primary.withAlpha(40)
                                        : AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.apps,
                                    color: isEnabled ? AppColors.primaryLight : AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.appName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isEnabled
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isEnabled
                                            ? 'Daily limit: ${_formatLimitText(currentLimit)}'
                                            : 'Free to use freely (Detox OFF)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isEnabled
                                              ? AppColors.secondary
                                              : AppColors.textMuted,
                                          fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isEnabled,
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val) {
                                        _enabledAppPackages.add(app.packageName);
                                      } else {
                                        _enabledAppPackages.remove(app.packageName);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),

                            // If Detox is ON: show quick preset chips for 30m, 1h, 2h, and custom
                            if (isEnabled) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildPresetChip(app.packageName, 30, '30m', currentLimit),
                                  const SizedBox(width: 6),
                                  _buildPresetChip(app.packageName, 60, '1 hour', currentLimit),
                                  const SizedBox(width: 6),
                                  _buildPresetChip(app.packageName, 120, '2 hours', currentLimit),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AppLimitDialog(
                                          appName: app.appName,
                                          currentLimitMinutes: currentLimit,
                                          onSave: (newMinutes) {
                                            setState(() {
                                              _appLimits[app.packageName] = newMinutes;
                                            });
                                          },
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.surfaceBorder),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.edit, size: 12, color: AppColors.textSecondary),
                                          SizedBox(width: 4),
                                          Text('Custom', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buildFilterBadge(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(40) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String packageName, int minutes, String label, int currentLimit) {
    final isSelected = currentLimit == minutes;
    return InkWell(
      onTap: () {
        setState(() {
          _appLimits[packageName] = minutes;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // --- Screen 5: How Unlocks Work (The Doubling Rule) ---
  Widget _buildHowUnlocksWorkPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How Unlocks Work',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'When an application exceeds its limit, access is restricted. Earn screen time by solving coding interview problems.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                // 20-minute reward card
                GlassmorphicCard(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.timer, color: AppColors.secondary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fixed 20-Minute Rewards',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'A successful unlock grants exactly 20 minutes to that specific app. When expired, the app locks again.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Exponential Doubling Rule Card
                GlassmorphicCard(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.trending_up, color: AppColors.primaryLight, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Daily Question Doubling Rule',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Every time you unlock extra time today (for the same or different apps), the required coding challenges double:',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      _buildDoublingRow('1st Unlock Today', '1 Coding Question', AppColors.primaryLight),
                      const SizedBox(height: 6),
                      _buildDoublingRow('2nd Unlock Today', '2 Coding Questions (Doubled)', Colors.amber),
                      const SizedBox(height: 6),
                      _buildDoublingRow('3rd Unlock Today', '4 Coding Questions (Doubled)', Colors.orange),
                      const SizedBox(height: 6),
                      _buildDoublingRow('4th Unlock Today', '8 Coding Questions', Colors.deepOrange),
                      const SizedBox(height: 8),
                      const Text(
                        'Counter resets at midnight daily.',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

                // Anti-Cheating & Manual Typing
                GlassmorphicCard(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.keyboard, color: AppColors.error, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manual Typing Required',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'You must manually type your complete solution. Copy-pasting is flagged and will not unlock time.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoublingRow(String step, String questions, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(step, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(35),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              questions,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
            ),
          ),
        ],
      ),
    );
  }
}
