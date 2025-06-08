import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/models/notifikasi_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method untuk mendapatkan current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // --- JADWAL (Updated dengan User ID) ---
  Future<void> addJadwal(JadwalModel jadwal) async {
    if (_currentUserId == null) {
      throw Exception('User belum login');
    }
    
    await _db.collection('jadwal').add({
      'jam': jadwal.jam,
      'menit': jadwal.menit,
      'hari': jadwal.hari,
      'isActive': jadwal.isActive,
      'userId': _currentUserId, // Tambahkan userId
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateJadwal(String id, JadwalModel jadwal) async {
    if (_currentUserId == null) {
      throw Exception('User belum login');
    }

    // Verifikasi bahwa jadwal ini milik user yang sedang login
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

    // Verifikasi bahwa jadwal ini milik user yang sedang login
    final doc = await _db.collection('jadwal').doc(id).get();
    if (!doc.exists || doc.data()?['userId'] != _currentUserId) {
      throw Exception('Jadwal tidak ditemukan atau bukan milik Anda');
    }

    await _db.collection('jadwal').doc(id).delete();
  }

  // Stream jadwal hanya untuk user yang sedang login
  Stream<List<JadwalModel>> getJadwal() {
    if (_currentUserId == null) {
      return Stream.value([]); // Return empty list jika belum login
    }

    return _db
        .collection('jadwal')
        .where('userId', isEqualTo: _currentUserId) // Filter berdasarkan userId
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

  // --- NOTIFIKASI (Updated dengan User ID) ---
  Future<void> addNotification(NotifikasiModel notif) async {
    if (_currentUserId == null) {
      throw Exception('User belum login');
    }

    await _db.collection('notifikasi').add({
      ...notif.toMap(),
      'userId': _currentUserId, // Tambahkan userId
      'waktu': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<NotifikasiModel>> getNotifications() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('notifikasi')
        .where('userId', isEqualTo: _currentUserId) // Filter berdasarkan userId
        .orderBy('waktu', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotifikasiModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Get active schedules untuk user yang sedang login
  Future<List<NotifikasiModel>> getActiveSchedules() async {
    if (_currentUserId == null) {
      return [];
    }

    final snapshot = await _db
        .collection('jadwal')
        .where('userId', isEqualTo: _currentUserId) // Filter berdasarkan userId
        .where('isActive', isEqualTo: true)
        .get();

    final now = DateTime.now();
    final today = now.weekday;
    List<NotifikasiModel> scheduledNotifs = [];

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
          scheduledNotifs.add(
            NotifikasiModel(
              judul: 'Pengingat Jadwal',
              isi: 'Jadwal hari ini jam $jam:$menit',
              waktu: scheduledTime,
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

  Future<void> deleteOldNotifications() async {
    if (_currentUserId == null) return;

    final now = DateTime.now();
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final snapshot = await _db
        .collection('notifikasi')
        .where('userId', isEqualTo: _currentUserId) // Filter berdasarkan userId
        .where('waktu', isLessThan: twoDaysAgo)
        .get();
    
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Method untuk membersihkan semua data user ketika logout
  Future<void> clearUserData() async {
    // Method ini bisa dipanggil saat logout jika diperlukan
    // Untuk sementara hanya untuk keperluan development
  }

  Future<void> clearAllNotifications() async {
  if (_currentUserId == null) return;
  
  try {
    final snapshot = await _db
        .collection('notifikasi')
        .where('userId', isEqualTo: _currentUserId)
        .get();
    
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  } catch (e) {
    print('Error clearing notifications: $e');
    rethrow;
  }
}
}