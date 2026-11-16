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
                    val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
                    for (pkg in packages) {
                        // Filter to launchable apps only
                        if (pm.getLaunchIntentForPackage(pkg.packageName) != null) {
                            val appName = pm.getApplicationLabel(pkg).toString()
                            val isSystem = (pkg.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                            val appMap = HashMap<String, Any>()
                            appMap["packageName"] = pkg.packageName
                            appMap["appName"] = appName
                            appMap["isSystem"] = isSystem
                            appMap["category"] = if (isSystem) "System" else "User Installed"
                            appsList.add(appMap)
                        }
                    }
                    result.success(appsList)
                }
                "updateActiveRestrictions" -> {
                    val restrictedList = call.argument<List<String>>("restrictedPackages") ?: emptyList()
                    val activeRewardsMap = call.argument<Map<String, Int>>("activeRewards") ?: emptyMap()

                    AppRestrictionAccessibilityService.restrictedPackages = restrictedList.toSet()

                    val now = System.currentTimeMillis()
                    val epochRewards = HashMap<String, Long>()
                    for ((pkg, secsLeft) in activeRewardsMap) {
                        epochRewards[pkg] = now + (secsLeft * 1000L)
                    }
                    AppRestrictionAccessibilityService.activeRewards = epochRewards
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
