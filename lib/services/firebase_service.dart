import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/models/notifikasi_model.dart'; // pastikan file ini ada dan benar

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- JADWAL ---
  Future<void> addJadwal(JadwalModel jadwal) async {
    await _db.collection('jadwal').add({
      'jam': jadwal.jam,
      'menit': jadwal.menit,
      'hari': jadwal.hari,
      'isActive': jadwal.isActive,
    });
  }

  Future<void> updateJadwal(String id, JadwalModel jadwal) async {
    await _db.collection('jadwal').doc(id).update({
      'jam': jadwal.jam,
      'menit': jadwal.menit,
      'hari': jadwal.hari,
      'isActive': jadwal.isActive,
    });
  }

  Future<void> deleteJadwal(String id) async {
    await _db.collection('jadwal').doc(id).delete();
  }

  Stream<List<JadwalModel>> getJadwal() {
    return _db.collection('jadwal').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return JadwalModel(
          id: doc.id, // <--- penting ini!
          jam: data['jam'],
          menit: data['menit'],
          hari: List<String>.from(data['hari']),
        );
      }).toList();
    });
  }

  // --- NOTIFIKASI ---
  Future<void> addNotification(NotifikasiModel notif) async {
    await _db.collection('notifikasi').add(notif.toMap());
  }

  Stream<List<NotifikasiModel>> getNotifications() {
    return _db.collection('notifikasi').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotifikasiModel.fromMap(doc.data());
      }).toList();
    });
  }

  //----------------------------------
  Future<List<NotifikasiModel>> getActiveSchedules() async {
    final snapshot = await _db.collection('jadwal').get();
    final now = DateTime.now();
    final today = now.weekday;

    List<NotifikasiModel> scheduledNotifs = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['isActive'] == true) {
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
  final now = DateTime.now();
  final twoDaysAgo = now.subtract(const Duration(days: 2));
  final snapshot = await _db
      .collection('notifikasi')
      .where('waktu', isLessThan: twoDaysAgo)
      .get();
  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }
}

}
