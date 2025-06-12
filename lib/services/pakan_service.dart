import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IoTActionService {
  static const String ACTION_DOC_ID = 'qrPLUhAZbg2oUnAyoYtm';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Buka servo untuk durasi tertentu
  static Future<void> triggerPakanSequence({
    int durasiDetik = 3, // durasi servo terbuka
  }) async {
    try {
      print('🤖 IoT: Memulai sequence pakan...');
      print('⏱️ IoT: Durasi servo terbuka: ${durasiDetik}s');
      
      // 1. Buka servo
      await _updateActionStatus('buka');
      print('🔓 IoT: Servo pakan dibuka');
      
      // 2. Tunggu sesuai durasi
      await Future.delayed(Duration(seconds: durasiDetik));
      print('⏳ IoT: Menunggu ${durasiDetik} detik...');
      
      // 3. Tutup servo
      await _updateActionStatus('tutup');
      print('🔒 IoT: Servo pakan ditutup kembali');
      
      print('✅ IoT: Sequence pakan selesai');
      
    } catch (e) {
      print('❌ IoT: Error sequence pakan - $e');
      // Pastikan servo ditutup meskipun error
      try {
        await _updateActionStatus('tutup');
        print('🔒 IoT: Servo dipaksa tutup karena error');
      } catch (closeError) {
        print('❌ IoT: Gagal menutup servo - $closeError');
      }
      rethrow; // Re-throw error untuk handling di level atas
    }
  }

  // Update status action ke Firebase
  static Future<void> _updateActionStatus(String status) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      
      final updateData = {
        'pakan': status,
        'timestamp': FieldValue.serverTimestamp(),
      };
      
      // Tambahkan userId jika user sedang login
      if (currentUserId != null) {
        updateData['userId'] = currentUserId;
      }
      
      await _firestore
          .collection('Action')
          .doc(ACTION_DOC_ID)
          .update(updateData);
          
      print('📝 IoT: Status updated to "$status"');
    } catch (e) {
      print('❌ IoT: Error updating status to "$status" - $e');
      throw e;
    }
  }

  // Method untuk mengecek status saat ini
  static Future<String> getCurrentStatus() async {
    try {
      final doc = await _firestore
          .collection('Action')
          .doc(ACTION_DOC_ID)
          .get();
      
      if (doc.exists) {
        final status = doc.data()?['pakan'] ?? 'tutup';
        print('📊 IoT: Current status - $status');
        return status;
      } else {
        print('⚠️ IoT: Action document tidak ditemukan, default ke "tutup"');
        return 'tutup';
      }
    } catch (e) {
      print('❌ IoT: Error getting current status - $e');
      return 'tutup'; // Default ke tutup jika error
    }
  }

  // Method untuk force buka pakan (manual trigger)
  static Future<void> bukaPakan() async {
    try {
      await _updateActionStatus('buka');
      print('🔓 IoT: Pakan dibuka secara manual');
    } catch (e) {
      print('❌ IoT: Error membuka pakan manual - $e');
      rethrow;
    }
  }

  // Method untuk force tutup pakan (manual trigger)
  static Future<void> tutupPakan() async {
    try {
      await _updateActionStatus('tutup');
      print('🔒 IoT: Pakan ditutup secara manual');
    } catch (e) {
      print('❌ IoT: Error menutup pakan manual - $e');
      rethrow;
    }
  }

  // Method untuk emergency stop (paksa tutup)
  static Future<void> emergencyStop() async {
    try {
      print('🚨 IoT: EMERGENCY STOP - Menutup servo paksa');
      await _updateActionStatus('tutup');
      print('✅ IoT: Emergency stop berhasil');
    } catch (e) {
      print('❌ IoT: Error emergency stop - $e');
      // Jangan throw error di emergency stop
    }
  }

  // Method untuk cek apakah servo sedang buka
  static Future<bool> isServoOpen() async {
    final status = await getCurrentStatus();
    return status == 'buka';
  }

  // Method untuk cek apakah servo sedang tutup
  static Future<bool> isServoClosed() async {
    final status = await getCurrentStatus();
    return status == 'tutup';
  }

  // Method untuk get status dengan timestamp
  static Future<Map<String, dynamic>> getStatusWithTimestamp() async {
    try {
      final doc = await _firestore
          .collection('Action')
          .doc(ACTION_DOC_ID)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'status': data['pakan'] ?? 'tutup',
          'timestamp': data['timestamp'],
          'userId': data['userId'],
        };
      } else {
        return {
          'status': 'tutup',
          'timestamp': null,
          'userId': null,
        };
      }
    } catch (e) {
      print('❌ IoT: Error getting status with timestamp - $e');
      return {
        'status': 'tutup',
        'timestamp': null,
        'userId': null,
      };
    }
  }

  // Method untuk testing connectivity
  static Future<bool> testConnection() async {
    try {
      print('🧪 IoT: Testing Firebase connection...');
      await _firestore.collection('Action').doc(ACTION_DOC_ID).get();
      print('✅ IoT: Connection test successful');
      return true;
    } catch (e) {
      print('❌ IoT: Connection test failed - $e');
      return false;
    }
  }
}