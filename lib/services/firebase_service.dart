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
    });
  }

  Future<void> updateJadwal(String id, JadwalModel jadwal) async {
    await _db.collection('jadwal').doc(id).update({
      'jam': jadwal.jam,
      'menit': jadwal.menit,
      'hari': jadwal.hari,
    });
  }

  Stream<List<JadwalModel>> getJadwal() {
    return _db.collection('jadwal').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return JadwalModel(
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
}
