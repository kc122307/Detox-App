package com.codetounlock.app.code_to_unlock

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.codetounlock/usage"
    private var methodChannel: MethodChannel? = null
    private var pendingRestrictedPkg: String? = null

    companion object {
        var activeInstance: MainActivity? = null

        fun notifyRestricted(packageName: String) {
            activeInstance?.runOnUiThread {
                activeInstance?.methodChannel?.invokeMethod("onAppRestricted", packageName)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        activeInstance = this
        handleIncomingIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIncomingIntent(intent)
    }

    private fun handleIncomingIntent(intent: Intent?) {
        val restrictedPkg = intent?.getStringExtra("RESTRICTED_PACKAGE")
            ?: AppRestrictionAccessibilityService.pendingRestrictedPackage

        if (restrictedPkg != null) {
            pendingRestrictedPkg = restrictedPkg
            AppRestrictionAccessibilityService.pendingRestrictedPackage = null
            methodChannel?.invokeMethod("onAppRestricted", restrictedPkg)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val usageHelper = UsageStatsHelper(this)
        AppRestrictionAccessibilityService.loadRestrictions(this)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
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

                        appsList.sortBy { (it["appName"] as? String)?.lowercase() ?: "" }
                        result.success(appsList)
                    }
                    "getRealUsageStats" -> {
                        val stats = usageHelper.getAllUsageSecondsToday()
                        result.success(stats)
                    }
                    "getPendingRestrictedPackage" -> {
                        val pkg = pendingRestrictedPkg
                        pendingRestrictedPkg = null
                        result.success(pkg)
                    }
                    "updateActiveRestrictions" -> {
                        val restrictedList = call.argument<List<String>>("restrictedPackages") ?: emptyList()
                        val activeRewardsMap = call.argument<Map<String, Int>>("activeRewards") ?: emptyMap()
                        val protectedLimitsMap = call.argument<Map<String, Int>>("protectedLimits") ?: emptyMap()

                        val now = System.currentTimeMillis()
                        val epochRewards = HashMap<String, Long>()
                        for ((pkg, secsLeft) in activeRewardsMap) {
                            epochRewards[pkg] = now + (secsLeft * 1000L)
                        }

                        val limits = HashMap<String, Long>()
                        for ((pkg, limitSecs) in protectedLimitsMap) {
                            limits[pkg] = limitSecs.toLong()
                        }

                        AppRestrictionAccessibilityService.saveRestrictions(
                            this@MainActivity,
                            restrictedList.toSet(),
                            epochRewards,
                            limits
                        )

                        result.success(true)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }

        // If there was a pending restricted package before engine was configured, deliver it now
        pendingRestrictedPkg?.let { pkg ->
            methodChannel?.invokeMethod("onAppRestricted", pkg)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (activeInstance == this) {
            activeInstance = null
        }
    }
}
