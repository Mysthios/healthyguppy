// riverpod_provider.dart - Fixed Version
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider untuk sisa pakan dengan persistence
final sisaPakanProvider = StateNotifierProvider<SisaPakanNotifier, int>(
  (ref) => SisaPakanNotifier(),
);

// StateNotifier untuk mengelola sisa pakan dengan fitur persistence
class SisaPakanNotifier extends StateNotifier<int> {
  static const String _key = 'sisa_pakan';
  static const int _maxPakan = 130;
  static const int _minPakan = 0;

  SisaPakanNotifier() : super(_maxPakan) {
    _loadFromPrefs();
  }

  // Load nilai dari SharedPreferences saat initialization
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getInt(_key) ?? _maxPakan;
      state = savedValue;
      print('🍽️ Loaded sisa pakan from storage: $savedValue');
    } catch (e) {
      print('❌ Error loading sisa pakan: $e');
      state = _maxPakan;
    }
  }

  // Save nilai ke SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, state);
      print('💾 Saved sisa pakan to storage: $state');
    } catch (e) {
      print('❌ Error saving sisa pakan: $e');
    }
  }

  // Method untuk mengurangi pakan (dipanggil saat notifikasi muncul)
  Future<void> kurangiPakan({int jumlah = 1}) async {
    if (state > _minPakan) {
      final newValue = (state - jumlah).clamp(_minPakan, _maxPakan);
      state = newValue;
      await _saveToPrefs();
      
      print('🍽️ Pakan berkurang: $jumlah, Sisa: $state');
      
      // Cek jika pakan habis
      if (state == _minPakan) {
        print('⚠️ WARNING: Pakan habis! Sisa: $state');
      } else if (state <= 10) {
        print('⚠️ WARNING: Pakan hampir habis! Sisa: $state');
      }
    } else {
      print('❌ Pakan sudah habis, tidak bisa dikurangi lagi');
    }
  }

  // Method untuk reset pakan ke nilai maksimum
  Future<void> resetPakan() async {
    state = _maxPakan;
    await _saveToPrefs();
    print('🔄 Pakan di-reset ke: $state');
  }

  // Method untuk set pakan ke nilai tertentu
  Future<void> setPakan(int value) async {
    final newValue = value.clamp(_minPakan, _maxPakan);
    state = newValue;
    await _saveToPrefs();
    print('🎯 Pakan di-set ke: $state');
  }

  // Method untuk menambah pakan (untuk isi ulang) - FIXED METHOD NAME
  Future<void> isiPakan(int jumlah) async {
    if (state < _maxPakan) {
      final newValue = (state + jumlah).clamp(_minPakan, _maxPakan);
      state = newValue;
      await _saveToPrefs();
      print('➕ Pakan ditambah: $jumlah, Total: $state');
    } else {
      print('⚠️ Pakan sudah penuh!');
    }
  }

  // Alternative method name for adding pakan
  Future<void> tambahPakan({int jumlah = 1}) async {
    await isiPakan(jumlah);
  }

  // Getter untuk mengakses kapasitas maksimal
  int get kapasitasMaksimal => _maxPakan;
  int get kapasitasMinimal => _minPakan;

  // Getter untuk status pakan
  bool get isPakanHabis => state == _minPakan;
  bool get isPakanHampirHabis => state <= 10;
  bool get isPakanPenuh => state == _maxPakan;
  double get persentasePakan => (state / _maxPakan) * 100;

  // Getter untuk informasi pakan
  String get statusPakan {
    if (isPakanHabis) return 'Habis';
    if (isPakanHampirHabis) return 'Hampir Habis';
    if (isPakanPenuh) return 'Penuh';
    return 'Tersedia';
  }

  // Getter untuk warna status
  String get warnaStatus {
    if (isPakanHabis) return 'red';
    if (isPakanHampirHabis) return 'orange';
    if (state <= 70) return 'yellow';
    return 'green';
  }
}