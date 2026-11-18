package com.codetounlock.app.code_to_unlock

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent

class AppRestrictionAccessibilityService : AccessibilityService() {

    private val monitorHandler = Handler(Looper.getMainLooper())
    private var currentForegroundPkg: String? = null
    private var foregroundStartTime: Long = 0L
    private var usageStatsHelper: UsageStatsHelper? = null

    private val checkForegroundRunnable = object : Runnable {
        override fun run() {
            val pkg = currentForegroundPkg ?: return
            checkAndEnforcePackage(pkg)
            monitorHandler.postDelayed(this, 1000L)
        }
    }

    companion object {
        const val PREFS_NAME = "code_to_unlock_native_prefs"
        const val KEY_RESTRICTED_PACKAGES = "restricted_packages"
        const val KEY_ACTIVE_REWARDS = "active_rewards"
        const val KEY_PROTECTED_LIMITS = "protected_limits"

        var isServiceActive: Boolean = false
        var restrictedPackages: MutableSet<String> = HashSet()
        var activeRewards: MutableMap<String, Long> = HashMap() // PackageName -> Expiration epoch millis
        var protectedLimits: MutableMap<String, Long> = HashMap() // PackageName -> Limit in seconds
        var pendingRestrictedPackage: String? = null

        fun saveRestrictions(
            context: Context,
            packages: Set<String>,
            rewards: Map<String, Long>,
            limits: Map<String, Long>
        ) {
            restrictedPackages = HashSet(packages)
            activeRewards = HashMap(rewards)
            protectedLimits = HashMap(limits)

            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val editor = prefs.edit()
            editor.putStringSet(KEY_RESTRICTED_PACKAGES, packages)

            // Store rewards as key-value pairs formatted as "pkg:epoch"
            val rewardsSet = rewards.map { "${it.key}:${it.value}" }.toSet()
            editor.putStringSet(KEY_ACTIVE_REWARDS, rewardsSet)

            // Store limits as key-value pairs formatted as "pkg:limitSeconds"
            val limitsSet = limits.map { "${it.key}:${it.value}" }.toSet()
            editor.putStringSet(KEY_PROTECTED_LIMITS, limitsSet)

            editor.apply()
        }

        fun loadRestrictions(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            restrictedPackages = HashSet(prefs.getStringSet(KEY_RESTRICTED_PACKAGES, emptySet()) ?: emptySet())

            val rewardsSet = prefs.getStringSet(KEY_ACTIVE_REWARDS, emptySet()) ?: emptySet()
            val loadedRewards = HashMap<String, Long>()
            val now = System.currentTimeMillis()

            for (item in rewardsSet) {
                val parts = item.split(":")
                if (parts.size == 2) {
                    val pkg = parts[0]
                    val epoch = parts[1].toLongOrNull() ?: 0L
                    if (epoch > now) {
                        loadedRewards[pkg] = epoch
                    }
                }
            }
            activeRewards = loadedRewards

            val limitsSet = prefs.getStringSet(KEY_PROTECTED_LIMITS, emptySet()) ?: emptySet()
            val loadedLimits = HashMap<String, Long>()
            for (item in limitsSet) {
                val parts = item.split(":")
                if (parts.size == 2) {
                    val pkg = parts[0]
                    val limit = parts[1].toLongOrNull() ?: 3600L
                    loadedLimits[pkg] = limit
                }
            }
            protectedLimits = loadedLimits
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isServiceActive = true
        usageStatsHelper = UsageStatsHelper(applicationContext)
        loadRestrictions(applicationContext)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            return
        }

        val packageName = event.packageName?.toString() ?: return

        // Ignore our own application and system components
        if (packageName == applicationContext.packageName ||
            packageName == "com.android.systemui" ||
            packageName.contains("launcher")
        ) {
            stopForegroundMonitoring()
            return
        }

        // If in-memory state is empty, attempt reload from persistent preferences
        if (protectedLimits.isEmpty() && restrictedPackages.isEmpty()) {
            loadRestrictions(applicationContext)
        }

        // Check if package is protected or restricted
        if (protectedLimits.containsKey(packageName) || restrictedPackages.contains(packageName)) {
            currentForegroundPkg = packageName
            foregroundStartTime = System.currentTimeMillis()
            
            // Check immediately on app open
            val blocked = checkAndEnforcePackage(packageName)
            if (!blocked) {
                // If not blocked immediately, start real-time second-by-second enforcement
                monitorHandler.removeCallbacks(checkForegroundRunnable)
                monitorHandler.postDelayed(checkForegroundRunnable, 1000L)
            }
        } else {
            stopForegroundMonitoring()
        }
    }

    private fun checkAndEnforcePackage(packageName: String): Boolean {
        val now = System.currentTimeMillis()
        val rewardExpiration = activeRewards[packageName]
        val isRewardValid = rewardExpiration != null && now < rewardExpiration

        if (isRewardValid) {
            // Unlocked via coding challenge reward
            return false
        }

        val limitSeconds = protectedLimits[packageName] ?: Long.MAX_VALUE
        val helper = usageStatsHelper ?: UsageStatsHelper(applicationContext).also { usageStatsHelper = it }
        val usedSeconds = helper.getUsageSecondsToday(packageName)

        val isExhausted = restrictedPackages.contains(packageName) || (usedSeconds >= limitSeconds)

        if (isExhausted) {
            restrictedPackages.add(packageName)
            triggerLockout(packageName)
            return true
        }

        return false
    }

    private fun triggerLockout(packageName: String) {
        stopForegroundMonitoring()
        pendingRestrictedPackage = packageName

        // 1. Instantly return Home so user cannot use the restricted app
        performGlobalAction(GLOBAL_ACTION_HOME)

        // 2. Launch Code to Unlock with restriction intent
        val launchIntent = packageManager.getLaunchIntentForPackage(applicationContext.packageName)?.apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("RESTRICTED_PACKAGE", packageName)
        }
        if (launchIntent != null) {
            startActivity(launchIntent)
        }

        // 3. Notify running Flutter engine if active
        MainActivity.notifyRestricted(packageName)
    }

    private fun stopForegroundMonitoring() {
        monitorHandler.removeCallbacks(checkForegroundRunnable)
        currentForegroundPkg = null
    }

    override fun onInterrupt() {
        stopForegroundMonitoring()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopForegroundMonitoring()
        isServiceActive = false
    }
}
