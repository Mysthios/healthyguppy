import 'package:healthyguppy/services/jadwal_checker_service.dart';
import 'package:healthyguppy/models/jadwal_model.dart';

/// Helper class untuk menghubungkan PopupTambahUpdateJadwal dengan JadwalCheckerService
/// Memastikan konsistensi notification text dan database operations
class JadwalNotificationHelper {
  static final JadwalCheckerService _checkerService = JadwalCheckerService();
  
  /// Setup notifications untuk jadwal baru atau yang diupdate
  static Future<void> setupNotificationsForJadwal({
    required JadwalModel jadwal,
    bool isUpdate = false,
    List<int>? oldNotificationIds,
  }) async {
    print('🚀 === SETUP NOTIFICATIONS FOR JADWAL ===');
    print('📊 Jadwal: ${jadwal.jam}:${jadwal.menit} on ${jadwal.hari}');
    print('🔄 Is Update: $isUpdate');
    
    try {
      // Jika ini adalah update, cancel notifications lama dulu
      if (isUpdate && oldNotificationIds != null && oldNotificationIds.isNotEmpty) {
        print('🗑️ Cancelling old notifications...');
        await _checkerService.cancelScheduledNotifications(oldNotificationIds);
      }
      
      // Setup notifications baru
      await _checkerService.scheduleNotificationsForJadwal(
        jam: jadwal.jam,
        menit: jadwal.menit,
        selectedHari: jadwal.hari,
      );
      
      print('✅ Successfully setup notifications for jadwal');
    } catch (e) {
      print('❌ Error setting up notifications: $e');
      rethrow;
    }
  }
  
  /// Get consistent notification title
  static String getNotificationTitle() {
    return _checkerService.getNotificationTitle();
  }
  
  /// Get consistent notification body
  static String getNotificationBody(int jam, int menit) {
    return _checkerService.getNotificationBody(jam, menit);
  }
  
  /// Test notification (untuk debugging)
  static Future<void> testNotification() async {
    return await _checkerService.testNotification();
  }
  
  /// Get current user ID
  static String? get currentUserId => _checkerService.currentUserId;
  
  /// Generate notification IDs untuk jadwal (untuk tracking)
  static List<int> generateNotificationIds(List<String> selectedHari) {
    final baseId = DateTime.now().millisecondsSinceEpoch;
    return List.generate(selectedHari.length, (index) => baseId + index);
  }
}