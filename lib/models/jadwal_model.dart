class JadwalModel {
  String? id; // Firebase doc ID, nullable
  int jam;
  int menit;
  List<String> hari;

  JadwalModel({
    this.id,
    required this.jam,
    required this.menit,
    required this.hari,
  });

  Map<String, dynamic> toMap() {
    return {
      'jam': jam,
      'menit': menit,
      'hari': hari,
    };
  }

  factory JadwalModel.fromMap(Map<String, dynamic> json, String id) {
    return JadwalModel(
      id: id,
      jam: json['jam'],
      menit: json['menit'],
      hari: List<String>.from(json['hari']),
    );
  }
}
