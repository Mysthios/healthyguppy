// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:healthyguppy/services/background_task.dart';

// class BackgroundServiceManager {
//   static const String _notificationChannelId = 'healthy_guppy_foreground';
//   static const int _foregroundNotificationId = 777;

//   /// Inisialisasi background service
//   static Future<void> initialize() async {
//     try {
//       final service = FlutterBackgroundService();
      
//       await service.configure(
//         androidConfiguration: AndroidConfiguration(
//           onStart: backgroundTaskEntryPoint,
//           isForegroundMode: true,
//           autoStart: true,
//           foregroundServiceNotificationId: _foregroundNotificationId,
//           notificationChannelId: _notificationChannelId,
//           initialNotificationTitle: 'Healthy Guppy Aktif',
//           initialNotificationContent: 'Mengecek jadwal harian...',
//         ),
//         iosConfiguration: IosConfiguration(
//           onForeground: _iosForegroundHandler,
//           onBackground: _iosBackgroundHandler,
//         ),
//       );

//       await service.startService();
//       debugPrint('✅ Background service initialized and started');
//     } catch (e) {
//       debugPrint('❌ Failed to initialize background service: $e');
//     }
//   }

//   /// Stop background service
//   static Future<void> stop() async {
//     try {
//       final service = FlutterBackgroundService();
//       service.invoke('stop');
//       debugPrint('✅ Background service stopped');
//     } catch (e) {
//       debugPrint('❌ Failed to stop background service: $e');
//     }
//   }

//   /// Restart background service
//   static Future<void> restart() async {
//     await stop();
//     await initialize();
//   }

//   /// Check if background service is running
//   static Future<bool> isRunning() async {
//     try {
//       final service = FlutterBackgroundService();
//       return await service.isRunning();
//     } catch (e) {
//       debugPrint('❌ Failed to check background service status: $e');
//       return false;
//     }
//   }

//   /// Update notification content
//   static Future<void> updateNotification({
//     required String title,
//     required String content,
//   }) async {
//     try {
//       final service = FlutterBackgroundService();
//       service.invoke('update_notification', {
//         'title': title,
//         'content': content,
//       });
//     } catch (e) {
//       debugPrint('❌ Failed to update notification: $e');
//     }
//   }

//   /// iOS foreground handler
//   static void _iosForegroundHandler(ServiceInstance service) {
//     debugPrint('📱 iOS foreground service started');
//     // Implement iOS-specific foreground logic here
//   }

//   /// iOS background handler
//   static Future<bool> _iosBackgroundHandler(ServiceInstance service) async {
//     debugPrint('📱 iOS background service running');
//     // Implement iOS-specific background logic here
//     return true;
//   }
// }