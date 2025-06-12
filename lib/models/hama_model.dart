import 'package:cloud_firestore/cloud_firestore.dart';

class HamaData {
  final String nama;
  final String status; // "Tidak ada hama" atau "Hama Terdeteksi"
  final DateTime timestamp;
  final Map<String, dynamic>? extraData;

  HamaData({
    required this.nama,
    required this.status,
    required this.timestamp,
    this.extraData,
  });

  // Factory constructor untuk membuat HamaData dari Firestore
  factory HamaData.fromFirestore(Map<String, dynamic> data) {
    // Debug: Print data yang diterima dari Firestore
    print('🔍 Firestore data received: $data');
    
    // Cek field yang tersedia di Firestore
    String status;
    String nama;
    
    if (data.containsKey('hama') && data['hama'] != null) {
      // Menggunakan field 'hama' dari database
      status = data['hama'].toString();
      nama = data['nama'] ?? 'Monitoring Hama';
      print('📋 Using hama field: $status');
    } else if (data.containsKey('status') && data['status'] != null) {
      // Jika ada field status terpisah
      status = data['status'].toString();
      nama = data['nama'] ?? 'Unknown';
      print('📋 Using separate status field: $status');
    } else if (data.containsKey('nama') && data['nama'] != null) {
      // Fallback ke field 'nama' sebagai status
      status = data['nama'].toString();
      nama = status;
      print('📋 Using nama as status: $status');
    } else {
      // Default jika tidak ada field yang sesuai
      status = 'Tidak ada hama';
      nama = 'Unknown';
      print('📋 Using default status: $status');
    }
    
    // Normalisasi status untuk memastikan konsistensi
    status = _normalizeStatus(status);
    print('✨ Normalized status: $status');
    
    return HamaData(
      nama: nama,
      status: status,
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      extraData: data,
    );
  }

  // ✅ PERBAIKAN: Helper method untuk normalisasi status
  static String _normalizeStatus(String rawStatus) {
    String normalized = rawStatus.toLowerCase().trim();
    print('🔧 Normalizing status: "$rawStatus" -> "$normalized"');
    
    // ✅ PERBAIKAN: Deteksi "Hama Terdeteksi" dengan lebih spesifik
    if (normalized.contains('hama terdeteksi') || 
        normalized.contains('hama detected') ||
        (normalized.contains('hama') && normalized.contains('terdeteksi'))) {
      print('✅ Detected as: Hama Terdeteksi');
      return 'Hama Terdeteksi';
    }
    
    // ✅ PERBAIKAN: Deteksi "tidak ada hama" dengan lebih spesifik
    if (normalized.contains('tidak ada hama') || 
        normalized.contains('no hama') || 
        normalized.contains('tidak ada') ||
        normalized.contains('clean') ||
        normalized.contains('aman') ||
        normalized.contains('normal')) {
      print('✅ Detected as: Tidak ada hama');
      return 'Tidak ada hama';
    }
    
    // ✅ PERBAIKAN: Jika tidak ada kata "hama" tapi ada indikasi positif
    if (normalized.contains('detected') || 
        normalized.contains('terdeteksi') || 
        normalized.contains('alert') ||
        normalized.contains('warning')) {
      print('✅ Detected as: Hama Terdeteksi (by keywords)');
      return 'Hama Terdeteksi';
    }
    
    // ✅ PERBAIKAN: Default ke "Tidak ada hama" untuk status yang tidak jelas
    print('⚠️ Defaulting to: Tidak ada hama');
    return 'Tidak ada hama';
  }

  // Check apakah hama terdeteksi
  bool get isHamaDetected {
    bool detected = status == 'Hama Terdeteksi';
    print('🔍 isHamaDetected: $detected for status: $status');
    return detected;
  }

  // Check apakah tidak ada hama
  bool get isNoHama {
    bool noHama = status == 'Tidak ada hama';
    print('✅ isNoHama: $noHama for status: $status');
    return noHama;
  }

  // Get notification title berdasarkan status
  String getNotificationTitle() {
    print('📱 Getting notification title for status: $status');
    if (isHamaDetected) {
      return '⚠️ Hama Terdeteksi!';
    }
    return '✅ Status Hama';
  }

  // Get notification body berdasarkan status
  String getNotificationBody() {
    if (isHamaDetected) {
      return 'Hama telah terdeteksi pada akuarium Anda. Segera lakukan penanganan yang diperlukan untuk menjaga kesehatan ikan.';
    }
    return 'Tidak ada hama yang terdeteksi. Akuarium dalam kondisi baik.';
  }

  // Get severity level untuk notification
  String getSeverityLevel() {
    if (isHamaDetected) {
      return 'high';
    }
    return 'low';
  }

  // Get priority untuk sorting notification
  int getPriority() {
    if (isHamaDetected) {
      return 3; // High priority
    }
    return 1; // Low priority
  }

  // Check apakah perlu notifikasi
  bool shouldNotify() {
    bool notify = isHamaDetected;
    print('🔔 shouldNotify: $notify for status: $status');
    return notify;
  }

  // Get color untuk UI
  String getStatusColor() {
    if (isHamaDetected) {
      return '#F44336'; // Red
    }
    return '#4CAF50'; // Green
  }

  // Get icon untuk UI
  String getStatusIcon() {
    if (isHamaDetected) {
      return '⚠️';
    }
    return '✅';
  }

  @override
  String toString() {
    return 'HamaData(nama: $nama, status: $status, timestamp: $timestamp, shouldNotify: ${shouldNotify()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HamaData &&
        other.nama == nama &&
        other.status == status &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return nama.hashCode ^ status.hashCode ^ timestamp.hashCode;
  }

  // Copy with method untuk immutability
  HamaData copyWith({
    String? nama,
    String? status,
    DateTime? timestamp,
    Map<String, dynamic>? extraData,
  }) {
    return HamaData(
      nama: nama ?? this.nama,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      extraData: extraData ?? this.extraData,
    );
  }

  // Method untuk testing - simulasi data hama terdeteksi
  static HamaData createTestHamaDetected() {
    return HamaData(
      nama: 'Test Hama',
      status: 'Hama Terdeteksi',
      timestamp: DateTime.now(),
    );
  }

  // Method untuk testing - simulasi data tidak ada hama
  static HamaData createTestNoHama() {
    return HamaData(
      nama: 'Test Clean',
      status: 'Tidak ada hama',
      timestamp: DateTime.now(),
    );
  }
}