import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthyguppy/models/notifikasi_model.dart';
import 'package:healthyguppy/services/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());
final notifikasiListProvider = StreamProvider<List<NotifikasiModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  
  if (currentUserId == null) {
    return Stream.value(<NotifikasiModel>[]);
  }

  try {
    // Auto-delete old notifications
    firebaseService.deleteOldNotifications().catchError((e) {
      print('Error deleting old notifications: $e');
    });

    return FirebaseFirestore.instance
        .collection('notifikasi')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('waktu', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              return NotifikasiModel.fromMap(data);
            } catch (e) {
              print('Error parsing notification: $e');
              return null;
            }
          }).where((notif) => notif != null).cast<NotifikasiModel>().toList();
        });
  } catch (e) {
    print('Error in notifikasiListProvider: $e');
    return Stream.value(<NotifikasiModel>[]);
  }
});