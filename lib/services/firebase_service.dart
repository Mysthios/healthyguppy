// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:healthyguppy/models/jadwal_model.dart';
// import 'package:healthyguppy/models/notifikasi_model.dart';
// import 'package:healthyguppy/models/suhu_model.dart';

// class FirebaseService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Helper method untuk mendapatkan current user ID
//   String? get _currentUserId => _auth.currentUser?.uid;

//   // --- SUHU MONITORING ---
//   static const String _collectionName = 'Monitoring';
//   static const String _documentId = 'QiTZ7CtUxanTTlefUyOF';

//   Stream<SuhuData> getSuhuStream() {
//     return _db
//         .collection(_collectionName)
//         .doc(_documentId)
//         .snapshots()
//         .map((snapshot) {
//           if (snapshot.exists && snapshot.data() != null) {
//             final data = snapshot.data()!;
//             return SuhuData.fromFirestore(data);
//           } else {
//             throw Exception('Document tidak ditemukan');
//           }
//         });
//   }

//   Future<SuhuData?> getCurrentSuhu() async {
//     try {
//       DocumentSnapshot snapshot =
//           await _db.collection(_collectionName).doc(_documentId).get();

//       if (snapshot.exists && snapshot.data() != null) {
//         final data = snapshot.data() as Map<String, dynamic>;
//         return SuhuData.fromFirestore(data);
//       }
      
//       return null;
//     } catch (e) {
//       throw Exception('Error mengambil data: $e');
//     }
//   }

//   // --- JADWAL ---
//   Future<void> addJadwal(JadwalModel jadwal) async {
//     if (_currentUserId == null) {
//       throw Exception('User belum login');
//     }

//     await _db.collection('jadwal').add({
//       'jam': jadwal.jam,
//       'menit': jadwal.menit,
//       'hari': jadwal.hari,
//       'isActive': jadwal.isActive,
//       'userId': _currentUserId,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> updateJadwal(String id, JadwalModel jadwal) async {
//     if (_currentUserId == null) {
//       throw Exception('User belum login');
//     }

//     final doc = await _db.collection('jadwal').doc(id).get();
//     if (!doc.exists || doc.data()?['userId'] != _currentUserId) {
//       throw Exception('Jadwal tidak ditemukan atau bukan milik Anda');
//     }

//     await _db.collection('jadwal').doc(id).update({
//       'jam': jadwal.jam,
//       'menit': jadwal.menit,
//       'hari': jadwal.hari,
//       'isActive': jadwal.isActive,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> deleteJadwal(String id) async {
//     if (_currentUserId == null) {
//       throw Exception('User belum login');
//     }

//     final doc = await _db.collection('jadwal').doc(id).get();
//     if (!doc.exists || doc.data()?['userId'] != _currentUserId) {
//       throw Exception('Jadwal tidak ditemukan atau bukan milik Anda');
//     }

//     await _db.collection('jadwal').doc(id).delete();
//   }

//   Stream<List<JadwalModel>> getJadwal() {
//     if (_currentUserId == null) {
//       return Stream.value([]);
//     }

//     return _db
//         .collection('jadwal')
//         .where('userId', isEqualTo: _currentUserId)
//         .orderBy('createdAt', descending: false)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) {
//             final data = doc.data();
//             return JadwalModel(
//               id: doc.id,
//               jam: data['jam'],
//               menit: data['menit'],
//               hari: List<String>.from(data['hari']),
//               isActive: data['isActive'] ?? false,
//             );
//           }).toList();
//         });
//   }

//   // --- NOTIFIKASI ---
//   // Gunakan collection 'notifications' sesuai dengan NotificationService
//   Future<void> addNotification(NotificationModel notif) async {
//     try {
//       await _db.collection('notifications').add({
//         'judul': notif.judul,
//         'isi': notif.isi,
//         'type': notif.type,
//         'waktu': FieldValue.serverTimestamp(),
//         'isRead': false,
//         'createdAt': DateTime.now().toIso8601String(),
//         'notificationId': notif.notificationId,
//         ...?notif.extraData,
//       });
//       print('✅ Notification added to Firestore: ${notif.judul}');
//     } catch (e) {
//       print('❌ Error adding notification to Firestore: $e');
//       throw Exception('Error adding notification: $e');
//     }
//   }

//   // Menggunakan collection 'notifications' dan tanpa filter userId
//   Stream<List<NotificationModel>> getNotifications() {
//     return _db
//         .collection('notifications')
//         .orderBy('waktu', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) {
//             try {
//               return NotificationModel.fromFirestore(doc);
//             } catch (e) {
//               print('Error parsing notification ${doc.id}: $e');
//               return null;
//             }
//           }).where((notif) => notif != null).cast<NotificationModel>().toList();
//         });
//   }

//   // Method untuk mendapatkan jadwal aktif dan mengkonversi ke NotificationModel
//   Future<List<NotificationModel>> getActiveSchedules() async {
//     if (_currentUserId == null) {
//       return [];
//     }

//     final snapshot = await _db
//         .collection('jadwal')
//         .where('userId', isEqualTo: _currentUserId)
//         .where('isActive', isEqualTo: true)
//         .get();

//     final now = DateTime.now();
//     final today = now.weekday;
//     List<NotificationModel> scheduledNotifs = [];

//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//       final hariList = List<String>.from(data['hari'] ?? []);
//       if (hariList.contains(_getHariFromInt(today))) {
//         final jam = data['jam'] ?? 0;
//         final menit = data['menit'] ?? 0;
//         final scheduledTime = DateTime(
//           now.year,
//           now.month,
//           now.day,
//           jam,
//           menit,
//         );

//         if (scheduledTime.isAfter(now)) {
//           final timeString = '${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')}';
//           scheduledNotifs.add(
//             NotificationModel(
//               id: doc.id,
//               judul: 'Pengingat Jadwal',
//               isi: 'Saatnya memberikan makan ikan pada jam $timeString',
//               type: 'jadwal',
//               waktu: scheduledTime,
//               extraData: {
//                 'jadwalId': doc.id,
//                 'scheduledTime': timeString,
//                 'hari': hariList,
//               },
//             ),
//           );
//         }
//       }
//     }
//     return scheduledNotifs;
//   }

//   String _getHariFromInt(int weekday) {
//     const days = [
//       'Senin',
//       'Selasa',
//       'Rabu',
//       'Kamis',
//       'Jumat',
//       'Sabtu',
//       'Minggu',
//     ];
//     return days[weekday - 1];
//   }

//   // Method untuk mendapatkan nama hari dari weekday (1 = Monday, 7 = Sunday)
//   String getDayName(int weekday) {
//     return _getHariFromInt(weekday);
//   }

//   // Method untuk mendapatkan weekday dari nama hari
//   int getWeekdayFromName(String dayName) {
//     const days = [
//       'Senin',
//       'Selasa',
//       'Rabu',
//       'Kamis',
//       'Jumat',
//       'Sabtu',
//       'Minggu',
//     ];
//     final index = days.indexOf(dayName);
//     return index == -1 ? 1 : index + 1;
//   }

//   // Update method untuk menghapus notifikasi lama
//   Future<void> deleteOldNotifications() async {
//     try {
//       final now = DateTime.now();
//       final sevenDaysAgo = now.subtract(const Duration(days: 7)); // Ubah ke 7 hari
      
//       final snapshot = await _db
//           .collection('notifications')
//           .where('waktu', isLessThan: Timestamp.fromDate(sevenDaysAgo))
//           .get();

//       if (snapshot.docs.isNotEmpty) {
//         final batch = _db.batch();
//         for (var doc in snapshot.docs) {
//           batch.delete(doc.reference);
//         }
//         await batch.commit();
//         print('✅ Deleted ${snapshot.docs.length} old notifications');
//       }
//     } catch (e) {
//       print('❌ Error deleting old notifications: $e');
//     }
//   }

//   // Update method untuk menghapus semua notifikasi
//   Future<void> clearAllNotifications() async {
//     try {
//       final snapshot = await _db.collection('notifications').get();

//       if (snapshot.docs.isNotEmpty) {
//         final batch = _db.batch();
//         for (var doc in snapshot.docs) {
//           batch.delete(doc.reference);
//         }
//         await batch.commit();
//         print('✅ Cleared all notifications (${snapshot.docs.length} items)');
//       }
//     } catch (e) {
//       print('❌ Error clearing notifications: $e');
//       throw Exception('Error clearing notifications: $e');
//     }
//   }

//   // Method untuk menandai notifikasi sebagai dibaca
//   Future<void> markNotificationAsRead(String notificationId) async {
//     try {
//       await _db.collection('notifications').doc(notificationId).update({
//         'isRead': true,
//         'readAt': FieldValue.serverTimestamp(),
//       });
//       print('✅ Notification marked as read: $notificationId');
//     } catch (e) {
//       print('❌ Error marking notification as read: $e');
//       throw Exception('Error marking notification as read: $e');
//     }
//   }

//   // Method untuk menandai semua notifikasi sebagai dibaca
//   Future<void> markAllNotificationsAsRead() async {
//     try {
//       final snapshot = await _db
//           .collection('notifications')
//           .where('isRead', isEqualTo: false)
//           .get();

//       if (snapshot.docs.isNotEmpty) {
//         final batch = _db.batch();
//         for (var doc in snapshot.docs) {
//           batch.update(doc.reference, {
//             'isRead': true,
//             'readAt': FieldValue.serverTimestamp(),
//           });
//         }
//         await batch.commit();
//         print('✅ Marked ${snapshot.docs.length} notifications as read');
//       }
//     } catch (e) {
//       print('❌ Error marking all notifications as read: $e');
//       throw Exception('Error marking all notifications as read: $e');
//     }
//   }

//   // Method untuk mendapatkan jumlah notifikasi belum dibaca
//   Future<int> getUnreadNotificationCount() async {
//     try {
//       final snapshot = await _db
//           .collection('notifications')
//           .where('isRead', isEqualTo: false)
//           .get();
      
//       return snapshot.docs.length;
//     } catch (e) {
//       print('❌ Error getting unread notification count: $e');
//       return 0;
//     }
//   }

//   // Stream untuk mendapatkan jumlah notifikasi belum dibaca
//   Stream<int> getUnreadNotificationCountStream() {
//     return _db
//         .collection('notifications')
//         .where('isRead', isEqualTo: false)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.length);
//   }

//   // Method untuk mendapatkan notifikasi berdasarkan tipe
//   Stream<List<NotificationModel>> getNotificationsByType(String type) {
//     return _db
//         .collection('notifications')
//         .where('type', isEqualTo: type)
//         .orderBy('waktu', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) {
//             try {
//               return NotificationModel.fromFirestore(doc);
//             } catch (e) {
//               print('Error parsing notification ${doc.id}: $e');
//               return null;
//             }
//           }).where((notif) => notif != null).cast<NotificationModel>().toList();
//         });
//   }

//   // Method untuk menghapus notifikasi tertentu
//   Future<void> deleteNotification(String notificationId) async {
//     try {
//       await _db.collection('notifications').doc(notificationId).delete();
//       print('✅ Notification deleted: $notificationId');
//     } catch (e) {
//       print('❌ Error deleting notification: $e');
//       throw Exception('Error deleting notification: $e');
//     }
//   }

//   // Method untuk mendapatkan notifikasi terbaru (24 jam terakhir)
//   Stream<List<NotificationModel>> getRecentNotifications() {
//     final yesterday = DateTime.now().subtract(const Duration(days: 1));
    
//     return _db
//         .collection('notifications')
//         .where('waktu', isGreaterThan: Timestamp.fromDate(yesterday))
//         .orderBy('waktu', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) {
//             try {
//               return NotificationModel.fromFirestore(doc);
//             } catch (e) {
//               print('Error parsing notification ${doc.id}: $e');
//               return null;
//             }
//           }).where((notif) => notif != null).cast<NotificationModel>().toList();
//         });
//   }

//   // Method untuk mendapatkan notifikasi kritis
//   Stream<List<NotificationModel>> getCriticalNotifications() {
//     return _db
//         .collection('notifications')
//         .where('type', whereIn: ['suhu_alert', 'health'])
//         .orderBy('waktu', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) {
//             try {
//               return NotificationModel.fromFirestore(doc);
//             } catch (e) {
//               print('Error parsing notification ${doc.id}: $e');
//               return null;
//             }
//           }).where((notif) => notif != null).cast<NotificationModel>().toList();
//         });
//   }

//   // Method helper untuk mendapatkan current user
//   User? getCurrentUser() {
//     return _auth.currentUser;
//   }

//   // Method untuk logout (opsional)
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }

//   // Method untuk mengecek apakah user sudah login
//   bool get isUserLoggedIn => _auth.currentUser != null;

//   // Stream untuk mendengarkan perubahan authentication state
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/models/notifikasi_model.dart';
import 'package:healthyguppy/models/suhu_model.dart';
import 'package:healthyguppy/models/hama_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method untuk mendapatkan current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // --- SUHU MONITORING ---
  static const String _collectionName = 'Monitoring';
  static const String _documentId = 'QiTZ7CtUxanTTlefUyOF';

  Stream<SuhuData> getSuhuStream() {
    return _db
        .collection(_collectionName)
        .doc(_documentId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data()!;
            return SuhuData.fromFirestore(data);
          } else {
            throw Exception('Document tidak ditemukan');
          }
        });
  }

  Future<SuhuData?> getCurrentSuhu() async {
    try {
      DocumentSnapshot snapshot =
          await _db.collection(_collectionName).doc(_documentId).get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        return SuhuData.fromFirestore(data);
      }
      
      return null;
    } catch (e) {
      throw Exception('Error mengambil data: $e');
    }
  }

  // --- HAMA MONITORING ---
  Stream<HamaData> getHamaStream() {
    return _db
        .collection(_collectionName)
        .doc(_documentId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data()!;
            return HamaData.fromFirestore(data);
          } else {
            // Return default "tidak ada hama" jika document tidak ada
            return HamaData(
              nama: 'Tidak ada nama',
              status: 'Tidak ada hama',
              timestamp: DateTime.now(),
            );
          }
        });
  }

  Future<HamaData?> getCurrentHama() async {
    try {
      DocumentSnapshot snapshot =
          await _db.collection(_collectionName).doc(_documentId).get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        return HamaData.fromFirestore(data);
      }
      
      // Return default jika tidak ada data
      return HamaData(
        nama: 'Tidak ada nama',
        status: 'Tidak ada hama',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error mengambil data hama: $e');
    }
  }

  // Method untuk update status hama (jika diperlukan dari aplikasi)
  Future<void> updateHamaStatus(String status) async {
    try {
      await _db.collection(_collectionName).doc(_documentId).update({
        'nama': 'Monitoring Hama',
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Hama status updated: $status');
    } catch (e) {
      print('❌ Error updating hama status: $e');
      throw Exception('Error updating hama status: $e');
    }
  }

  // Method untuk menambahkan notifikasi hama
  Future<void> addHamaNotification(HamaData hamaData) async {
    if (!hamaData.shouldNotify()) return;

    try {
      final notification = NotificationModel(
        judul: hamaData.getNotificationTitle(),
        isi: hamaData.getNotificationBody(),
        type: 'hama_alert',
        waktu: DateTime.now(),
        extraData: {
          'hamaStatus': hamaData.status,
          'severity': hamaData.getSeverityLevel(),
          'priority': hamaData.getPriority(),
          'color': hamaData.getStatusColor(),
          'icon': hamaData.getStatusIcon(),
          'timestamp': hamaData.timestamp.toIso8601String(),
        }, id: '',
      );

      await addNotification(notification);
      print('✅ Hama notification added: ${hamaData.status}');
    } catch (e) {
      print('❌ Error adding hama notification: $e');
      throw Exception('Error adding hama notification: $e');
    }
  }

  // --- JADWAL ---
  Future<void> addJadwal(JadwalModel jadwal) async {
    if (_currentUserId == null) {
      throw Exception('User belum login');
    }

    await _db.collection('jadwal').add({
      'jam': jadwal.jam,
      'menit': jadwal.menit,
      'hari': jadwal.hari,
      'isActive': jadwal.isActive,
      'userId': _currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateJadwal(String id, JadwalModel jadwal) async {
    if (_currentUserId == null) {
      throw Exception('User belum login');
    }

    final doc = await _db.collection('jadwal').doc(id).get();
    if (!doc.exists || doc.data()?['userId'] != _currentUserId) {
      throw Exception('Jadwal tidak ditemukan atau bukan milik Anda');
    }

    await _db.collection('jadwal').doc(id).update({
      'jam': jadwal.jam,
      'menit': jadwal.menit,
      'hari': jadwal.hari,
      'isActive': jadwal.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteJadwal(String id) async {
    if (_currentUserId == null) {
      throw Exception('User belum login');
    }

    final doc = await _db.collection('jadwal').doc(id).get();
    if (!doc.exists || doc.data()?['userId'] != _currentUserId) {
      throw Exception('Jadwal tidak ditemukan atau bukan milik Anda');
    }

    await _db.collection('jadwal').doc(id).delete();
  }

  Stream<List<JadwalModel>> getJadwal() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('jadwal')
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return JadwalModel(
              id: doc.id,
              jam: data['jam'],
              menit: data['menit'],
              hari: List<String>.from(data['hari']),
              isActive: data['isActive'] ?? false,
            );
          }).toList();
        });
  }

  // --- NOTIFIKASI ---
  Future<void> addNotification(NotificationModel notif) async {
    try {
      await _db.collection('notifications').add({
        'judul': notif.judul,
        'isi': notif.isi,
        'type': notif.type,
        'waktu': FieldValue.serverTimestamp(),
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
        'notificationId': notif.notificationId,
        ...?notif.extraData,
      });
      print('✅ Notification added to Firestore: ${notif.judul}');
    } catch (e) {
      print('❌ Error adding notification to Firestore: $e');
      throw Exception('Error adding notification: $e');
    }
  }

  Stream<List<NotificationModel>> getNotifications() {
    return _db
        .collection('notifications')
        .orderBy('waktu', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return NotificationModel.fromFirestore(doc);
            } catch (e) {
              print('Error parsing notification ${doc.id}: $e');
              return null;
            }
          }).where((notif) => notif != null).cast<NotificationModel>().toList();
        });
  }

  // Method untuk mendapatkan jadwal aktif dan mengkonversi ke NotificationModel
  Future<List<NotificationModel>> getActiveSchedules() async {
    if (_currentUserId == null) {
      return [];
    }

    final snapshot = await _db
        .collection('jadwal')
        .where('userId', isEqualTo: _currentUserId)
        .where('isActive', isEqualTo: true)
        .get();

    final now = DateTime.now();
    final today = now.weekday;
    List<NotificationModel> scheduledNotifs = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final hariList = List<String>.from(data['hari'] ?? []);
      if (hariList.contains(_getHariFromInt(today))) {
        final jam = data['jam'] ?? 0;
        final menit = data['menit'] ?? 0;
        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          jam,
          menit,
        );

        if (scheduledTime.isAfter(now)) {
          final timeString = '${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')}';
          scheduledNotifs.add(
            NotificationModel(
              id: doc.id,
              judul: 'Pengingat Jadwal',
              isi: 'Saatnya memberikan makan ikan pada jam $timeString',
              type: 'jadwal',
              waktu: scheduledTime,
              extraData: {
                'jadwalId': doc.id,
                'scheduledTime': timeString,
                'hari': hariList,
              },
            ),
          );
        }
      }
    }
    return scheduledNotifs;
  }

  String _getHariFromInt(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[weekday - 1];
  }

  String getDayName(int weekday) {
    return _getHariFromInt(weekday);
  }

  int getWeekdayFromName(String dayName) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final index = days.indexOf(dayName);
    return index == -1 ? 1 : index + 1;
  }

  Future<void> deleteOldNotifications() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      final snapshot = await _db
          .collection('notifications')
          .where('waktu', isLessThan: Timestamp.fromDate(sevenDaysAgo))
          .get();

      if (snapshot.docs.isNotEmpty) {
        final batch = _db.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('✅ Deleted ${snapshot.docs.length} old notifications');
      }
    } catch (e) {
      print('❌ Error deleting old notifications: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final snapshot = await _db.collection('notifications').get();

      if (snapshot.docs.isNotEmpty) {
        final batch = _db.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('✅ Cleared all notifications (${snapshot.docs.length} items)');
      }
    } catch (e) {
      print('❌ Error clearing notifications: $e');
      throw Exception('Error clearing notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      print('✅ Notification marked as read: $notificationId');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      throw Exception('Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final snapshot = await _db
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final batch = _db.batch();
        for (var doc in snapshot.docs) {
          batch.update(doc.reference, {
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        print('✅ Marked ${snapshot.docs.length} notifications as read');
      }
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final snapshot = await _db
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting unread notification count: $e');
      return 0;
    }
  }

  Stream<int> getUnreadNotificationCountStream() {
    return _db
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<List<NotificationModel>> getNotificationsByType(String type) {
    return _db
        .collection('notifications')
        .where('type', isEqualTo: type)
        .orderBy('waktu', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return NotificationModel.fromFirestore(doc);
            } catch (e) {
              print('Error parsing notification ${doc.id}: $e');
              return null;
            }
          }).where((notif) => notif != null).cast<NotificationModel>().toList();
        });
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).delete();
      print('✅ Notification deleted: $notificationId');
    } catch (e) {
      print('❌ Error deleting notification: $e');
      throw Exception('Error deleting notification: $e');
    }
  }

  Stream<List<NotificationModel>> getRecentNotifications() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    
    return _db
        .collection('notifications')
        .where('waktu', isGreaterThan: Timestamp.fromDate(yesterday))
        .orderBy('waktu', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return NotificationModel.fromFirestore(doc);
            } catch (e) {
              print('Error parsing notification ${doc.id}: $e');
              return null;
            }
          }).where((notif) => notif != null).cast<NotificationModel>().toList();
        });
  }

  Stream<List<NotificationModel>> getCriticalNotifications() {
    return _db
        .collection('notifications')
        .where('type', whereIn: ['suhu_alert', 'health', 'hama_alert'])
        .orderBy('waktu', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return NotificationModel.fromFirestore(doc);
            } catch (e) {
              print('Error parsing notification ${doc.id}: $e');
              return null;
            }
          }).where((notif) => notif != null).cast<NotificationModel>().toList();
        });
  }

  // Method untuk mendapatkan notifikasi hama
  Stream<List<NotificationModel>> getHamaNotifications() {
    return getNotificationsByType('hama_alert');
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool get isUserLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}