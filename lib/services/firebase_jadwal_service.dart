import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jadwal_model.dart';

class FirebaseJadwalService {
  final _collection = FirebaseFirestore.instance.collection('jadwal');

  Future<void> addJadwal(JadwalModel jadwal) async {
    await _collection.add(jadwal.toMap());
  }

  Future<void> updateJadwal(JadwalModel jadwal) async {
    if (jadwal.id != null) {
      await _collection.doc(jadwal.id).update(jadwal.toMap());
    }
  }

  Future<void> deleteJadwal(String id) async {
    await _collection.doc(id).delete();
  }

  Stream<List<JadwalModel>> getJadwalStream() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return JadwalModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
