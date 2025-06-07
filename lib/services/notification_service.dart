import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Counter untuk ID unik yang aman - RESET ke 1
  static int _notificationCounter = 1;

  static Future<void> init() async {
    print('🚀 Starting NotificationService initialization...');
    
    // LANGKAH 1: Bersihkan SEMUA notifikasi lama terlebih dahulu
    try {
      print('🧹 Cleaning up old notifications...');
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('✅ All old notifications cancelled');
    } catch (e) {
      print('⚠️ Error cancelling old notifications: $e');
    }

    // LANGKAH 2: Reset counter ke 1
    _notificationCounter = 1;
    await _resetNotificationCounter();
    print('🔄 Notification counter reset to 1');

    // LANGKAH 3: Initialize timezone
    try {
      tz.initializeTimeZones();
      final String timeZoneName = 'Asia/Jakarta';
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print('🌏 Timezone set to $timeZoneName');
    } catch (e) {
      print('⚠️ Error setting timezone: $e');
    }

    // LANGKAH 4: Initialize notification plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    try {
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
      print('📱 Notification plugin initialized');
    } catch (e) {
      print('❌ Error initializing notification plugin: $e');
      rethrow;
    }

    // LANGKAH 5: Create notification channels
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      try {
        // Channel untuk foreground service
        const AndroidNotificationChannel foregroundChannel =
            AndroidNotificationChannel(
              'my_foreground',
              'Foreground Service Channel',
              description: 'Channel untuk notifikasi background service HealthyGuppy',
              importance: Importance.low,
            );

        // Channel untuk jadwal notifikasi
        const AndroidNotificationChannel jadwalChannel =
            AndroidNotificationChannel(
              'jadwal_channel',
              'Jadwal Notifikasi',
              description: 'Channel untuk notifikasi jadwal',
              importance: Importance.max,
            );

        // Buat kedua channel
        await androidImplementation.createNotificationChannel(foregroundChannel);
        await androidImplementation.createNotificationChannel(jadwalChannel);
        
        print('📺 Notification channels created successfully');
      } catch (e) {
        print('❌ Error creating notification channels: $e');
        rethrow;
      }
    }

    print('✅ NotificationService initialized successfully');
  }

  // RESET counter ke 1 (untuk debugging)
  static Future<void> _resetNotificationCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_counter', 1);
      _notificationCounter = 1;
      print('🔄 Counter reset to 1');
    } catch (e) {
      print('⚠️ Error resetting counter: $e');
    }
  }

  // ID Generator SUPER AMAN - hanya counter sederhana
  static int generateSafeId() {
    _notificationCounter++;
    if (_notificationCounter > 999999) { // Maksimal 999,999 (sangat aman)
      _notificationCounter = 1;
    }
    
    // TIDAK menyimpan ke SharedPreferences setiap kali untuk menghindari overhead
    // Hanya simpan setiap 100 increment
    if (_notificationCounter % 100 == 0) {
      _saveNotificationCounter();
    }
    
    print('🆔 Generated safe ID: $_notificationCounter');
    return _notificationCounter;
  }

  // ID Generator dengan timestamp sederhana (ALTERNATIF)
  static int generateTimestampId() {
    final now = DateTime.now();
    // Gunakan menit dalam hari + detik, tapi tetap kecil
    final minutesInDay = (now.hour * 60) + now.minute; // Max 1440
    final seconds = now.second; // Max 59
    
    // Gabung dengan cara aman: menit*100 + detik
    // Maksimal: 1440*100 + 59 = 144,059 (sangat aman)
    int id = (minutesInDay * 100) + seconds;
    
    // Jika 0, set ke 1
    if (id == 0) id = 1;
    
    print('⏰ Generated timestamp ID: $id');
    return id;
  }

  // ID Generator dengan random sederhana
  static int generateRandomId() {
    final random = Random();
    int id = random.nextInt(999999) + 1; // 1 sampai 999,999
    print('🎲 Generated random ID: $id');
    return id;
  }

  static Future<void> _loadNotificationCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationCounter = prefs.getInt('notification_counter') ?? 1;
      print('📖 Loaded counter: $_notificationCounter');
    } catch (e) {
      print('⚠️ Error loading counter: $e');
      _notificationCounter = 1;
    }
  }

  static Future<void> _saveNotificationCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_counter', _notificationCounter);
    } catch (e) {
      print('⚠️ Error saving counter: $e');
    }
  }

  static Future<void> showNotification({
    int? id,
    required String title,
    required String body,
  }) async {
    // Gunakan generateRandomId() untuk menghindari konflik
    final safeId = id ?? generateRandomId();
    print('📢 Showing notification with ID: $safeId');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'jadwal_channel',
          'Jadwal Notifikasi',
          channelDescription: 'Channel untuk notifikasi jadwal',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        safeId,
        title,
        body,
        platformChannelSpecifics,
      );
      print('✅ Notification shown successfully with ID: $safeId');
    } catch (e) {
      print('❌ Error showing notification: $e');
      // Coba lagi dengan ID yang berbeda
      final retryId = generateRandomId();
      print('🔄 Retrying with ID: $retryId');
      try {
        await _flutterLocalNotificationsPlugin.show(
          retryId,
          title,
          body,
          platformChannelSpecifics,
        );
        print('✅ Retry successful with ID: $retryId');
      } catch (retryError) {
        print('❌ Retry failed: $retryError');
        rethrow;
      }
    }
  }

  Future<void> scheduleNotification({
    int? id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Gunakan generateRandomId() untuk menghindari konflik
    final safeId = id ?? generateRandomId();
    
    print('⏰ Scheduling notification with ID: $safeId for: $scheduledDate');
    
    // Validasi waktu
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      print('⚠️ Scheduled time is in the past! Adjusting to 1 minute from now.');
      scheduledDate = now.add(const Duration(minutes: 1));
    }

    try {
      // Pastikan timezone conversion benar
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      
      print('📅 Scheduled TZ DateTime: $scheduledTZ');
      print('🕐 Current TZ DateTime: ${tz.TZDateTime.now(tz.local)}');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        safeId,
        title,
        body,
        scheduledTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'jadwal_channel',
            'Jadwal Notifikasi',
            channelDescription: 'Channel untuk notifikasi jadwal',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Notification scheduled successfully with ID: $safeId');
      
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      
      // Coba lagi dengan ID yang berbeda
      final retryId = generateRandomId();
      print('🔄 Retrying schedule with ID: $retryId');
      
      try {
        final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
        
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          retryId,
          title,
          body,
          scheduledTZ,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'jadwal_channel',
              'Jadwal Notifikasi',
              channelDescription: 'Channel untuk notifikasi jadwal',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
              enableVibration: true,
              playSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        
        print('✅ Retry schedule successful with ID: $retryId');
      } catch (retryError) {
        print('❌ Retry schedule failed: $retryError');
        rethrow;
      }
    }
  }

  // Method untuk FORCE CLEANUP semua notifikasi
  static Future<void> forceCleanup() async {
    print('🧹 FORCE CLEANUP: Cancelling all notifications...');
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('✅ All notifications cancelled');
      
      // Reset counter
      await _resetNotificationCounter();
      print('🔄 Counter reset');
      
      // Clear SharedPreferences yang berkaitan dengan notifikasi
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notification_counter');
      print('🗑️ SharedPreferences cleared');
      
    } catch (e) {
      print('❌ Error during force cleanup: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('🗑️ Cancelled all notifications');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pending = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('📋 Found ${pending.length} pending notifications');
      return pending;
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  // Method untuk testing dengan ID aman
  static Future<void> testNotification() async {
    print('🧪 Testing immediate notification...');
    await showNotification(
      title: 'Test Notification',
      body: 'This is a test notification with safe ID generation.',
    );
  }

  static Future<void> testScheduledNotification() async {
    print('🧪 Testing scheduled notification in 10 seconds...');
    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    final service = NotificationService();
    await service.scheduleNotification(
      title: 'Test Scheduled',
      body: 'This scheduled notification should appear in 10 seconds',
      scheduledDate: scheduledTime,
    );
  }

  // Method untuk debugging lengkap
  static Future<void> debugNotificationInfo() async {
    print('📊 === NOTIFICATION DEBUG INFO ===');
    print('🔢 Current counter: $_notificationCounter');
    
    final pending = await getPendingNotifications();
    print('⏳ Pending notifications: ${pending.length}');
    
    for (var notif in pending) {
      print('   - ID: ${notif.id}, Title: ${notif.title}');
    }
    
    // Test ID generators
    print('🆔 Test ID generators:');
    print('   - Safe ID: ${generateSafeId()}');
    print('   - Timestamp ID: ${generateTimestampId()}');
    print('   - Random ID: ${generateRandomId()}');
    
    print('================================');
  }
}