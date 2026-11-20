# Detox-App (Code-to-Unlock) 🚀

> **Master your digital habits by earning screen time through code.**  
> An intelligent Android screen-time restriction and digital detox application built with Flutter and Native Android Kotlin services.

---

## 📌 Overview

**Detox-App** flips digital distraction on its head. Instead of weak self-control reminders, it strictly enforces your daily screen-time limits on selected apps using native Android accessibility and usage tracking services. 

When your daily allowance on an app expires, the app locks down. To earn **15 additional minutes**, you must solve authentic coding challenges in an interactive multi-language code editor. With an **exponential daily doubling challenge system** ($1 \rightarrow 2 \rightarrow 4 \rightarrow 8 \dots$), every extra unlock makes you think twice and practice more code!

---

## ✨ Key Features

### 1. 🎯 Individual App Limits & Custom Detoxing
* **Full Device App Discovery:** Automatically scans and detects all installed user applications on your device using Android's native `PackageManager`.
* **Per-App Toggle Control:** You choose exactly which apps to detox (e.g., Instagram, YouTube, TikTok, Reddit). Untoggled apps remain completely unrestricted.
* **Custom Time Budgets:** Set independent daily time budgets per application (e.g., 30 minutes for social media, 2 hours for video streaming).

### 2. 🛡️ Native Background Enforcement & Real-Time Lockout
* **Real Android Screen-Time Tracking:** Reads foreground app usage via Android's `UsageStatsManager` (`queryAndAggregateUsageStats`), ensuring screen time reflects true device usage.
* **Instant Foreground Interception:** Powered by a native Kotlin `AccessibilityService` (`AppRestrictionAccessibilityService.kt`), the app detects foreground window changes within milliseconds.
* **Strict Lockout:** If an app exceeds its limit and has no active unlock session, it immediately blocks access, closes the restricted app, and displays the Detox restriction overlay.
* **Reboot Resilience:** `BootReceiver.kt` listens for `BOOT_COMPLETED` to ensure monitoring and restrictions resume automatically after restarting your phone.

### 3. 📈 Exponential Challenge Doubling System ($1 \rightarrow 2 \rightarrow 4 \dots$)
* When an app reaches its daily limit, you can request an **extra 15 minutes**.
* To unlock, you must solve coding problems:
  * **1st Unlock of the day:** **1** coding problem
  * **2nd Unlock of the day:** **2** coding problems
  * **3rd Unlock of the day:** **4** coding problems
  * **4th Unlock of the day:** **8** coding problems ($2^{n-1}$)
* The counter resets daily at midnight.
* Upon passing all required test cases, a 15-minute countdown session starts. Once the timer expires, the app locks again until the next challenge is solved.

### 4. 💻 In-App Code Editor & Challenge Engine
* **Clean Code Editor:** Starts completely empty with helpful placeholders—no pre-filled answers—ensuring genuine practice.
* **Multi-Language Support:** Solve problems in **Python**, **JavaScript**, or **Dart**.
* **Anti-Paste Detection:** Monitors manual typing and input pacing to prevent mindless copy-pasting.
* **Diverse Question Bank:** Includes both curated problems and procedural algorithmic challenges across **Easy**, **Medium**, and **Hard** tiers.
* **Test Case Validator:** Tests your code against sample and hidden test cases with immediate feedback on syntax, execution, and outputs.

### 5. 🏆 Gamification & Analytics
* **XP & Leveling:** Earn Experience Points (XP) for every problem solved and level up along a developer roadmap.
* **Streaks & Achievements:** Maintain daily detox streaks and unlock badges for milestones.
* **Visual Usage Insights:** Interactive daily and weekly usage charts powered by `fl_chart`.
* **Emergency Override:** A guarded emergency unlock dialog with daily cooldowns and penalty mechanisms for urgent access.

---

## 🏗️ Architecture & Project Structure

The project uses a clean **Provider + Repository Pattern** on the Flutter frontend, connected via an asynchronous `MethodChannel` (`com.codetounlock.app/usage`) to the native Android platform layer.

```text
Detox-App/
├── android/                                # Native Android Implementation
│   ├── app/src/main/
│   │   ├── kotlin/com/codetounlock/app/code_to_unlock/
│   │   │   ├── MainActivity.kt             # Flutter MethodChannel bridge & app discovery
│   │   │   ├── AppRestrictionAccessibilityService.kt  # Real-time foreground app blocker
│   │   │   ├── UsageStatsHelper.kt         # Android UsageStatsManager integration
│   │   │   └── BootReceiver.kt             # Resumes protection upon device boot
│   │   ├── res/xml/
│   │   │   └── accessibility_service_config.xml # Accessibility configuration
│   │   └── AndroidManifest.xml             # Permission declarations & service registrations
│   └── build.gradle.kts                    # Android Gradle configuration
├── lib/                                    # Flutter Frontend (Dart)
│   ├── core/
│   │   ├── constants/                      # AppColors, AppConstants
│   │   ├── services/                       # NotificationService
│   │   ├── theme/                          # Dark glassmorphic AppTheme
│   │   └── utils/                          # Time formatting & helpers
│   ├── data/
│   │   ├── execution/                      # CodeExecutionEngine & TestCaseValidator
│   │   ├── models/                         # ManagedApp, Question, Submission, Progress models
│   │   ├── platform/                       # AppUsageBridge (MethodChannel client)
│   │   ├── questions/                      # CuratedProblemBank & ProceduralProblemGenerator
│   │   └── repositories/                   # AppUsage, Question, Progression, Preferences repos
│   ├── providers/                          # UsageTrackingProvider, ChallengeProvider, ProgressionProvider
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── app_management/             # App list, per-app toggles, and limit dialog
│   │   │   ├── coding/                     # Code editor, challenge screen, test sheet
│   │   │   ├── dashboard/                  # Main dashboard, timer indicator, quick stats
│   │   │   ├── gamification/               # Achievements & badges
│   │   │   ├── progression/                # Level roadmap
│   │   │   ├── restriction/                # Lockout overlay screen
│   │   │   └── settings/                   # App settings & emergency override
│   │   └── widgets/                        # Glassmorphic cards, custom buttons, badges
│   └── main.dart                           # App entry point & multi-provider initialization
├── pubspec.yaml                            # Flutter package dependencies
└── README.md                               # Project documentation
```

---

## 🔒 Required Android Permissions

Because Detox-App actively enforces screen-time limits and blocks foreground applications, it requires the following system permissions on Android:

1. **Usage Access (`PACKAGE_USAGE_STATS`):**  
   Required to query daily foreground screen time for managed apps via `UsageStatsManager`.
2. **Accessibility Service (`BIND_ACCESSIBILITY_SERVICE`):**  
   Required for real-time window state monitoring (`TYPE_WINDOW_STATE_CHANGED`) to detect and lock restricted apps instantly when opened.
3. **Display Over Other Apps (`SYSTEM_ALERT_WINDOW`):**  
   Allows the app to display restriction alerts and prompt the coding challenge overlay over blocked apps.
4. **Boot Notification (`RECEIVE_BOOT_COMPLETED`):**  
   Ensures monitoring and restrictions persist automatically after restarting your phone.
5. **Post Notifications (`POST_NOTIFICATIONS`):**  
   Delivers time warnings (e.g., 5-minute warning) and streak notifications.

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.12.1` or higher)
* Android Studio with Android SDK (API 34+ recommended)
* Physical Android device or Android Emulator (API 29+)
* Java 17 or Java 21

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kc122307/Detox-App.git
   cd Detox-App
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on an Android device or emulator:**
   ```bash
   flutter run -d <device-id>
   ```
   *(e.g., `flutter run -d emulator-5554`)*

### Initial Device Setup

When launching the app for the first time:
1. Complete the onboarding screen.
2. Grant **Usage Access** in `Settings > Apps > Special app access > Usage access > Detox App`.
3. Enable **Accessibility Service** in `Settings > Accessibility > Downloaded apps > Detox App Restriction Service`.
4. Navigate to **Manage Apps**, toggle on the apps you want to limit, and set your daily time targets.

---

## 🛠️ Tech Stack & Dependencies

* **Flutter & Dart:** Cross-platform reactive UI
* **Provider (`^6.1.5`):** Reactive state management across usage tracking, progression, and coding challenges
* **fl_chart (`^1.3.1`):** Smooth, animated charts for analytics
* **google_fonts (`^8.2.1`):** Clean developer typography (Fira Code, Inter)
* **shared_preferences (`^2.5.6`):** Fast local key-value persistence for usage stats, unlock sessions, and limits
* **intl (`^0.20.3`):** Date formatting and time utilities
* **uuid (`^4.6.0`):** Unique identifier generation for sessions and submissions
* **Android Native (Kotlin):** `AccessibilityService`, `UsageStatsManager`, `PackageManager`, `BroadcastReceiver`

---

## 📄 License

This project is licensed under the MIT License. Feel free to fork, customize, and build upon it!
