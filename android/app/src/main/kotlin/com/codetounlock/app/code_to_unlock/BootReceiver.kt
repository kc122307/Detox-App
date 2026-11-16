package com.codetounlock.app.code_to_unlock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED && context != null) {
            // Restore persistent restrictions immediately upon device boot
            AppRestrictionAccessibilityService.loadRestrictions(context)
        }
    }
}
