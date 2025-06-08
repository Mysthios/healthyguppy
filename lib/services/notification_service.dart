import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static int _notificationCounter = 1;

  static Future<void> init() async {
    // Clean up old notifications
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      print('Error canceling notifications: $e');
    }

    // Reset counter to 1
    _notificationCounter = 1;
    await _resetNotificationCounter();

    // Initialize timezone
    try {
      tz.initializeTimeZones();
      final String timeZoneName = 'Asia/Jakarta';
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print('Timezone initialized: $timeZoneName');
    } catch (e) {
      print('Error initializing timezone: $e');
    }

    // Initialize notification plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    final bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
      },
    );

    print('Notification plugin initialized: $initialized');

    // Create notification channels
    final androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      // Channel untuk foreground service
      const AndroidNotificationChannel foregroundChannel =
          AndroidNotificationChannel(
            'my_foreground',
            'Foreground Service Channel',
            description:
                'Channel untuk notifikasi background service HealthyGuppy',
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

      await androidImplementation.createNotificationChannel(foregroundChannel);
      await androidImplementation.createNotificationChannel(jadwalChannel);
      print('Notification channels created');
    }
  }

  static Future<void> _resetNotificationCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_counter', 1);
      _notificationCounter = 1;
    } catch (e) {
      print('Error resetting notification counter: $e');
    }
  }

  static int generateSafeId() {
    _notificationCounter++;
    if (_notificationCounter > 999999) {
      _notificationCounter = 1;
    }

    if (_notificationCounter % 100 == 0) {
      _saveNotificationCounter();
    }

    return _notificationCounter;
  }

  static int generateTimestampId() {
    final now = DateTime.now();
    final minutesInDay = (now.hour * 60) + now.minute;
    final seconds = now.second;
    int id = (minutesInDay * 100) + seconds;

    if (id == 0) id = 1;
    return id;
  }

  static int generateRandomId() {
    final random = Random();
    int id = random.nextInt(999999) + 1;
    return id;
  }

  static Future<void> _loadNotificationCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationCounter = prefs.getInt('notification_counter') ?? 1;
    } catch (e) {
      _notificationCounter = 1;
    }
  }

  static Future<void> _saveNotificationCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_counter', _notificationCounter);
    } catch (e) {
      print('Error saving notification counter: $e');
    }
  }

  static Future<void> showNotification({
    int? id,
    required String title,
    required String body,
  }) async {
    final safeId = id ?? generateRandomId();
    print('Showing notification with ID: $safeId');

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
          ticker: 'Notification',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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
      print('Notification shown successfully');
    } catch (e) {
      print('Error showing notification: $e');
      // Retry with different ID
      final retryId = generateRandomId();
      try {
        await _flutterLocalNotificationsPlugin.show(
          retryId,
          title,
          body,
          platformChannelSpecifics,
        );
        print('Notification retry successful with ID: $retryId');
      } catch (retryError) {
        print('Notification retry failed: $retryError');
        rethrow;
      }
    }
  }

  static Future<void> scheduleNotification({
    int? id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final safeId = id ?? generateRandomId();
    print('Scheduling notification with ID: $safeId for: $scheduledDate');

    // Validate time
    final now = DateTime.now();
    DateTime finalScheduledDate = scheduledDate;
    if (scheduledDate.isBefore(now)) {
      finalScheduledDate = now.add(const Duration(minutes: 1));
      print('Scheduled date was in the past, adjusted to: $finalScheduledDate');
    }

    try {
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        finalScheduledDate,
        tz.local,
      );

      print('Scheduled TZ DateTime: $scheduledTZ');

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
            ticker: 'Scheduled Notification',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print('Notification scheduled successfully');
    } catch (e) {
      print('Error scheduling notification: $e');
      // Retry with different ID
      final retryId = generateRandomId();
      try {
        final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
          finalScheduledDate,
          tz.local,
        );

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
              ticker: 'Scheduled Notification',
              largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        print('Notification retry scheduled successfully with ID: $retryId');
      } catch (retryError) {
        print('Notification schedule retry failed: $retryError');
        rethrow;
      }
    }
  }

  // 🔥 METHOD YANG HILANG - untuk cancel single notification by ID
  static Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      print('✅ Cancelled notification with ID: $id');
    } catch (e) {
      print('❌ Error cancelling notification ID $id: $e');
    }
  }

  static Future<void> forceCleanup() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      await _resetNotificationCounter();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notification_counter');
      print('Force cleanup completed');
    } catch (e) {
      print('Error during force cleanup: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('All notifications canceled');
    } catch (e) {
      print('Error canceling notifications: $e');
    }
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    try {
      final pending =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('Pending notifications count: ${pending.length}');
      return pending;
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  // Method untuk testing notifikasi
  static Future<void> testNotification() async {
    await showNotification(
      title: 'Test Notification',
      body: 'Ini adalah test notifikasi. Jika muncul, berarti notifikasi berfungsi!',
    );
  }

  // Method untuk testing scheduled notification
  static Future<void> testScheduledNotification() async {
    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    await scheduleNotification(
      title: 'Test Scheduled Notification',
      body: 'Ini adalah test scheduled notifikasi setelah 10 detik!',
      scheduledDate: scheduledTime,
    );
  }
}