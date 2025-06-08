import 'package:cloud_firestore/cloud_firestore.dart';

class NotifikasiModel {
  final String? id;
  final String judul;
  final String isi;
  final DateTime waktu;
  final String? userId;
  final bool isRead;

  NotifikasiModel({
    this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
    this.userId,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'judul': judul,
        'isi': isi,
        'waktu': Timestamp.fromDate(waktu), // ✅ Gunakan Timestamp untuk Firebase
        'userId': userId,
        'isRead': isRead,
      };

  factory NotifikasiModel.fromMap(Map<String, dynamic> json) {
    DateTime parsedWaktu;
    
    try {
      // Handle berbagai format waktu yang mungkin ada
      if (json['waktu'] is Timestamp) {
        // Format Timestamp dari Firebase
        parsedWaktu = (json['waktu'] as Timestamp).toDate();
      } else if (json['waktu'] is String) {
        // Format String ISO8601
        parsedWaktu = DateTime.parse(json['waktu']);
      } else {
        // Fallback ke waktu sekarang jika format tidak dikenali
        parsedWaktu = DateTime.now();
        print('Warning: Unknown waktu format, using current time');
      }
    } catch (e) {
      print('Error parsing waktu: $e');
      parsedWaktu = DateTime.now();
    }

    return NotifikasiModel(
      judul: json['judul'] ?? 'Tidak ada judul',
      isi: json['isi'] ?? 'Tidak ada isi',
      waktu: parsedWaktu,
      userId: json['userId'],
      isRead: json['isRead'] ?? false,
    );
  }

  // Method untuk membuat copy dengan field yang diupdate
  NotifikasiModel copyWith({
    String? id,
    String? judul,
    String? isi,
    DateTime? waktu,
    String? userId,
    bool? isRead,
  }) {
    return NotifikasiModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      waktu: waktu ?? this.waktu,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() {
    return 'NotifikasiModel(id: $id, judul: $judul, isi: $isi, waktu: $waktu, userId: $userId, isRead: $isRead)';
  }
}