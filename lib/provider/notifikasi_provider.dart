import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../models/notifikasi_model.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final notifikasiStreamProvider = StreamProvider<List<NotifikasiModel>>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  return service.getNotifications();
});

final addNotificationProvider = Provider((ref) {
  final service = ref.read(firebaseServiceProvider);
  return (NotifikasiModel notif) => service.addNotification(notif);
});
