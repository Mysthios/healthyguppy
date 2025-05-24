import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/services/firebase_service.dart';

class JadwalNotifier extends StateNotifier<List<JadwalModel>> {
  final FirebaseService _firebaseService;

  JadwalNotifier(this._firebaseService) : super([]) {
    _loadJadwal();
  }

  void _loadJadwal() {
    _firebaseService.getJadwal().listen((jadwalList) {
      state = jadwalList;
    });
  }

  Future<void> tambahJadwal(JadwalModel jadwal) async {
    await _firebaseService.addJadwal(jadwal);
  }

  Future<void> updateJadwal(String id, JadwalModel newJadwal) async {
    await _firebaseService.updateJadwal(id, newJadwal);
    state = [
    for (final jadwal in state)
      if (jadwal.id == id) newJadwal else jadwal
  ];
  }

  Future<void> hapusJadwal(String id) async {
    await _firebaseService.deleteJadwal(id);
  }

  Future<void> toggleAktif(String id, bool statusBaru) async {
  await _firebaseService.updateJadwal(id, JadwalModel(
    id: id,
    jam: state.firstWhere((j) => j.id == id).jam,
    menit: state.firstWhere((j) => j.id == id).menit,
    hari: state.firstWhere((j) => j.id == id).hari,
    isActive: statusBaru,
  ));
}
}

final firebaseServiceProvider = Provider<FirebaseService>(
  (ref) => FirebaseService(),
);
final jadwalListProvider =
    StateNotifierProvider<JadwalNotifier, List<JadwalModel>>(
      (ref) => JadwalNotifier(ref.read(firebaseServiceProvider)),
    );
