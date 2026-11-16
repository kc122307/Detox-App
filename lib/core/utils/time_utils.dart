import 'package:intl/intl.dart';

class TimeUtils {
  static String formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else if (minutes > 0) {
      return seconds > 0 && minutes < 5 ? '${minutes}m ${seconds}s' : '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  static String formatTimeRemaining(int seconds) {
    if (seconds <= 0) return 'Exhausted';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSecs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m left';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSecs}s left';
    } else {
      return '${remainingSecs}s left';
    }
  }

  static String getTodayDateKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static DateTime getNextResetTime({int resetHour = 0, int resetMinute = 0}) {
    final now = DateTime.now();
    var resetTime = DateTime(now.year, now.month, now.day, resetHour, resetMinute);
    if (now.isAfter(resetTime)) {
      resetTime = resetTime.add(const Duration(days: 1));
    }
    return resetTime;
  }

  static String formatTimestamp(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d').format(dateTime);
  }
}

