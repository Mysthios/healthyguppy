// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'notification_service.dart';

// class JadwalCheckerService {
//   Timer? _timer;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Helper method untuk mendapatkan current user ID
//   String? get _currentUserId => _auth.currentUser?.uid;

//   void startChecking() {
//     _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       _checkAndTriggerNotification();
//     });
//   }

//   void stopChecking() {
//     _timer?.cancel();
//   }

//   Future<void> _checkAndTriggerNotification() async {
//     // Jangan cek jika user belum login
//     if (_currentUserId == null) {
//       print('User belum login, skip notification check');
//       return;
//     }

//     final now = DateTime.now();
//     final currentDay = DateFormat('EEEE', 'id_ID').format(now);
//     final currentHour = now.hour;
//     final currentMinute = now.minute;

//     try {
//       // Hanya ambil jadwal milik user yang sedang login
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('jadwal')
//               .where(
//                 'userId',
//                 isEqualTo: _currentUserId,
//               ) // Filter berdasarkan userId
//               .where('isActive', isEqualTo: true) // Hanya jadwal yang aktif
//               .get();

//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         final hariList = List<String>.from(data['hari'] ?? []);
//         final jam = data['jam'] ?? 0;
//         final menit = data['menit'] ?? 0;

//         // Cek apakah hari ini ada dalam daftar hari jadwal
//         bool isToday = hariList.any(
//           (hari) => hari.toLowerCase() == currentDay.toLowerCase(),
//         );

//         if (isToday && jam == currentHour && menit == currentMinute) {
//           print('Cocok waktu! Kirim notifikasi untuk user: $_currentUserId');

//           // Kirim notifikasi
//           await NotificationService.showNotification(
//             // id: now.millisecondsSinceEpoch ~/ 1000,
//             title: 'Pengingat Jadwal',
//             body:
//                 'Sekarang sudah jam ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')} sesuai jadwal!',
//           );

//           // Optional: Simpan notifikasi ke database
//           await _saveNotificationToDatabase(
//             'Pengingat Jadwal',
//             'Sekarang sudah jam ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')} sesuai jadwal!',
//             now,
//           );
//         }
//       }
//     } catch (e) {
//       print('Error checking jadwal: $e');
//     }
//   }

//   // // Method untuk menyimpan notifikasi ke database - FIXED VERSION
//   // Future<void> _saveNotificationToDatabase(
//   //   String title,
//   //   String body,
//   //   DateTime time,
//   // ) async {
//   //   if (_currentUserId == null) return;

//   //   try {
//   //     await FirebaseFirestore.instance.collection('notifikasi').add({
//   //       'judul': title,
//   //       'isi': body,
//   //       'waktu': FieldValue.serverTimestamp(), // ✅ Hanya satu field waktu
//   //       'userId': _currentUserId,
//   //       'isRead': false,
//   //     });
//   //     print('Notification saved to database successfully');
//   //   } catch (e) {
//   //     print('Error saving notification: $e');
//   //   }
//   // }

//   Future<void> _saveNotificationToDatabase(
//     String title,
//     String body,
//     DateTime time,
//   ) async {
//     print('🚀 === _saveNotificationToDatabase CALLED ===');
//     print('📝 Title: $title');
//     print('📝 Body: $body');
//     print('📝 Time: $time');
//     print('👤 Current User ID: $_currentUserId');
//     print('🔐 Auth Current User: ${_auth.currentUser?.uid}');

//     if (_currentUserId == null) {
//       print('❌ STOPPING: User ID is null');
//       return;
//     }

//     print('🔄 Attempting to save to Firestore...');

//     try {
//       // Test koneksi dulu
//       print('🌐 Testing Firestore connection...');
//       await FirebaseFirestore.instance.enableNetwork();
//       print('✅ Network enabled');

//       // Simpan data
//       print('💾 Adding document to collection...');
//       DocumentReference docRef = await FirebaseFirestore.instance
//           .collection('notifikasi')
//           .add({
//             'judul': title,
//             'isi': body,
//             'waktu': FieldValue.serverTimestamp(),
//             'userId': _currentUserId,
//             'isRead': false,
//             'debug_timestamp': DateTime.now().millisecondsSinceEpoch,
//           });

//       print('✅ SUCCESS! Document added with ID: ${docRef.id}');

//       // Tunggu sebentar lalu verify
//       await Future.delayed(Duration(seconds: 2));
//       DocumentSnapshot snapshot = await docRef.get();

//       if (snapshot.exists) {
//         print('✅ VERIFIED! Document exists in database');
//         print('📄 Data: ${snapshot.data()}');
//       } else {
//         print('❌ WARNING! Document not found after save');
//       }
//     } catch (e, stackTrace) {
//       print('❌ ERROR SAVING: $e');
//       print('🔥 Error type: ${e.runtimeType}');
//       print('📍 Stack trace: $stackTrace');

//       if (e is FirebaseException) {
//         print('🔥 Firebase Error Code: ${e.code}');
//         print('🔥 Firebase Error Message: ${e.message}');
//       }
//     }

//     print('🏁 === _saveNotificationToDatabase FINISHED ===');
//   }

//   // Method untuk restart checker ketika user login/logout
//   void restartForUser() {
//     stopChecking();
//     if (_currentUserId != null) {
//       startChecking();
//     }
//   }
// }



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
      final snapshot =
          await FirebaseFirestore.instance
              .collection('jadwal')
              .where(
                'userId',
                isEqualTo: _currentUserId,
              ) // Filter berdasarkan userId
              .where('isActive', isEqualTo: true) // Hanya jadwal yang aktif
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final hariList = List<String>.from(data['hari'] ?? []);
        final jam = data['jam'] ?? 0;
        final menit = data['menit'] ?? 0;

        // Cek apakah hari ini ada dalam daftar hari jadwal
        bool isToday = hariList.any(
          (hari) => hari.toLowerCase() == currentDay.toLowerCase(),
        );

        if (isToday && jam == currentHour && menit == currentMinute) {
          print('Cocok waktu! Kirim notifikasi untuk user: $_currentUserId');

          // Gunakan method yang sama untuk generate notification text
          final title = getNotificationTitle();
          final body = getNotificationBody(jam, menit);

          // Kirim notifikasi
          await NotificationService.showNotification(
            title: title,
            body: body,
          );

          // Simpan notifikasi ke database
          await saveNotificationToDatabase(title, body, now);
        }
      }
    } catch (e) {
      print('Error checking jadwal: $e');
    }
  }

  // 🔥 PUBLIC METHODS untuk digunakan dari PopupTambahUpdateJadwal
  
  /// Generate title notifikasi yang konsisten
  String getNotificationTitle() {
    return 'Pengingat Jadwal';
  }

  /// Generate body notifikasi yang konsisten
  String getNotificationBody(int jam, int menit) {
    return 'Sekarang sudah jam ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')} sesuai jadwal!';
  }

  /// Save notification ke database - bisa dipanggil dari luar
  Future<void> saveNotificationToDatabase(
    String title,
    String body,
    DateTime time, {
    String? additionalInfo,
  }) async {
    print('🚀 === saveNotificationToDatabase CALLED ===');
    print('📝 Title: $title');
    print('📝 Body: $body');
    print('📝 Time: $time');
    print('👤 Current User ID: $_currentUserId');
    print('🔐 Auth Current User: ${_auth.currentUser?.uid}');
    
    if (additionalInfo != null) {
      print('ℹ️ Additional Info: $additionalInfo');
    }

    if (_currentUserId == null) {
      print('❌ STOPPING: User ID is null');
      return;
    }

    print('🔄 Attempting to save to Firestore...');

    try {
      // Test koneksi dulu
      print('🌐 Testing Firestore connection...');
      await FirebaseFirestore.instance.enableNetwork();
      print('✅ Network enabled');

      // Simpan data
      print('💾 Adding document to collection...');
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('notifikasi')
          .add({
            'judul': title,
            'isi': body,
            'waktu': FieldValue.serverTimestamp(),
            'userId': _currentUserId,
            'isRead': false,
            'debug_timestamp': DateTime.now().millisecondsSinceEpoch,
            'source': 'jadwal_checker', // Untuk tracking dari mana notifikasi ini
            'additional_info': additionalInfo,
          });

      print('✅ SUCCESS! Document added with ID: ${docRef.id}');

      // Tunggu sebentar lalu verify
      await Future.delayed(Duration(seconds: 2));
      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        print('✅ VERIFIED! Document exists in database');
        print('📄 Data: ${snapshot.data()}');
      } else {
        print('❌ WARNING! Document not found after save');
      }
    } catch (e, stackTrace) {
      print('❌ ERROR SAVING: $e');
      print('🔥 Error type: ${e.runtimeType}');
      print('📍 Stack trace: $stackTrace');

      if (e is FirebaseException) {
        print('🔥 Firebase Error Code: ${e.code}');
        print('🔥 Firebase Error Message: ${e.message}');
      }
    }

    print('🏁 === saveNotificationToDatabase FINISHED ===');
  }

  /// Method helper untuk schedule multiple notifications
  Future<void> scheduleNotificationsForJadwal({
    required int jam,
    required int menit,
    required List<String> selectedHari,
    String? customTitle,
    String? customBody,
  }) async {
    print('🚀 === SCHEDULING NOTIFICATIONS FOR JADWAL ===');
    
    final title = customTitle ?? getNotificationTitle();
    final body = customBody ?? getNotificationBody(jam, menit);
    
    print('📝 Using Title: $title');
    print('📝 Using Body: $body');
    print('📅 Days: $selectedHari');
    print('⏰ Time: ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')}');

    final baseId = DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now();
    
    // Mapping hari Indonesia ke index (Minggu = 0, Senin = 1, dst)
    final hariMapping = {
      'Minggu': 0,
      'Senin': 1,
      'Selasa': 2,
      'Rabu': 3,
      'Kamis': 4,
      'Jumat': 5,
      'Sabtu': 6,
    };

    for (int i = 0; i < selectedHari.length; i++) {
      final hari = selectedHari[i];
      final hariIndex = hariMapping[hari];
      
      if (hariIndex == null) {
        print('❌ Invalid day: $hari');
        continue;
      }
      
      DateTime nextScheduledDate = _getNextScheduledDate(now, hariIndex, jam, menit);
      final notificationId = baseId + i;
      
      try {
        // Schedule notification menggunakan NotificationService
        await NotificationService.scheduleNotification(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: nextScheduledDate,
        );
        
        // Save preview notification ke database dengan info tambahan
        await saveNotificationToDatabase(
          title,
          body,
          nextScheduledDate,
          additionalInfo: 'Scheduled for $hari at ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')}',
        );
        
        print('✅ Scheduled notification for $hari at $nextScheduledDate');
      } catch (e) {
        print('❌ Failed to schedule notification for $hari: $e');
      }
    }

    print('🏁 === NOTIFICATION SCHEDULING COMPLETED ===');
  }

  /// Helper method untuk menghitung tanggal jadwal berikutnya
  DateTime _getNextScheduledDate(DateTime now, int targetDayOfWeek, int targetHour, int targetMinute) {
    int currentDayOfWeek = now.weekday == 7 ? 0 : now.weekday;
    int daysUntilTarget = (targetDayOfWeek - currentDayOfWeek) % 7;
    
    if (daysUntilTarget == 0) {
      final targetTime = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
      if (targetTime.isBefore(now)) {
        daysUntilTarget = 7;
      }
    }
    
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day + daysUntilTarget,
      targetHour,
      targetMinute,
    );
    
    return scheduledDate;
  }

  /// Method untuk cancel semua scheduled notifications (untuk edit/delete jadwal)
  Future<void> cancelScheduledNotifications(List<int> notificationIds) async {
    print('🗑️ Cancelling scheduled notifications: $notificationIds');
    
    try {
      for (int id in notificationIds) {
        await NotificationService.cancelNotification(id);
        print('✅ Cancelled notification ID: $id');
      }
    } catch (e) {
      print('❌ Error cancelling notifications: $e');
    }
  }

  // Method untuk restart checker ketika user login/logout
  void restartForUser() {
    stopChecking();
    if (_currentUserId != null) {
      startChecking();
    }
  }

  // Getter untuk mengakses user ID dari luar (jika diperlukan)
  String? get currentUserId => _currentUserId;

  // Method untuk test notification (untuk debugging)
  Future<void> testNotification() async {
    final title = getNotificationTitle();
    final body = getNotificationBody(DateTime.now().hour, DateTime.now().minute);
    
    await NotificationService.showNotification(
      title: title,
      body: body,
    );
    
    await saveNotificationToDatabase(
      title,
      body,
      DateTime.now(),
      additionalInfo: 'Test notification',
    );
    
    print('🧪 Test notification sent and saved');
  }
}