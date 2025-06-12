// import 'package:cloud_firestore/cloud_firestore.dart';

// class ActionModel {
//   final String id;
//   final String pakan; // "tutup" atau "buka"
//   final DateTime? timestamp;
//   final String? userId;

//   ActionModel({
//     required this.id,
//     required this.pakan,
//     this.timestamp,
//     this.userId,
//   });

//   factory ActionModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return ActionModel(
//       id: doc.id,
//       pakan: data['pakan'] ?? 'tutup',
//       timestamp: data['timestamp']?.toDate(),
//       userId: data['userId'],
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'pakan': pakan,
//       'timestamp': FieldValue.serverTimestamp(),
//       'userId': userId,
//     };
//   }

//   // Helper method untuk copy dengan perubahan
//   ActionModel copyWith({
//     String? id,
//     String? pakan,
//     DateTime? timestamp,
//     String? userId,
//   }) {
//     return ActionModel(
//       id: id ?? this.id,
//       pakan: pakan ?? this.pakan,
//       timestamp: timestamp ?? this.timestamp,
//       userId: userId ?? this.userId,
//     );
//   }

//   // Helper method untuk status checking
//   bool get isPakanBuka => pakan == 'buka';
//   bool get isPakanTutup => pakan == 'tutup';

//   @override
//   String toString() {
//     return 'ActionModel(id: $id, pakan: $pakan, timestamp: $timestamp, userId: $userId)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is ActionModel &&
//         other.id == id &&
//         other.pakan == pakan &&
//         other.timestamp == timestamp &&
//         other.userId == userId;
//   }

//   @override
//   int get hashCode {
//     return id.hashCode ^
//         pakan.hashCode ^
//         timestamp.hashCode ^
//         userId.hashCode;
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class ActionModel {
  final String id;
  final String pakan; // "tutup" atau "buka"

  ActionModel({
    required this.id,
    required this.pakan,
  });

  factory ActionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActionModel(
      id: doc.id,
      pakan: data['pakan'] ?? 'tutup',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pakan': pakan,
    };
  }

  // Helper method untuk copy dengan perubahan
  ActionModel copyWith({
    String? id,
    String? pakan,
  }) {
    return ActionModel(
      id: id ?? this.id,
      pakan: pakan ?? this.pakan,
    );
  }

  // Helper method untuk status checking
  bool get isPakanBuka => pakan == 'buka';
  bool get isPakanTutup => pakan == 'tutup';

  @override
  String toString() {
    return 'ActionModel(id: $id, pakan: $pakan)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActionModel &&
        other.id == id &&
        other.pakan == pakan;
  }

  @override
  int get hashCode {
    return id.hashCode ^ pakan.hashCode;
  }
}