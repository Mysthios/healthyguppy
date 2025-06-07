import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/services/firebase_service.dart';

// Import authStateProvider dari auth wrapper atau buat provider terpisah
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class JadwalNotifier extends StateNotifier<List<JadwalModel>> {
  final FirebaseService _firebaseService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  JadwalNotifier(this._firebaseService) : super([]) {
    _loadJadwal();
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User logged out, clear jadwal
        state = [];
      } else {
        // User logged in, reload jadwal
        _loadJadwal();
      }
    });
  }

  void _loadJadwal() {
    // Hanya load jadwal jika user sudah login
    if (_auth.currentUser != null) {
      _firebaseService.getJadwal().listen(
        (jadwalList) {
          state = jadwalList;
        },
        onError: (error) {
          print('Error loading jadwal: $error');
          state = [];
        },
      );
    } else {
      state = [];
    }
  }

  Future<void> tambahJadwal(JadwalModel jadwal) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('Anda harus login terlebih dahulu');
      }
      await _firebaseService.addJadwal(jadwal);
    } catch (e) {
      print('Error adding jadwal: $e');
      rethrow;
    }
  }

  Future<void> updateJadwal(String id, JadwalModel newJadwal) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('Anda harus login terlebih dahulu');
      }
      
      await _firebaseService.updateJadwal(id, newJadwal);
      
      // Update state lokal - membuat objek baru dengan id yang benar
      state = [
        for (final jadwal in state)
          if (jadwal.id == id) 
            JadwalModel(
              id: id,
              jam: newJadwal.jam,
              menit: newJadwal.menit,
              hari: newJadwal.hari,
              isActive: newJadwal.isActive,
            )
          else jadwal
      ];
    } catch (e) {
      print('Error updating jadwal: $e');
      rethrow;
    }
  }

  Future<void> hapusJadwal(String id) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('Anda harus login terlebih dahulu');
      }
      
      await _firebaseService.deleteJadwal(id);
    } catch (e) {
      print('Error deleting jadwal: $e');
      rethrow;
    }
  }

  Future<void> toggleAktif(String id, bool statusBaru) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('Anda harus login terlebih dahulu');
      }

      final jadwalLama = state.firstWhere((j) => j.id == id);
      final jadwalBaru = JadwalModel(
        id: id,
        jam: jadwalLama.jam,
        menit: jadwalLama.menit,
        hari: jadwalLama.hari,
        isActive: statusBaru,
      );

      await _firebaseService.updateJadwal(id, jadwalBaru);
      
      // Update state lokal
      state = [
        for (final jadwal in state)
          if (jadwal.id == id) jadwalBaru else jadwal
      ];
    } catch (e) {
      print('Error toggling jadwal: $e');
      rethrow;
    }
  }

  // Method untuk refresh jadwal
  void refreshJadwal() {
    _loadJadwal();
  }

  // Method untuk clear jadwal ketika logout
  void clearJadwal() {
    state = [];
  }
}

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

final firebaseServiceProvider = Provider<FirebaseService>(
  (ref) => FirebaseService(),
);

final jadwalListProvider =
    StateNotifierProvider<JadwalNotifier, List<JadwalModel>>(
  (ref) => JadwalNotifier(ref.read(firebaseServiceProvider)),
);

// Provider untuk cek apakah user sudah login
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});