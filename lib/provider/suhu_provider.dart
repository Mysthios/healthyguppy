import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/suhu_model.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

// Provider untuk FirebaseService
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Provider untuk NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider untuk stream suhu data
final suhuStreamProvider = StreamProvider<SuhuData>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getSuhuStream();
});

// Provider untuk notifikasi logic
final suhuNotificationProvider = Provider<void>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  
  // Listen to suhu changes
  ref.listen<AsyncValue<SuhuData>>(
    suhuStreamProvider,
    (previous, next) {
      next.whenData((suhuData) {
        // Hanya kirim notifikasi jika data sebelumnya ada dan suhu berubah
        if (previous?.value != null && 
            previous!.value!.suhu != suhuData.suhu) {
          notificationService.showSuhuAlert(suhuData);
        }
      });
    },
  );
});

// Provider untuk tracking previous suhu (untuk menghindari duplicate notifications)
final previousSuhuProvider = StateProvider<double?>((ref) => null);

// Provider untuk connection status
final connectionStatusProvider = StateProvider<ConnectionStatus>((ref) {
  return ConnectionStatus.connecting;
});

enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
  error,
}