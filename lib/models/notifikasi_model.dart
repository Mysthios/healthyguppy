import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String judul;
  final String isi;
  final String type;
  final DateTime waktu;
  final bool isRead;
  final int? notificationId;
  final Map<String, dynamic>? extraData;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.type,
    required this.waktu,
    this.isRead = false,
    this.notificationId,
    this.extraData,
    this.readAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      judul: data['judul'] ?? '',
      isi: data['isi'] ?? '',
      type: data['type'] ?? 'general',
      waktu: _parseTimestamp(data['waktu']),
      isRead: data['isRead'] ?? false,
      notificationId: data['notificationId'],
      extraData: data,
      readAt: data['readAt'] != null ? _parseTimestamp(data['readAt']) : null,
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'isi': isi,
      'type': type,
      'waktu': Timestamp.fromDate(waktu),
      'isRead': isRead,
      'notificationId': notificationId,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      ...?extraData,
    };
  }

  // Get icon based on notification type
  String getIconName() {
    switch (type) {
      case 'suhu_alert':
        if (extraData?['suhuRange'] == 'too_cold') {
          return 'ac_unit';
        } else if (extraData?['suhuRange'] == 'too_hot') {
          return 'whatshot';
        }
        return 'thermostat';
      case 'jadwal':
        return 'schedule';
      case 'feeding':
        return 'restaurant';
      case 'cleaning':
        return 'cleaning_services';
      case 'health':
        return 'health_and_safety';
      default:
        return 'notifications';
    }
  }

  // Get color based on notification type and status
  String getColorCode() {
    if (!isRead) {
      switch (type) {
        case 'suhu_alert':
          if (extraData?['suhuRange'] == 'too_cold') {
            return '#2196F3'; // Blue
          } else if (extraData?['suhuRange'] == 'too_hot') {
            return '#F44336'; // Red
          }
          return '#FF9800'; // Orange
        case 'jadwal':
          return '#4CAF50'; // Green
        case 'feeding':
          return '#FF5722'; // Deep Orange
        case 'cleaning':
          return '#00BCD4'; // Cyan
        case 'health':
          return '#9C27B0'; // Purple
        default:
          return '#607D8B'; // Blue Grey
      }
    }
    return '#9E9E9E'; // Grey for read notifications
  }

  // Get priority level
  int getPriority() {
    switch (type) {
      case 'suhu_alert':
        return 3; // High priority
      case 'health':
        return 3; // High priority
      case 'jadwal':
        return 2; // Medium priority
      case 'feeding':
        return 2; // Medium priority
      case 'cleaning':
        return 1; // Low priority
      default:
        return 1; // Low priority
    }
  }

  // Check if notification is critical
  bool isCritical() {
    return type == 'suhu_alert' || type == 'health';
  }

  // Check if notification is recent (within 24 hours)
  bool isRecent() {
    final now = DateTime.now();
    final difference = now.difference(waktu);
    return difference.inHours < 24;
  }

  // Get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(waktu);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu yang lalu';
    }
  }

  // Get formatted date time
  String getFormattedDateTime() {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final days = [
      'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
    ];

    final day = days[waktu.weekday % 7];
    final date = waktu.day;
    final month = months[waktu.month - 1];
    final year = waktu.year;
    final hour = waktu.hour.toString().padLeft(2, '0');
    final minute = waktu.minute.toString().padLeft(2, '0');

    return '$day, $date $month $year - $hour:$minute';
  }

  // Get subtitle based on notification type
  String getSubtitle() {
    switch (type) {
      case 'suhu_alert':
        if (extraData?['suhu'] != null) {
          return 'Suhu: ${extraData!['suhu'].toStringAsFixed(1)}°C';
        }
        return 'Alert suhu akuarium';
      case 'jadwal':
        return 'Pengingat jadwal';
      case 'feeding':
        return 'Waktu pemberian makan';
      case 'cleaning':
        return 'Waktu pembersihan';
      case 'health':
        return 'Kesehatan ikan';
      default:
        return 'Notifikasi umum';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? judul,
    String? isi,
    String? type,
    DateTime? waktu,
    bool? isRead,
    int? notificationId,
    Map<String, dynamic>? extraData,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      type: type ?? this.type,
      waktu: waktu ?? this.waktu,
      isRead: isRead ?? this.isRead,
      notificationId: notificationId ?? this.notificationId,
      extraData: extraData ?? this.extraData,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, judul: $judul, type: $type, waktu: $waktu, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}