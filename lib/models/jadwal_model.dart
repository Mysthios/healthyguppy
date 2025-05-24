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
    this.isActive = true, // default true
  });

  Map<String, dynamic> toMap() {
    return {
      'jam': jam,
      'menit': menit,
      'hari': hari,
      'isActive': isActive,
    };
  }

  factory JadwalModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return JadwalModel(
      id: id,
      jam: map['jam'],
      menit: map['menit'],
      hari: List<String>.from(map['hari']),
      isActive: map['isActive'] ?? true,
    );
  }
}
