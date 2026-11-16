package com.codetounlock.app.code_to_unlock

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class AppRestrictionAccessibilityService : AccessibilityService() {

    companion object {
        var isServiceActive: Boolean = false
        var restrictedPackages: Set<String> = emptySet()
        var activeRewards: Map<String, Long> = emptyMap() // PackageName -> Expiration epoch millis
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isServiceActive = true
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

        // Check if package is in restricted set
        if (restrictedPackages.contains(packageName)) {
            val rewardExpiration = activeRewards[packageName]
            val now = System.currentTimeMillis()

            if (rewardExpiration == null || now > rewardExpiration) {
                // Restricted and unrewarded (or expired)! Redirect user to challenge screen
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
        // Handle interruption
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceActive = false
    }
}
