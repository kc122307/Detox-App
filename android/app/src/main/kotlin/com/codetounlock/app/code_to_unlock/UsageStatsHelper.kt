package com.codetounlock.app.code_to_unlock

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Process
import java.util.Calendar

class UsageStatsHelper(private val context: Context) {

    fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager ?: return false
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getStartOfDayMillis(): Long {
        return Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis
    }

    fun getUsageSecondsToday(packageName: String): Long {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return 0L

        val startTime = getStartOfDayMillis()
        val endTime = System.currentTimeMillis()

        val aggregated = usageStatsManager.queryAndAggregateUsageStats(startTime, endTime)
        val usage = aggregated[packageName] ?: return 0L
        return usage.totalTimeInForeground / 1000L
    }

    fun getAllUsageSecondsToday(): Map<String, Long> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return emptyMap()

        val startTime = getStartOfDayMillis()
        val endTime = System.currentTimeMillis()

        val aggregated = usageStatsManager.queryAndAggregateUsageStats(startTime, endTime)
        val result = HashMap<String, Long>()
        for ((pkg, stats) in aggregated) {
            val seconds = stats.totalTimeInForeground / 1000L
            if (seconds > 0) {
                result[pkg] = seconds
            }
        }
        return result
    }
}
