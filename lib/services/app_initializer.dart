import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:healthyguppy/firebase_options.dart';
import 'package:healthyguppy/services/alarm_service.dart';
import 'package:healthyguppy/services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AppInitializer {
  static Future initialize() async {
    try {
      // Inisialisasi service dasar
      await _initBasicServices();
      
      // TAMBAHAN: Request permissions untuk notifikasi
      await _requestNotificationPermissions();
      
      // Inisialisasi alarm dan notifikasi
      await _initAlarmAndNotification();
      
      // // Start background services
      // await _initBackgroundServices();
      
      debugPrint('✅ App initialization completed successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize app: $e');
    }
  }

  static Future _initBasicServices() async {
    debugPrint('🔧 Initializing basic services...');
    
    // Inisialisasi Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // TAMBAHAN: Cleanup notifikasi sebelum init ulang
    // await NotificationService.forceCleanup();
    
    // Inisialisasi NotificationService
    await NotificationService.init();
    
    // Inisialisasi date formatting
    await initializeDateFormatting('id_ID', null);
    
    debugPrint('✅ Basic services initialized');
  }

  // TAMBAHAN: Method untuk request notification permissions
  static Future _requestNotificationPermissions() async {
    debugPrint('🔔 Requesting notification permissions...');
    
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        debugPrint('📱 Android SDK Version: ${androidInfo.version.sdkInt}');
        
        // Android 13+ (API 33+) memerlukan runtime permission untuk POST_NOTIFICATIONS
        if (androidInfo.version.sdkInt >= 33) {
          final notificationStatus = await Permission.notification.request();
          debugPrint('📣 Notification permission: $notificationStatus');
          
          if (notificationStatus.isDenied) {
            debugPrint('⚠️ Notification permission denied by user');
          }
        }
        
        // Android 12+ (API 31+) memerlukan permission untuk exact alarms
        if (androidInfo.version.sdkInt >= 31) {
          final alarmPermission = await Permission.scheduleExactAlarm.status;
          debugPrint('⏰ Exact alarm permission: $alarmPermission');
          
          if (alarmPermission.isDenied) {
            final alarmStatus = await Permission.scheduleExactAlarm.request();
            debugPrint('⏰ Exact alarm permission after request: $alarmStatus');
          }
        }
        
        debugPrint('✅ Permission requests completed');
        
      } catch (e) {
        debugPrint('❌ Error requesting permissions: $e');
        // Jangan throw error, biarkan app tetap jalan
      }
    } else {
      debugPrint('📱 iOS detected, skipping Android-specific permissions');
    }
  }

  static Future _initAlarmAndNotification() async {
    debugPrint('⏰ Initializing alarm and notification services...');
    await AlarmService.initialize();
    await AlarmService.scheduleActiveAlarms();
    debugPrint('✅ Alarm and notification services initialized');
  }

  // static Future _initBackgroundServices() async {
  //   debugPrint('🔄 Initializing background services...');
  //   await BackgroundServiceManager.initialize();
  //   JadwalCheckerService().startChecking();
  //   debugPrint('✅ Background services initialized');
  // }
}