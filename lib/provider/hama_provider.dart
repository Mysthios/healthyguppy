import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/models/hama_model.dart';
import 'package:healthyguppy/models/notifikasi_model.dart';
import 'package:healthyguppy/services/firebase_service.dart';
import 'package:healthyguppy/services/notification_service.dart';

// Provider untuk Firebase Service (jika belum ada di providers lain)
final firebaseServiceProvider = Provider((ref) => FirebaseService());

// Provider untuk data hama real-time
final hamaDataProvider = StreamProvider<HamaData>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  
  try {
    return firebaseService.getHamaStream();
  } catch (e) {
    print('Error in hamaDataProvider: $e');
    // Return default "tidak ada hama" jika error
    return Stream.value(HamaData(
      nama: 'Tidak ada nama',
      status: 'Tidak ada hama',
      timestamp: DateTime.now(),
    ));
  }
});

// Provider untuk current hama data (one-time fetch)
final currentHamaProvider = FutureProvider<HamaData?>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  
  try {
    return firebaseService.getCurrentHama();
  } catch (e) {
    print('Error in currentHamaProvider: $e');
    return null;
  }
});

// Provider untuk hama notifications
final hamaNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  
  try {
    return firebaseService.getHamaNotifications();
  } catch (e) {
    print('Error in hamaNotificationsProvider: $e');
    return Stream.value(<NotificationModel>[]);
  }
});

// StateNotifier untuk mengelola hama actions














// StateNotifier untuk mengelola hama actions
// StateNotifier untuk mengelola hama actions
class HamaNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseService _firebaseService;
  final Ref _ref;
  HamaData? _lastHamaData;
  bool _isInitialized = false; // Flag untuk tracking initialization

  HamaNotifier(this._firebaseService, this._ref) : super(const AsyncValue.data(null)) {
    _initializeHamaMonitoring();
  }

  void _initializeHamaMonitoring() {
    // Listen to hama data changes
    _ref.listen<AsyncValue<HamaData>>(hamaDataProvider, (previous, next) {
      next.whenData((hamaData) {
        _handleHamaDataChange(hamaData);
      });
    });
  }

  // ✅ VERSI YANG SUDAH DIPERBAIKI DENGAN DEBUG LEBIH DETAIL
  void _handleHamaDataChange(HamaData newHamaData) {
    print('🔄 Processing hama data: ${newHamaData.status}');
    print('🔍 Should notify: ${newHamaData.shouldNotify()}');
    print('🔍 Last data: ${_lastHamaData?.status ?? 'null'}');
    print('🔍 Is initialized: $_isInitialized');
    print('🔍 Status comparison: "${_lastHamaData?.status}" vs "${newHamaData.status}"');
    print('🔍 Status equal: ${_lastHamaData?.status == newHamaData.status}');
    
    bool shouldTriggerNotification = false;
    String triggerReason = '';
    
    // ✅ KONDISI 1: Hanya trigger jika sudah ada data sebelumnya DAN status berubah ke "Hama Terdeteksi"
    if (_lastHamaData != null && 
        _lastHamaData!.status != newHamaData.status && 
        newHamaData.shouldNotify()) {
      shouldTriggerNotification = true;
      triggerReason = 'Status changed to HAMA: ${_lastHamaData!.status} -> ${newHamaData.status}';
      print('✅ Condition 1 met: Status changed to hama detected');
    }
    
    // ✅ KONDISI 2: Status berubah dari ada hama ke tidak ada hama (optional - untuk log saja)
    else if (_lastHamaData != null && 
             _lastHamaData!.shouldNotify() && 
             !newHamaData.shouldNotify() &&
             _lastHamaData!.status != newHamaData.status) {
      print('✅ Hama cleared: ${_lastHamaData!.status} -> ${newHamaData.status}');
      // Bisa tambahkan notifikasi "hama sudah hilang" jika diinginkan
      // shouldTriggerNotification = true;
      // triggerReason = 'Hama cleared';
    }
    
    // ✅ KONDISI 3: Pertama kali masuk app - hanya simpan data, jangan trigger notifikasi
    else if (_lastHamaData == null) {
      print('🆕 First time data load: ${newHamaData.status} - No notification triggered');
      _isInitialized = true;
    }
    
    // ✅ KONDISI 4: Status sama - tidak ada perubahan
    else if (_lastHamaData != null && _lastHamaData!.status == newHamaData.status) {
      print('📍 Same status, no change: ${newHamaData.status}');
    }
    
    // ✅ KONDISI 5: Status berubah tapi bukan ke hama terdeteksi
    else if (_lastHamaData != null && 
             _lastHamaData!.status != newHamaData.status && 
             !newHamaData.shouldNotify()) {
      print('📍 Status changed but not to hama: ${_lastHamaData!.status} -> ${newHamaData.status}');
    }
    
    // Trigger notification jika kondisi terpenuhi
    if (shouldTriggerNotification) {
      print('🚨 TRIGGERING NOTIFICATION: $triggerReason');
      _showHamaNotification(newHamaData);
      _addHamaNotificationToFirestore(newHamaData);
    } else {
      print('⏭️ No notification needed - Current conditions not met');
    }
    
    // Update _lastHamaData setelah semua pemrosesan selesai
    _lastHamaData = newHamaData;
    print('💾 Updated _lastHamaData to: ${_lastHamaData!.status}');
  }

  Future<void> _showHamaNotification(HamaData hamaData) async {
    try {
      await NotificationService.showHamaAlert(hamaData);
      print('✅ Hama notification shown successfully');
    } catch (e) {
      print('❌ Error showing hama notification: $e');
    }
  }

  Future<void> _addHamaNotificationToFirestore(HamaData hamaData) async {
    try {
      await _firebaseService.addHamaNotification(hamaData);
      print('✅ Hama notification added to Firestore');
    } catch (e) {
      print('❌ Error adding hama notification to Firestore: $e');
    }
  }

  // Method untuk manual update hama status (jika diperlukan)
  Future<void> updateHamaStatus(String status) async {
    state = const AsyncValue.loading();
    try {
      await _firebaseService.updateHamaStatus(status);
      state = const AsyncValue.data(null);
      print('✅ Hama status updated manually: $status');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      print('❌ Error updating hama status: $e');
    }
  }

  // Method untuk force check hama status
  Future<void> checkHamaStatus() async {
    state = const AsyncValue.loading();
    try {
      final hamaData = await _firebaseService.getCurrentHama();
      if (hamaData != null && hamaData.shouldNotify()) {
        await _showHamaNotification(hamaData);
        await _addHamaNotificationToFirestore(hamaData);
      }
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Method untuk reset monitoring (jika diperlukan untuk testing)
  void resetMonitoring() {
    _lastHamaData = null;
    _isInitialized = false;
    print('🔄 Hama monitoring reset');
  }
}

















// Provider untuk HamaNotifier
final hamaNotifierProvider = 
    StateNotifierProvider<HamaNotifier, AsyncValue<void>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return HamaNotifier(firebaseService, ref);
});

// Provider untuk hama statistics
final hamaStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final hamaDataAsync = ref.watch(hamaDataProvider);
  final hamaNotificationsAsync = ref.watch(hamaNotificationsProvider);
  
  return hamaDataAsync.when(
    data: (hamaData) {
      final notificationCount = hamaNotificationsAsync.when(
        data: (notifications) => notifications.length,
        loading: () => 0,
        error: (_, __) => 0,
      );
      
      return {
        'currentStatus': hamaData.status,
        'isHamaDetected': hamaData.isHamaDetected,
        'lastUpdated': hamaData.timestamp,
        'totalNotifications': notificationCount,
        'severityLevel': hamaData.getSeverityLevel(),
        'priority': hamaData.getPriority(),
        'statusColor': hamaData.getStatusColor(),
        'statusIcon': hamaData.getStatusIcon(),
      };
    },
    loading: () => <String, dynamic>{
      'currentStatus': 'Loading...',
      'isHamaDetected': false,
      'totalNotifications': 0,
    },
    error: (error, stack) => <String, dynamic>{
      'currentStatus': 'Error',
      'isHamaDetected': false,
      'totalNotifications': 0,
      'error': error.toString(),
    },
  );
});

// Provider untuk recent hama detections (last 24 hours)
final recentHamaDetectionsProvider = Provider<AsyncValue<List<NotificationModel>>>((ref) {
  final hamaNotificationsAsync = ref.watch(hamaNotificationsProvider);
  
  return hamaNotificationsAsync.when(
    data: (notifications) {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      final recentDetections = notifications.where((notif) {
        return notif.waktu.isAfter(yesterday) && 
               notif.type == 'hama_alert';
      }).toList();
      
      return AsyncValue.data(recentDetections);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider untuk hama alert count (unread)
final unreadHamaAlertsProvider = Provider<int>((ref) {
  final hamaNotificationsAsync = ref.watch(hamaNotificationsProvider);
  
  return hamaNotificationsAsync.when(
    data: (notifications) {
      return notifications.where((notif) => 
        !notif.isRead && notif.type == 'hama_alert'
      ).length;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Provider untuk hama monitoring status
final hamaMonitoringStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final hamaDataAsync = ref.watch(hamaDataProvider);
  final unreadAlerts = ref.watch(unreadHamaAlertsProvider);
  
  return hamaDataAsync.when(
    data: (hamaData) => {
      'isOnline': true,
      'status': hamaData.status,
      'lastUpdate': hamaData.timestamp,
      'unreadAlerts': unreadAlerts,
      'needsAttention': hamaData.isHamaDetected && unreadAlerts > 0,
    },
    loading: () => {
      'isOnline': false,
      'status': 'Loading...',
      'unreadAlerts': 0,
      'needsAttention': false,
    },
    error: (_, __) => {
      'isOnline': false,
      'status': 'Error',
      'unreadAlerts': 0,
      'needsAttention': true,
      'hasError': true,
    },
  );
});