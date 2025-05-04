import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/models/jadwal_model.dart';

class JadwalNotifier extends StateNotifier<List<JadwalModel>> {
  JadwalNotifier() : super([]);

  void tambahJadwal(JadwalModel jadwal) {
    state = [...state, jadwal];
  }

  void updateJadwal(int index, JadwalModel newJadwal) {
    final updatedList = [...state];
    updatedList[index] = newJadwal;
    state = updatedList;
  }

  void hapusJadwal(int index) {
    final updatedList = [...state]..removeAt(index);
    state = updatedList;
  }
}

final jadwalListProvider = StateNotifierProvider<JadwalNotifier, List<JadwalModel>>(
  (ref) => JadwalNotifier(),
);
