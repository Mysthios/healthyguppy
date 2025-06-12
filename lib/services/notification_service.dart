// import 'dart:ui';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math';
// import '../models/suhu_model.dart';

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
//       FlutterLocalNotificationsPlugin();

//   static int _notificationCounter = 1;

//   // Firestore instance
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Initialize notification service
//   static Future<void> init() async {
//     // Clean up old notifications
//     try {
//       await _flutterLocalNotificationsPlugin.cancelAll();
//     } catch (e) {
//       print('Error canceling notifications: $e');
//     }

//     // Reset counter to 1
//     _notificationCounter = 1;
//     await _resetNotificationCounter();

//     // Initialize timezone
//     try {
//       tz.initializeTimeZones();
//       final String timeZoneName = 'Asia/Jakarta';
//       tz.setLocalLocation(tz.getLocation(timeZoneName));
//       print('Timezone initialized: $timeZoneName');
//     } catch (e) {
//       print('Error initializing timezone: $e');
//     }

//     // Initialize notification plugin
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
    
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     final bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         print('Notification tapped: ${response.payload}');
//       },
//     );

//     print('Notification plugin initialized: $initialized');

//     // Create notification channels
//     final androidImplementation =
//         _flutterLocalNotificationsPlugin
//             .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin
//             >();

//     if (androidImplementation != null) {
//       // Channel untuk foreground service
//       const AndroidNotificationChannel foregroundChannel =
//           AndroidNotificationChannel(
//             'my_foreground',
//             'Foreground Service Channel',
//             description: 'Channel untuk notifikasi background service HealthyGuppy',
//             importance: Importance.low,
//           );

//       // Channel untuk jadwal notifikasi
//       const AndroidNotificationChannel jadwalChannel =
//           AndroidNotificationChannel(
//             'jadwal_channel',
//             'Jadwal Notifikasi',
//             description: 'Channel untuk notifikasi jadwal',
//             importance: Importance.max,
//           );

//       // Channel untuk suhu alerts
//       const AndroidNotificationChannel suhuChannel =
//           AndroidNotificationChannel(
//             'suhu_channel',
//             'Suhu Alerts',
//             description: 'Channel untuk notifikasi suhu alerts',
//             importance: Importance.max,
//           );

//       await androidImplementation.createNotificationChannel(foregroundChannel);
//       await androidImplementation.createNotificationChannel(jadwalChannel);
//       await androidImplementation.createNotificationChannel(suhuChannel);
//       print('Notification channels created');
//     }
//   }

//   // Instance method for backward compatibility
//   Future<void> initialize() async {
//     await init();
//   }

//   static Future<void> _resetNotificationCounter() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('notification_counter', 1);
//       _notificationCounter = 1;
//     } catch (e) {
//       print('Error resetting notification counter: $e');
//     }
//   }

//   static int generateSafeId() {
//     _notificationCounter++;
//     if (_notificationCounter > 999999) {
//       _notificationCounter = 1;
//     }

//     if (_notificationCounter % 100 == 0) {
//       _saveNotificationCounter();
//     }

//     return _notificationCounter;
//   }

//   static int generateTimestampId() {
//     final now = DateTime.now();
//     final minutesInDay = (now.hour * 60) + now.minute;
//     final seconds = now.second;
//     int id = (minutesInDay * 100) + seconds;

//     if (id == 0) id = 1;
//     return id;
//   }

//   static int generateRandomId() {
//     final random = Random();
//     int id = random.nextInt(999999) + 1;
//     return id;
//   }

//   static Future<void> _saveNotificationCounter() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('notification_counter', _notificationCounter);
//     } catch (e) {
//       print('Error saving notification counter: $e');
//     }
//   }

//   // Save notification to Firestore
//   static Future<void> _saveNotificationToFirestore({
//     required String title,
//     required String body,
//     required String type,
//     Map<String, dynamic>? extraData,
//   }) async {
//     try {
//       final notificationData = {
//         'judul': title,
//         'isi': body,
//         'type': type, // 'suhu_alert', 'jadwal', 'general'
//         'waktu': FieldValue.serverTimestamp(),
//         'isRead': false,
//         'createdAt': DateTime.now().toIso8601String(),
//         ...?extraData,
//       };

//       await _firestore.collection('notifications').add(notificationData);
//       print('✅ Notification saved to Firestore: $title');
//     } catch (e) {
//       print('❌ Error saving notification to Firestore: $e');
//     }
//   }

//   // Enhanced suhu alert notification with database integration
//   Future<void> showSuhuAlert(SuhuData suhuData) async {
//     if (!suhuData.isOutOfRange()) return;

//     final safeId = generateRandomId();
//     final title = suhuData.getNotificationTitle();
//     final body = suhuData.getNotificationBody();
    
//     print('Showing suhu alert with ID: $safeId');

//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'suhu_channel',
//       'Suhu Alerts',
//       channelDescription: 'Channel untuk notifikasi suhu alerts',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: true,
//       enableVibration: true,
//       playSound: true,
//       ticker: 'Suhu Alert',
//       largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//       color: Color(0xFF2196F3), // Blue color for temperature alerts
//     );
    
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
    
//     try {
//       // Show local notification
//       await _flutterLocalNotificationsPlugin.show(
//         safeId,
//         title,
//         body,
//         platformChannelSpecifics,
//       );
      
//       // Save to Firestore
//       await _saveNotificationToFirestore(
//         title: title,
//         body: body,
//         type: 'suhu_alert',
//         extraData: {
//           'suhu': suhuData.suhu,
//           'status': suhuData.status,
//           'notificationId': safeId,
//           'isOutOfRange': true,
//           'suhuRange': suhuData.suhu < 24 ? 'too_cold' : 'too_hot',
//         },
//       );
      
//       print('✅ Suhu alert shown and saved successfully');
//     } catch (e) {
//       print('❌ Error showing suhu alert: $e');
//     }
//   }

//   // Enhanced general notification methods with database integration
//   static Future<void> showNotification({
//     int? id,
//     required String title,
//     required String body,
//     String type = 'general',
//     Map<String, dynamic>? extraData,
//   }) async {
//     final safeId = id ?? generateRandomId();
//     print('Showing notification with ID: $safeId');

//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//           'jadwal_channel',
//           'Jadwal Notifikasi',
//           channelDescription: 'Channel untuk notifikasi jadwal',
//           importance: Importance.max,
//           priority: Priority.high,
//           showWhen: true,
//           enableVibration: true,
//           playSound: true,
//           ticker: 'Notification',
//           largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//         );
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );

//     try {
//       // Show local notification
//       await _flutterLocalNotificationsPlugin.show(
//         safeId,
//         title,
//         body,
//         platformChannelSpecifics,
//       );
      
//       // Save to Firestore
//       await _saveNotificationToFirestore(
//         title: title,
//         body: body,
//         type: type,
//         extraData: {
//           'notificationId': safeId,
//           ...?extraData,
//         },
//       );
      
//       print('✅ Notification shown and saved successfully');
//     } catch (e) {
//       print('❌ Error showing notification: $e');
//       // Retry with different ID
//       final retryId = generateRandomId();
//       try {
//         await _flutterLocalNotificationsPlugin.show(
//           retryId,
//           title,
//           body,
//           platformChannelSpecifics,
//         );
        
//         // Save retry to Firestore
//         await _saveNotificationToFirestore(
//           title: title,
//           body: body,
//           type: type,
//           extraData: {
//             'notificationId': retryId,
//             'isRetry': true,
//             'originalId': safeId,
//             ...?extraData,
//           },
//         );
        
//         print('✅ Notification retry successful with ID: $retryId');
//       } catch (retryError) {
//         print('❌ Notification retry failed: $retryError');
//         rethrow;
//       }
//     }
//   }

//   static Future<void> scheduleNotification({
//     int? id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//     String type = 'jadwal',
//     Map<String, dynamic>? extraData,
//   }) async {
//     final safeId = id ?? generateRandomId();
//     print('Scheduling notification with ID: $safeId for: $scheduledDate');

//     // Validate time
//     final now = DateTime.now();
//     DateTime finalScheduledDate = scheduledDate;
//     if (scheduledDate.isBefore(now)) {
//       finalScheduledDate = now.add(const Duration(minutes: 1));
//       print('Scheduled date was in the past, adjusted to: $finalScheduledDate');
//     }

//     try {
//       final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
//         finalScheduledDate,
//         tz.local,
//       );

//       print('Scheduled TZ DateTime: $scheduledTZ');

//       await _flutterLocalNotificationsPlugin.zonedSchedule(
//         safeId,
//         title,
//         body,
//         scheduledTZ,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'jadwal_channel',
//             'Jadwal Notifikasi',
//             channelDescription: 'Channel untuk notifikasi jadwal',
//             importance: Importance.max,
//             priority: Priority.high,
//             showWhen: true,
//             enableVibration: true,
//             playSound: true,
//             ticker: 'Scheduled Notification',
//             largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//           ),
//         ),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         payload: 'scheduled_notification',
//       );
      
//       // Save scheduled notification to Firestore
//       await _saveNotificationToFirestore(
//         title: title,
//         body: body,
//         type: type,
//         extraData: {
//           'notificationId': safeId,
//           'scheduledFor': finalScheduledDate.toIso8601String(),
//           'isScheduled': true,
//           'status': 'scheduled',
//           ...?extraData,
//         },
//       );
      
//       print('✅ Notification scheduled and saved successfully');
//     } catch (e) {
//       print('❌ Error scheduling notification: $e');
//       // Retry with different ID
//       final retryId = generateRandomId();
//       try {
//         final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
//           finalScheduledDate,
//           tz.local,
//         );

//         await _flutterLocalNotificationsPlugin.zonedSchedule(
//           retryId,
//           title,
//           body,
//           scheduledTZ,
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'jadwal_channel',
//               'Jadwal Notifikasi',
//               channelDescription: 'Channel untuk notifikasi jadwal',
//               importance: Importance.max,
//               priority: Priority.high,
//               showWhen: true,
//               enableVibration: true,
//               playSound: true,
//               ticker: 'Scheduled Notification',
//               largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//             ),
//           ),
//           androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//           payload: 'scheduled_notification_retry',
//         );
        
//         // Save retry to Firestore
//         await _saveNotificationToFirestore(
//           title: title,
//           body: body,
//           type: type,
//           extraData: {
//             'notificationId': retryId,
//             'scheduledFor': finalScheduledDate.toIso8601String(),
//             'isScheduled': true,
//             'isRetry': true,
//             'originalId': safeId,
//             'status': 'scheduled',
//             ...?extraData,
//           },
//         );
        
//         print('✅ Notification retry scheduled successfully with ID: $retryId');
//       } catch (retryError) {
//         print('❌ Notification schedule retry failed: $retryError');
//         rethrow;
//       }
//     }
//   }

//   // Cancel single notification by ID
//   static Future<void> cancelNotification(int id) async {
//     try {
//       await _flutterLocalNotificationsPlugin.cancel(id);
//       print('✅ Cancelled notification with ID: $id');
      
//       // Update status in Firestore
//       try {
//         final querySnapshot = await _firestore
//             .collection('notifications')
//             .where('notificationId', isEqualTo: id)
//             .get();
        
//         for (var doc in querySnapshot.docs) {
//           await doc.reference.update({
//             'status': 'cancelled',
//             'cancelledAt': FieldValue.serverTimestamp(),
//           });
//         }
//         print('✅ Updated notification status in Firestore');
//       } catch (e) {
//         print('❌ Error updating notification status in Firestore: $e');
//       }
//     } catch (e) {
//       print('❌ Error cancelling notification ID $id: $e');
//     }
//   }

//   static Future<void> forceCleanup() async {
//     try {
//       await _flutterLocalNotificationsPlugin.cancelAll();
//       await _resetNotificationCounter();
      
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('notification_counter');
//       print('✅ Force cleanup completed');
//     } catch (e) {
//       print('❌ Error during force cleanup: $e');
//     }
//   }

//   Future<void> cancelAllNotifications() async {
//     try {
//       await _flutterLocalNotificationsPlugin.cancelAll();
//       print('✅ All notifications canceled');
//     } catch (e) {
//       print('❌ Error canceling notifications: $e');
//     }
//   }

//   static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     try {
//       final pending = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
//       print('📋 Pending notifications count: ${pending.length}');
//       return pending;
//     } catch (e) {
//       print('❌ Error getting pending notifications: $e');
//       return [];
//     }
//   }

//   // Get notifications from Firestore
//   static Stream<List<Map<String, dynamic>>> getNotificationsStream() {
//     return _firestore
//         .collection('notifications')
//         .orderBy('waktu', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return data;
//       }).toList();
//     });
//   }

//   // Clear all notifications from Firestore
//   static Future<void> clearAllNotificationsFromFirestore() async {
//     try {
//       final querySnapshot = await _firestore.collection('notifications').get();
//       final batch = _firestore.batch();
      
//       for (var doc in querySnapshot.docs) {
//         batch.delete(doc.reference);
//       }
      
//       await batch.commit();
//       print('✅ All notifications cleared from Firestore');
//     } catch (e) {
//       print('❌ Error clearing notifications from Firestore: $e');
//     }
//   }

//   // Mark notification as read
//   static Future<void> markNotificationAsRead(String notificationId) async {
//     try {
//       await _firestore
//           .collection('notifications')
//           .doc(notificationId)
//           .update({
//         'isRead': true,
//         'readAt': FieldValue.serverTimestamp(),
//       });
//       print('✅ Notification marked as read: $notificationId');
//     } catch (e) {
//       print('❌ Error marking notification as read: $e');
//     }
//   }

//   // Get unread notifications count
//   static Stream<int> getUnreadNotificationsCount() {
//     return _firestore
//         .collection('notifications')
//         .where('isRead', isEqualTo: false)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.length);
//   }
// }

import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/suhu_model.dart';
import '../models/hama_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  static int _notificationCounter = 1;

  // Firestore instance
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize notification service
  static Future<void> init() async {
    // Clean up old notifications
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      // Error handled silently
    }

    // Reset counter to 1
    _notificationCounter = 1;
    await _resetNotificationCounter();

    // Initialize timezone
    try {
      tz.initializeTimeZones();
      final String timeZoneName = 'Asia/Jakarta';
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Error handled silently
    }

    // Initialize notification plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

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

      // Channel untuk suhu alerts
      const AndroidNotificationChannel suhuChannel =
          AndroidNotificationChannel(
            'suhu_channel',
            'Suhu Alerts',
            description: 'Channel untuk notifikasi suhu alerts',
            importance: Importance.max,
          );

      // Channel untuk hama alerts
      const AndroidNotificationChannel hamaChannel =
          AndroidNotificationChannel(
            'hama_channel',
            'Hama Alerts',
            description: 'Channel untuk notifikasi deteksi hama',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          );

      await androidImplementation.createNotificationChannel(foregroundChannel);
      await androidImplementation.createNotificationChannel(jadwalChannel);
      await androidImplementation.createNotificationChannel(suhuChannel);
      await androidImplementation.createNotificationChannel(hamaChannel);
    }
  }

  // Instance method for backward compatibility
  Future<void> initialize() async {
    await init();
  }

  static Future<void> _resetNotificationCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_counter', 1);
      _notificationCounter = 1;
    } catch (e) {
      // Error handled silently
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

  static Future<void> _saveNotificationCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_counter', _notificationCounter);
    } catch (e) {
      // Error handled silently
    }
  }

  // Save notification to Firestore
  static Future<void> _saveNotificationToFirestore({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final notificationData = {
        'judul': title,
        'isi': body,
        'type': type, // 'suhu_alert', 'jadwal', 'general', 'hama_alert'
        'waktu': FieldValue.serverTimestamp(),
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
        ...?extraData,
      };

      await _firestore.collection('notifications').add(notificationData);
    } catch (e) {
      // Error handled silently
    }
  }

  // Enhanced suhu alert notification with database integration
  Future<void> showSuhuAlert(SuhuData suhuData) async {
    if (!suhuData.isOutOfRange()) return;

    final safeId = generateRandomId();
    final title = suhuData.getNotificationTitle();
    final body = suhuData.getNotificationBody();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'suhu_channel',
      'Suhu Alerts',
      channelDescription: 'Channel untuk notifikasi suhu alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      ticker: 'Suhu Alert',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Color(0xFF2196F3), // Blue color for temperature alerts
    );
    
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    try {
      // Show local notification
      await _flutterLocalNotificationsPlugin.show(
        safeId,
        title,
        body,
        platformChannelSpecifics,
      );
      
      // Save to Firestore
      await _saveNotificationToFirestore(
        title: title,
        body: body,
        type: 'suhu_alert',
        extraData: {
          'suhu': suhuData.suhu,
          'status': suhuData.status,
          'notificationId': safeId,
          'isOutOfRange': true,
          'suhuRange': suhuData.suhu < 24 ? 'too_cold' : 'too_hot',
        },
      );
    } catch (e) {
      // Error handled silently
    }
  }

  // Enhanced general notification methods with database integration
  static Future<void> showNotification({
    int? id,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? extraData,
  }) async {
    final safeId = id ?? generateRandomId();

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
      // Show local notification
      await _flutterLocalNotificationsPlugin.show(
        safeId,
        title,
        body,
        platformChannelSpecifics,
      );
      
      // Save to Firestore
      await _saveNotificationToFirestore(
        title: title,
        body: body,
        type: type,
        extraData: {
          'notificationId': safeId,
          ...?extraData,
        },
      );
    } catch (e) {
      // Retry with different ID
      final retryId = generateRandomId();
      try {
        await _flutterLocalNotificationsPlugin.show(
          retryId,
          title,
          body,
          platformChannelSpecifics,
        );
        
        // Save retry to Firestore
        await _saveNotificationToFirestore(
          title: title,
          body: body,
          type: type,
          extraData: {
            'notificationId': retryId,
            'isRetry': true,
            'originalId': safeId,
            ...?extraData,
          },
        );
      } catch (retryError) {
        // Error handled silently
      }
    }
  }

  static Future<void> scheduleNotification({
    int? id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String type = 'jadwal',
    Map<String, dynamic>? extraData,
  }) async {
    final safeId = id ?? generateRandomId();

    // Validate time
    final now = DateTime.now();
    DateTime finalScheduledDate = scheduledDate;
    if (scheduledDate.isBefore(now)) {
      finalScheduledDate = now.add(const Duration(minutes: 1));
    }

    try {
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        finalScheduledDate,
        tz.local,
      );

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
        payload: 'scheduled_notification',
      );
      
      // Save scheduled notification to Firestore
      await _saveNotificationToFirestore(
        title: title,
        body: body,
        type: type,
        extraData: {
          'notificationId': safeId,
          'scheduledFor': finalScheduledDate.toIso8601String(),
          'isScheduled': true,
          'status': 'scheduled',
          ...?extraData,
        },
      );
    } catch (e) {
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
          payload: 'scheduled_notification_retry',
        );
        
        // Save retry to Firestore
        await _saveNotificationToFirestore(
          title: title,
          body: body,
          type: type,
          extraData: {
            'notificationId': retryId,
            'scheduledFor': finalScheduledDate.toIso8601String(),
            'isScheduled': true,
            'isRetry': true,
            'originalId': safeId,
            'status': 'scheduled',
            ...?extraData,
          },
        );
      } catch (retryError) {
        // Error handled silently
      }
    }
  }

  // Cancel single notification by ID
  static Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      
      // Update status in Firestore
      try {
        final querySnapshot = await _firestore
            .collection('notifications')
            .where('notificationId', isEqualTo: id)
            .get();
        
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({
            'status': 'cancelled',
            'cancelledAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        // Error handled silently
      }
    } catch (e) {
      // Error handled silently
    }
  }

  static Future<void> forceCleanup() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      await _resetNotificationCounter();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notification_counter');
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      // Error handled silently
    }
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pending = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      return pending;
    } catch (e) {
      return [];
    }
  }

  // Get notifications from Firestore
  static Stream<List<Map<String, dynamic>>> getNotificationsFromFirestore() {
    return _firestore
        .collection('notifications')
        .orderBy('waktu', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();
        });
  }

  // Enhanced hama alert dengan better error handling
  static Future<void> showHamaAlert(HamaData hamaData) async {
    if (!hamaData.shouldNotify()) {
      return;
    }

    final safeId = generateRandomId();
    final title = hamaData.getNotificationTitle();
    final body = hamaData.getNotificationBody();

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hama_channel',
      'Hama Alerts',
      channelDescription: 'Channel untuk notifikasi deteksi hama',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      ticker: 'Hama Alert',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: const Color(0xFFFF5722), // Orange-red color for hama alerts
      autoCancel: true,
      ongoing: false,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'HealthyGuppy Alert',
      ),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'view_details',
          'Lihat Detail',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'dismiss',
          'Tutup',
          cancelNotification: true,
        ),
      ],
    );
    
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    try {
      // Show local notification
      await _flutterLocalNotificationsPlugin.show(
        safeId,
        title,
        body,
        platformChannelSpecifics,
        payload: 'hama_alert:${hamaData.status}',
      );
      
      // Save to Firestore with enhanced data
      await _saveNotificationToFirestore(
        title: title,
        body: body,
        type: 'hama_alert',
        extraData: {
          'hamaStatus': hamaData.status,
          'hamaName': hamaData.nama,
          'severity': hamaData.getSeverityLevel(),
          'priority': hamaData.getPriority(),
          'color': hamaData.getStatusColor(),
          'icon': hamaData.getStatusIcon(),
          'timestamp': hamaData.timestamp.toIso8601String(),
          'notificationId': safeId,
          'isHamaDetected': hamaData.isHamaDetected,
          'requiresAction': true,
          'category': 'health_alert',
        },
      );
    } catch (e) {
      // Retry mechanism with exponential backoff
      await _retryHamaAlert(hamaData, safeId, title, body, platformChannelSpecifics);
    }
  }

  // Retry mechanism untuk hama alert
  static Future<void> _retryHamaAlert(
    HamaData hamaData,
    int originalId,
    String title,
    String body,
    NotificationDetails platformChannelSpecifics,
  ) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await Future.delayed(Duration(milliseconds: 500 * attempt)); // Exponential backoff
        
        final retryId = generateRandomId();
        
        await _flutterLocalNotificationsPlugin.show(
          retryId,
          title,
          body,
          platformChannelSpecifics,
          payload: 'hama_alert_retry:${hamaData.status}',
        );
        
        // Save retry to Firestore
        await _saveNotificationToFirestore(
          title: title,
          body: body,
          type: 'hama_alert',
          extraData: {
            'hamaStatus': hamaData.status,
            'hamaName': hamaData.nama,
            'severity': hamaData.getSeverityLevel(),
            'priority': hamaData.getPriority(),
            'color': hamaData.getStatusColor(),
            'icon': hamaData.getStatusIcon(),
            'timestamp': hamaData.timestamp.toIso8601String(),
            'notificationId': retryId,
            'isHamaDetected': hamaData.isHamaDetected,
            'isRetry': true,
            'originalId': originalId,
            'retryAttempt': attempt,
            'requiresAction': true,
            'category': 'health_alert',
          },
        );
        
        return; // Success, exit retry loop
        
      } catch (retryError) {
        if (attempt == 3) {
          // Final attempt failed, log error and save failed notification
          await _saveFailedNotification(hamaData, originalId, retryError);
          return;
        }
      }
    }
  }

  // Save failed notification untuk debugging
  static Future<void> _saveFailedNotification(
    HamaData hamaData,
    int notificationId,
    dynamic error,
  ) async {
    try {
      await _firestore.collection('failed_notifications').add({
        'type': 'hama_alert',
        'hamaStatus': hamaData.status,
        'notificationId': notificationId,
        'error': error.toString(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Error handled silently
    }
  }

  // Method untuk check dan show hama alert secara manual
  static Future<void> checkAndShowHamaAlert(HamaData hamaData) async {
    if (hamaData.shouldNotify()) {
      await showHamaAlert(hamaData);
    }
  }

  // Batch notification untuk multiple hama alerts
  static Future<void> showBatchHamaAlerts(List<HamaData> hamaDataList) async {
    if (hamaDataList.isEmpty) return;
    
    for (final hamaData in hamaDataList) {
      if (hamaData.shouldNotify()) {
        try {
          await showHamaAlert(hamaData);
          // Small delay between notifications to avoid overwhelming
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          continue; // Continue with next notification
        }
      }
    }
  }

  // Cancel hama notifications specifically
  static Future<void> cancelHamaNotifications() async {
    try {
      // Get all pending notifications
      final pendingNotifications = await getPendingNotifications();
      
      for (final notification in pendingNotifications) {
        if (notification.payload?.contains('hama_alert') == true) {
          await cancelNotification(notification.id);
        }
      }
    } catch (e) {
      // Error handled silently
    }
  }

  // Get hama notification statistics
  static Future<Map<String, dynamic>> getHamaNotificationStats() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeek = now.subtract(Duration(days: now.weekday - 1));
      
      // Get hama notifications from Firestore
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('type', isEqualTo: 'hama_alert')
          .get();
      
      int totalCount = querySnapshot.docs.length;
      int todayCount = 0;
      int weekCount = 0;
      int detectedCount = 0;
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final timestamp = (data['waktu'] as Timestamp?)?.toDate() ?? DateTime.now();
        
        if (timestamp.isAfter(today)) {
          todayCount++;
        }
        
        if (timestamp.isAfter(thisWeek)) {
          weekCount++;
        }
        
        if (data['isHamaDetected'] == true) {
          detectedCount++;
        }
      }
      
      return {
        'total': totalCount,
        'today': todayCount,
        'thisWeek': weekCount,
        'detected': detectedCount,
        'lastUpdate': now.toIso8601String(),
      };
      
    } catch (e) {
      return {
        'total': 0,
        'today': 0,
        'thisWeek': 0,
        'detected': 0,
        'error': e.toString(),
      };
    }
  }

  // Clear old hama notifications
  static Future<void> clearOldHamaNotifications({int daysOld = 7}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('type', isEqualTo: 'hama_alert')
          .where('waktu', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        
        for (final doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
      }
      
    } catch (e) {
      // Error handled silently
    }
  }

  // Initialize hama monitoring (tambahan untuk init method)
  static Future<void> initializeHamaMonitoring() async {
    try {
      // Clean up old hama notifications
      await clearOldHamaNotifications();
      
      // Cancel any pending hama notifications from previous sessions
      await cancelHamaNotifications();
    } catch (e) {
      // Error handled silently
    }
  }
}