class JadwalModel {
  String? id;
  int jam;
  int menit;
  List<String> hari;
  bool isActive;

  JadwalModel({
    this.id,
    required this.jam,
    required this.menit,
    required this.hari,
    this.isActive = true,
  });

  // Method toMap() - tidak perlu kirim ID karena Firestore auto-generate
  Map<String, dynamic> toMap() {
    return {
      'jam': jam,
      'menit': menit,
      'hari': hari,
      'isActive': isActive,
    };
  }

  // Factory constructor yang aman untuk parsing dari Firestore
  factory JadwalModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return JadwalModel(
      id: docId, // Gunakan document ID dari Firestore
      jam: _safeInt(map['jam']) ?? 0,
      menit: _safeInt(map['menit']) ?? 0,
      hari: _safeStringList(map['hari']) ?? [],
      isActive: map['isActive'] ?? true,
    );
  }

  // Helper method untuk safely convert ke int
  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  // Helper method untuk safely convert ke List<String>
  static List<String>? _safeStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  // CopyWith method untuk update
  JadwalModel copyWith({
    String? id,
    int? jam,
    int? menit,
    List<String>? hari,
    bool? isActive,
  }) {
    return JadwalModel(
      id: id ?? this.id,
      jam: jam ?? this.jam,
      menit: menit ?? this.menit,
      hari: hari ?? this.hari,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'JadwalModel(id: $id, jam: $jam, menit: $menit, hari: $hari, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JadwalModel &&
        other.id == id &&
        other.jam == jam &&
        other.menit == menit &&
        other.hari.toString() == hari.toString() &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        jam.hashCode ^
        menit.hashCode ^
        hari.hashCode ^
        isActive.hashCode;
  }
}