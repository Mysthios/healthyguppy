import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notifikasi_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addNotification(NotifikasiModel notif) async {
    await _db.collection('notifications').add(notif.toJson());
  }

  Stream<List<NotifikasiModel>> getNotifications() {
    return _db.collection('notifications')
      .orderBy('waktu')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) =>
          NotifikasiModel.fromJson(doc.data())).toList());
  }

  Future<void> deleteOldNotifications(Duration maxAge) async {
    final now = DateTime.now();
    final cutoff = now.subtract(maxAge);
    final snapshot = await _db
        .collection('notifications')
        .where('waktu', isLessThan: cutoff.toIso8601String())
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
