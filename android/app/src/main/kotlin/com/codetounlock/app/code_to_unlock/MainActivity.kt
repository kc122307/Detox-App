package com.codetounlock.app.code_to_unlock

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.codetounlock/usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val usageHelper = UsageStatsHelper(this)

        // Load existing persistent restrictions
        AppRestrictionAccessibilityService.loadRestrictions(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsagePermission" -> {
                    result.success(usageHelper.hasUsageStatsPermission())
                }
                "requestUsagePermission" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(true)
                }
                "hasAccessibilityPermission" -> {
                    result.success(AppRestrictionAccessibilityService.isServiceActive)
                }
                "requestAccessibilityPermission" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                }
                "getInstalledApps" -> {
                    val appsList = ArrayList<Map<String, Any>>()
                    val pm = packageManager
                    val launcherIntent = Intent(Intent.ACTION_MAIN, null).apply {
                        addCategory(Intent.CATEGORY_LAUNCHER)
                    }
                    val resolveInfos = pm.queryIntentActivities(launcherIntent, 0)
                    val seenPackages = HashSet<String>()

                    for (info in resolveInfos) {
                        val pkgName = info.activityInfo.packageName
                        // Exclude Code to Unlock self
                        if (pkgName == packageName || seenPackages.contains(pkgName)) {
                            continue
                        }
                        seenPackages.add(pkgName)

                        val appName = info.loadLabel(pm)?.toString() ?: pkgName
                        val isSystem = (info.activityInfo.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

                        val appMap = HashMap<String, Any>()
                        appMap["packageName"] = pkgName
                        appMap["appName"] = appName
                        appMap["isSystem"] = isSystem
                        appMap["category"] = if (isSystem) "System" else "Installed"
                        appsList.add(appMap)
                    }

                    // Sort alphabetically by app name
                    appsList.sortBy { (it["appName"] as? String)?.lowercase() ?: "" }
                    result.success(appsList)
                }
                "updateActiveRestrictions" -> {
                    val restrictedList = call.argument<List<String>>("restrictedPackages") ?: emptyList()
                    val activeRewardsMap = call.argument<Map<String, Int>>("activeRewards") ?: emptyMap()

                    val now = System.currentTimeMillis()
                    val epochRewards = HashMap<String, Long>()
                    for ((pkg, secsLeft) in activeRewardsMap) {
                        epochRewards[pkg] = now + (secsLeft * 1000L)
                    }

                    // Save to persistent SharedPreferences and in-memory static state
                    AppRestrictionAccessibilityService.saveRestrictions(
                        this,
                        restrictedList.toSet(),
                        epochRewards
                    )

                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
