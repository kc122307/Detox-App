package com.codetounlock.app.code_to_unlock

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class AppRestrictionAccessibilityService : AccessibilityService() {

    companion object {
        const val PREFS_NAME = "code_to_unlock_native_prefs"
        const val KEY_RESTRICTED_PACKAGES = "restricted_packages"
        const val KEY_ACTIVE_REWARDS = "active_rewards"

        var isServiceActive: Boolean = false
        var restrictedPackages: Set<String> = emptySet()
        var activeRewards: Map<String, Long> = emptyMap() // PackageName -> Expiration epoch millis

        fun saveRestrictions(context: Context, packages: Set<String>, rewards: Map<String, Long>) {
            restrictedPackages = packages
            activeRewards = rewards

            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val editor = prefs.edit()
            editor.putStringSet(KEY_RESTRICTED_PACKAGES, packages)

            // Store rewards as key-value pairs formatted as "pkg:epoch"
            val rewardsSet = rewards.map { "${it.key}:${it.value}" }.toSet()
            editor.putStringSet(KEY_ACTIVE_REWARDS, rewardsSet)
            editor.apply()
        }

        fun loadRestrictions(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            restrictedPackages = prefs.getStringSet(KEY_RESTRICTED_PACKAGES, emptySet()) ?: emptySet()

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
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isServiceActive = true
        loadRestrictions(applicationContext)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            return
        }

        val packageName = event.packageName?.toString() ?: return

        // Ignore our own application
        if (packageName == applicationContext.packageName) {
            return
        }

        // If in-memory set is empty, attempt reload from persistent preferences
        if (restrictedPackages.isEmpty()) {
            loadRestrictions(applicationContext)
        }

        // Check if package is in restricted set
        if (restrictedPackages.contains(packageName)) {
            val rewardExpiration = activeRewards[packageName]
            val now = System.currentTimeMillis()

            if (rewardExpiration == null || now > rewardExpiration) {
                // Restricted and unrewarded (or expired)! Redirect user to restriction interface
                val launchIntent = packageManager.getLaunchIntentForPackage(applicationContext.packageName)?.apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    putExtra("RESTRICTED_PACKAGE", packageName)
                }
                if (launchIntent != null) {
                    startActivity(launchIntent)
                }
            }
        }
    }

    override fun onInterrupt() {
        // Handle accessibility interruption
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceActive = false
    }
}
