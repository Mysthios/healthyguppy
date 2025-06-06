import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthyguppy/services/firebase_service.dart';
import 'package:healthyguppy/services/notification_service.dart';

class AlarmService {
  static const String _alarmTitlePrefix = 'alarm_title_';
  static const String _alarmBodyPrefix = 'alarm_body_';

  /// Inisialisasi alarm manager
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  /// Jadwalkan semua alarm aktif dari database
  static Future<void> scheduleActiveAlarms() async {
    try {
      final firebaseService = FirebaseService();
      final notificationService = NotificationService();
      final prefs = await SharedPreferences.getInstance();
      
      final activeNotifs = await firebaseService.getActiveSchedules();

      for (var notif in activeNotifs) {
        final id = _generateAlarmId(notif.waktu);

        // Simpan data alarm ke SharedPreferences
        await _saveAlarmData(prefs, id, notif.judul, notif.isi);

        // Schedule notification
        await notificationService.scheduleNotification(
          id: id,
          title: notif.judul,
          body: notif.isi,
          scheduledDate: notif.waktu,
        );

        // Schedule alarm
        await AndroidAlarmManager.oneShotAt(
          notif.waktu,
          id,
          alarmCallback,
          exact: true,
          wakeup: true,
        );
      }

      debugPrint('✅ Scheduled ${activeNotifs.length} alarms');
    } catch (e) {
      debugPrint('❌ Failed to schedule alarms: $e');
    }
  }

  /// Jadwalkan alarm tunggal
  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Simpan data alarm
      await _saveAlarmData(prefs, id, title, body);

      // Schedule notification
      await NotificationService().scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
      );

      // Schedule alarm
      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        id,
        alarmCallback,
        exact: true,
        wakeup: true,
      );

      debugPrint('✅ Alarm scheduled for $scheduledTime');
    } catch (e) {
      debugPrint('❌ Failed to schedule alarm: $e');
    }
  }

  /// Batalkan alarm
  static Future<void> cancelAlarm(int id) async {
    try {
      await AndroidAlarmManager.cancel(id);
      
      // Hapus data dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_alarmTitlePrefix$id');
      await prefs.remove('$_alarmBodyPrefix$id');

      debugPrint('✅ Alarm $id cancelled');
    } catch (e) {
      debugPrint('❌ Failed to cancel alarm: $e');
    }
  }

  /// Generate unique alarm ID dari timestamp
  static int _generateAlarmId(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// Simpan data alarm ke SharedPreferences
  static Future<void> _saveAlarmData(
    SharedPreferences prefs,
    int id,
    String title,
    String body,
  ) async {
    await prefs.setString('$_alarmTitlePrefix$id', title);
    await prefs.setString('$_alarmBodyPrefix$id', body);
  }

  /// Ambil data alarm dari SharedPreferences
  static Future<Map<String, String>> getAlarmData(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'title': prefs.getString('$_alarmTitlePrefix$id') ?? 'Alarm!',
      'body': prefs.getString('$_alarmBodyPrefix$id') ?? 'Waktunya memberi makan ikan!',
    };
  }
}

/// Fungsi callback alarm - harus di level top untuk bisa dipanggil
@pragma('vm:entry-point')
void alarmCallback() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString('alarm_title_0') ?? 'Alarm!';
    final body = prefs.getString('alarm_body_0') ?? 'Waktunya memberi makan ikan!';
    
    // Trigger notifikasi jika diperlukan
    // NotificationService().showInstantNotification(title: title, body: body);
    
    debugPrint('🔔 Alarm triggered: $title - $body');
  } catch (e) {
    debugPrint('❌ Error in alarm callback: $e');
  }
}