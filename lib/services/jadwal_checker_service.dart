import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class JadwalCheckerService {
  Timer? _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method untuk mendapatkan current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  void startChecking() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndTriggerNotification();
    });
  }

  void stopChecking() {
    _timer?.cancel();
  }

  Future<void> _checkAndTriggerNotification() async {
    // Jangan cek jika user belum login
    if (_currentUserId == null) {
      print('User belum login, skip notification check');
      return;
    }

    final now = DateTime.now();
    final currentDay = DateFormat('EEEE', 'id_ID').format(now);
    final currentHour = now.hour;
    final currentMinute = now.minute;

    try {
      // Hanya ambil jadwal milik user yang sedang login
      final snapshot = await FirebaseFirestore.instance
          .collection('jadwal')
          .where('userId', isEqualTo: _currentUserId) // Filter berdasarkan userId
          .where('isActive', isEqualTo: true) // Hanya jadwal yang aktif
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final hariList = List<String>.from(data['hari'] ?? []);
        final jam = data['jam'] ?? 0;
        final menit = data['menit'] ?? 0;

        // Cek apakah hari ini ada dalam daftar hari jadwal
        bool isToday = hariList.any((hari) => 
            hari.toLowerCase() == currentDay.toLowerCase());

        if (isToday && jam == currentHour && menit == currentMinute) {
          print('Cocok waktu! Kirim notifikasi untuk user: $_currentUserId');
          
          // Kirim notifikasi
          await NotificationService.showNotification(
            id: now.millisecondsSinceEpoch ~/ 1000,
            title: 'Pengingat Jadwal',
            body: 'Sekarang sudah jam ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')} sesuai jadwal!',
          );

          // Optional: Simpan notifikasi ke database
          await _saveNotificationToDatabase(
            'Pengingat Jadwal',
            'Sekarang sudah jam ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')} sesuai jadwal!',
            now,
          );
        }
      }
    } catch (e) {
      print('Error checking jadwal: $e');
    }
  }

  // Method untuk menyimpan notifikasi ke database
  Future<void> _saveNotificationToDatabase(
      String title, String body, DateTime time) async {
    if (_currentUserId == null) return;

    try {
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'judul': title,
        'isi': body,
        'waktu': Timestamp.fromDate(time),
        'userId': _currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false, // Tambahan field untuk tracking baca/belum
      });
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  // Method untuk restart checker ketika user login/logout
  void restartForUser() {
    stopChecking();
    if (_currentUserId != null) {
      startChecking();
    }
  }
}