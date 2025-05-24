import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class JadwalCheckerService {
  Timer? _timer;

  void startChecking() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndTriggerNotification();
    });
  }

  void stopChecking() {
    _timer?.cancel();
  }

  Future<void> _checkAndTriggerNotification() async {
    final now = DateTime.now();
    final currentDay = DateFormat('EEEE', 'id_ID').format(now); // Misal "Kamis"
    final currentHour = now.hour;
    final currentMinute = now.minute;

    final snapshot = await FirebaseFirestore.instance.collection('jadwal').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final hari = (data['hari'] as List).first; // Ex: "Kamis"
      final isActive = data['isActive'] ?? false;
      final jam = data['jam'] ?? 0;
      final menit = data['menit'] ?? 0;

      if (isActive && hari.toLowerCase() == currentDay.toLowerCase()) {
        if (jam == currentHour && menit == currentMinute) {
          print('Cocok waktu! Kirim notifikasi');
          // Notifikasi!
          await NotificationService.showNotification(
            id: now.millisecondsSinceEpoch ~/ 1000,
            title: 'Pengingat Jadwal',
            body: 'Sekarang sudah jam $jam:$menit sesuai jadwal hari $hari!',
          );
        }
      }
    }
  }
}
