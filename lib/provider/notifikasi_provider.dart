// provider/notifikasi_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthyguppy/models/notifikasi_model.dart';

final notifikasiListProvider = StreamProvider<List<NotifikasiModel>>((ref) {
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
