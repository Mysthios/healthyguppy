import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthyguppy/models/notifikasi_model.dart';
import 'package:healthyguppy/services/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final notifikasiListProvider = StreamProvider<List<NotifikasiModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);

  // Panggil auto-delete dulu setiap kali stream aktif
  firebaseService.deleteOldNotifications();

  // Dapatkan current user ID
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  
  if (currentUserId == null) {
    // Jika user belum login, return stream kosong
    return Stream.value(<NotifikasiModel>[]);
  }

  return FirebaseFirestore.instance
      .collection('notifikasi')
      .where('userId', isEqualTo: currentUserId) // Filter berdasarkan userId
      .orderBy('waktu', descending: true) // Urutkan berdasarkan waktu terbaru
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return NotifikasiModel.fromMap(data);
        }).toList();
      });
});