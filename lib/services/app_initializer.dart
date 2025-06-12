import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/firebase_options.dart';
import 'package:healthyguppy/models/hama_model.dart';
import 'package:healthyguppy/provider/hama_provider.dart';
import 'package:healthyguppy/services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AppInitializer {
  static ProviderContainer? _container;
  
  static Future initialize() async {
    try {
      // Inisialisasi service dasar
      await _initBasicServices();
      
      // Request permissions untuk notifikasi
      await _requestNotificationPermissions();
      
      // Inisialisasi NotificationService
      await _initNotificationService();
      
      // ✨ Inisialisasi Riverpod Container untuk monitoring
      await _initRiverpodContainer();
      
      // ✨ Start hama monitoring menggunakan Riverpod
      await _initHamaMonitoring();
      
      // Start temperature monitoring (if needed)
      // await _initTemperatureMonitoring();
      
      debugPrint('✅ App initialization completed successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize app: $e');
      rethrow;
    }
  }

  static Future _initBasicServices() async {
    debugPrint('🔧 Initializing basic services...');
    
    // Inisialisasi Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    
    // Inisialisasi date formatting
    await initializeDateFormatting('id_ID', null);
    
    debugPrint('✅ Basic services initialized');
  }

  static Future _initNotificationService() async {
    debugPrint('🔔 Initializing notification service...');
    
    try {
      // Cleanup notifikasi lama sebelum init ulang
      await NotificationService.forceCleanup();
      
      // Inisialisasi NotificationService
      await NotificationService.init();
      
      debugPrint('✅ Notification service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize notification service: $e');
      // Don't throw error, let the app continue running
    }
  }

  // ✨ Inisialisasi Riverpod Container untuk background monitoring
  static Future _initRiverpodContainer() async {
    debugPrint('🏗️ Initializing Riverpod container...');
    
    try {
      _container = ProviderContainer();
      debugPrint('✅ Riverpod container initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Riverpod container: $e');
      throw e;
    }
  }

  // ✨ Inisialisasi Hama Monitoring menggunakan Riverpod Providers
  static Future _initHamaMonitoring() async {
    debugPrint('🐛 Initializing hama monitoring with Riverpod...');
    
    try {
      if (_container == null) {
        throw Exception('Riverpod container not initialized');
      }

      // Initialize HamaNotifier - ini akan otomatis start monitoring
      final hamaNotifier = _container!.read(hamaNotifierProvider.notifier);
      debugPrint('📊 HamaNotifier initialized and monitoring started');

      // Listen to hama data stream untuk background monitoring
      _container!.listen<AsyncValue<HamaData>>(
        hamaDataProvider,
        (previous, next) {
          next.when(
            data: (hamaData) {
              debugPrint('📈 Hama data updated: ${hamaData.status}');
              
              // Log status untuk debugging
              if (hamaData.isHamaDetected) {
                debugPrint('⚠️ HAMA DETECTED: ${hamaData.status}');
              } else {
                debugPrint('✅ No hama detected: ${hamaData.status}');
              }
            },
            loading: () => debugPrint('🔄 Loading hama data...'),
            error: (error, stackTrace) {
              debugPrint('❌ Error in hama data stream: $error');
            },
          );
        },
        fireImmediately: true,
      );

      // Listen to hama stats untuk monitoring overview
      _container!.listen<Map<String, dynamic>>(
        hamaStatsProvider,
        (previous, next) {
          debugPrint('📊 Hama stats updated: ${next['currentStatus']} | Notifications: ${next['totalNotifications']}');
        },
        fireImmediately: true,
      );

      // Listen to unread alerts
      _container!.listen<int>(
        unreadHamaAlertsProvider,
        (previous, next) {
          if (next > 0) {
            debugPrint('🔔 Unread hama alerts: $next');
          }
        },
        fireImmediately: true,
      );

      debugPrint('✅ Hama monitoring initialized successfully with Riverpod');
    } catch (e) {
      debugPrint('❌ Failed to initialize hama monitoring: $e');
      // Don't throw error, let the app continue running
    }
  }

  // Request notification permissions
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

  // Method untuk stop semua monitoring services saat app ditutup
  static Future dispose() async {
    debugPrint('🛑 Disposing app services...');
    
    try {
      // ✨ Dispose Riverpod container (otomatis stop semua providers)
      _container?.dispose();
      _container = null;
      
      // Cancel all pending notifications
      await NotificationService().cancelAllNotifications();
      
      debugPrint('✅ App services disposed successfully');
    } catch (e) {
      debugPrint('❌ Error disposing services: $e');
    }
  }

  // Test notification functionality
  static Future testNotification() async {
    try {
      await NotificationService.showNotification(
        title: 'Test Notification',
        body: 'App berhasil diinisialisasi dan notifikasi berfungsi!',
      );
      debugPrint('✅ Test notification sent');
    } catch (e) {
      debugPrint('❌ Test notification failed: $e');
    }
  }

  // ✨ Test hama notification
  static Future testHamaNotification() async {
    try {
      await NotificationService.showNotification(
        title: '⚠️ Hama Terdeteksi!',
        body: 'Hama telah terdeteksi pada akuarium Anda. Segera lakukan penanganan yang diperlukan.',
      );
      debugPrint('✅ Test hama notification sent');
    } catch (e) {
      debugPrint('❌ Test hama notification failed: $e');
    }
  }

  // ✨ Force check hama status (manual trigger)
  static Future forceCheckHamaStatus() async {
    try {
      if (_container == null) {
        debugPrint('⚠️ Riverpod container not initialized');
        return;
      }

      final hamaNotifier = _container!.read(hamaNotifierProvider.notifier);
      await hamaNotifier.checkHamaStatus();
      debugPrint('✅ Force hama check completed');
    } catch (e) {
      debugPrint('❌ Error in force hama check: $e');
    }
  }

  // ✨ Update hama status manually (untuk testing)
  static Future updateHamaStatus(String status) async {
    try {
      if (_container == null) {
        debugPrint('⚠️ Riverpod container not initialized');
        return;
      }

      final hamaNotifier = _container!.read(hamaNotifierProvider.notifier);
      await hamaNotifier.updateHamaStatus(status);
      debugPrint('✅ Hama status updated to: $status');
    } catch (e) {
      debugPrint('❌ Error updating hama status: $e');
    }
  }

  // ✨ Get current hama monitoring status
  static Map<String, dynamic>? get hamaMonitoringStatus {
    if (_container == null) return null;
    
    try {
      return _container!.read(hamaMonitoringStatusProvider);
    } catch (e) {
      debugPrint('❌ Error getting hama monitoring status: $e');
      return null;
    }
  }

  // ✨ Get current hama stats
  static Map<String, dynamic>? get hamaStats {
    if (_container == null) return null;
    
    try {
      return _container!.read(hamaStatsProvider);
    } catch (e) {
      debugPrint('❌ Error getting hama stats: $e');
      return null;
    }
  }

  // ✨ Get unread hama alerts count
  static int get unreadHamaAlerts {
    if (_container == null) return 0;
    
    try {
      return _container!.read(unreadHamaAlertsProvider);
    } catch (e) {
      debugPrint('❌ Error getting unread hama alerts: $e');
      return 0;
    }
  }

  // Check if container is initialized
  static bool get isInitialized => _container != null;
}