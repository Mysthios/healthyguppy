import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthyguppy/models/notifikasi_model.dart';
import 'package:healthyguppy/services/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final notifikasiListProvider = StreamProvider<List<NotifikasiModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);

  // Panggil auto-delete dulu setiap kali stream aktif
  firebaseService.deleteOldNotifications();

  return FirebaseFirestore.instance
      .collection('notifikasi')
      .orderBy('waktu', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return NotifikasiModel.fromMap(data);
        }).toList();
      });
});
