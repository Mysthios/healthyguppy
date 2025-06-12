import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/models/pakan_model.dart'; // Import ActionModel, bukan pakan_model

final actionProvider = StateNotifierProvider<ActionNotifier, ActionModel?>((ref) {
  return ActionNotifier();
});

class ActionNotifier extends StateNotifier<ActionModel?> {
  static const String ACTION_DOC_ID = 'qrPLUhAZbg2oUnAyoYtm';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ActionNotifier() : super(null) {
    // Load initial state saat provider dibuat
    _loadCurrentState();
  }

  // Load state saat ini dari Firebase
  Future<void> _loadCurrentState() async {
    try {
      final doc = await _firestore.collection('Action').doc(ACTION_DOC_ID).get();
      
      if (doc.exists) {
        state = ActionModel.fromFirestore(doc);
        print('✅ ActionProvider: Loaded current state - ${state?.pakan}');
      } else {
        print('⚠️ ActionProvider: Document tidak ditemukan');
      }
    } catch (e) {
      print('❌ ActionProvider: Error loading state - $e');
    }
  }

  // Buka pakan
  Future<void> bukaPakan() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      
      if (currentUserId == null) {
        print('❌ ActionProvider: User tidak login');
        return;
      }

      print('🔓 ActionProvider: Membuka pakan...');

      // Update state lokal terlebih dahulu
      state = ActionModel(
        id: ACTION_DOC_ID,
        pakan: 'buka',
      );

      // Update Firebase
      await _firestore.collection('Action').doc(ACTION_DOC_ID).update({
        'pakan': 'buka',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': currentUserId,
      });

      print('✅ ActionProvider: Pakan berhasil dibuka');
    } catch (e) {
      print('❌ ActionProvider: Error membuka pakan - $e');
      // Rollback state jika gagal
      await _loadCurrentState();
    }
  }

  // Tutup pakan
  Future<void> tutupPakan() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      
      if (currentUserId == null) {
        print('❌ ActionProvider: User tidak login');
        return;
      }

      print('🔒 ActionProvider: Menutup pakan...');

      // Update state lokal terlebih dahulu
      state = ActionModel(
        id: ACTION_DOC_ID,
        pakan: 'tutup',
      );

      // Update Firebase
      await _firestore.collection('Action').doc(ACTION_DOC_ID).update({
        'pakan': 'tutup',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': currentUserId,
      });

      print('✅ ActionProvider: Pakan berhasil ditutup');
    } catch (e) {
      print('❌ ActionProvider: Error menutup pakan - $e');
      // Rollback state jika gagal
      await _loadCurrentState();
    }
  }

  // Method untuk refresh state dari Firebase
  Future<void> refreshState() async {
    await _loadCurrentState();
  }

  // Getter untuk status pakan
  bool get isPakanBuka => state?.isPakanBuka ?? false;
  bool get isPakanTutup => state?.isPakanTutup ?? true;
  String get statusPakan => state?.pakan ?? 'tutup';

  // Method untuk listen real-time changes (opsional)
  Stream<ActionModel?> listenToActionChanges() {
    return _firestore
        .collection('Action')
        .doc(ACTION_DOC_ID)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final actionModel = ActionModel.fromFirestore(doc);
        // Update state saat ada perubahan dari Firebase
        state = actionModel;
        return actionModel;
      }
      return null;
    });
  }

  // Method untuk manual trigger (untuk testing)
  Future<void> togglePakan() async {
    if (isPakanBuka) {
      await tutupPakan();
    } else {
      await bukaPakan();
    }
  }

  // Method untuk reset ke state default
  Future<void> resetToDefault() async {
    await tutupPakan(); // Default adalah tutup
  }
}