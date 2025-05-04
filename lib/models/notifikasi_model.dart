class NotifikasiModel {
  final String? id;
  final String judul;
  final String isi;
  final DateTime waktu;

  NotifikasiModel({
    this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
  });

  Map<String, dynamic> toJson() => {
        'judul': judul,
        'isi': isi,
        'waktu': waktu.toIso8601String(),
      };

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      judul: json['judul'],
      isi: json['isi'],
      waktu: DateTime.parse(json['waktu']),
    );
  }
}
