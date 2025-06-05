import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'firebase_service.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void backgroundTaskEntryPoint(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // ✅ Tambahkan baris ini agar tidak error no small icon
    service.setForegroundNotificationInfo(
      title: "Healthy Guppy Aktif",
      content: "Mengecek jadwal harian...",
    );
  }

  Timer.periodic(const Duration(minutes: 15), (timer) async {
    if (service is AndroidServiceInstance && !await service.isForegroundService()) {
      return;
    }

    final firebaseService = FirebaseService();
    final notificationService = NotificationService();

    final jadwalList = await firebaseService.getActiveSchedules();
    final now = DateTime.now();

    for (var jadwal in jadwalList) {
      final selisih = jadwal.waktu.difference(now).inMinutes;
      if (selisih >= 0 && selisih <= 1) {
        await notificationService.scheduleNotification(
          id: jadwal.waktu.millisecondsSinceEpoch ~/ 1000,
          title: jadwal.judul,
          body: jadwal.isi,
          scheduledDate: jadwal.waktu,
        );
      }
    }
  });
}

