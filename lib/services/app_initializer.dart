import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:healthyguppy/firebase_options.dart';
import 'package:healthyguppy/services/alarm_service.dart';
import 'package:healthyguppy/services/background_service_manager.dart';
import 'package:healthyguppy/services/notification_service.dart';
import 'package:healthyguppy/services/jadwal_checker_service.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppInitializer {
  static Future<void> initialize() async {
    try {
      // Inisialisasi service dasar
      await _initBasicServices();
      
      // Inisialisasi alarm dan notifikasi
      await _initAlarmAndNotification();
      
      // Start background services
      await _initBackgroundServices();
      
      debugPrint('✅ App initialization completed successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize app: $e');
    }
  }

  static Future<void> _initBasicServices() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await NotificationService.init();
    await initializeDateFormatting('id_ID', null);
  }

  static Future<void> _initAlarmAndNotification() async {
    await AlarmService.initialize();
    await AlarmService.scheduleActiveAlarms();
  }

  static Future<void> _initBackgroundServices() async {
    await BackgroundServiceManager.initialize();
    JadwalCheckerService().startChecking();
  }
}