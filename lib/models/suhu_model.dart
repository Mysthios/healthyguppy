import 'package:flutter/material.dart';

class SuhuData {
  final double suhu;
  final String status;
  final DateTime timestamp;

  SuhuData({
    required this.suhu,
    required this.status,
    required this.timestamp,
  });

  factory SuhuData.fromFirestore(Map<String, dynamic> data) {
    double temp = data['suhu']?.toDouble() ?? 0.0;
    return SuhuData(
      suhu: temp,
      status: _getSuhuStatus(temp),
      timestamp: DateTime.now(),
    );
  }

  static String _getSuhuStatus(double suhu) {
    if (suhu < 24) {
      return 'Terlalu Dingin';
    } else if (suhu > 28) {
      return 'Terlalu Panas';
    } else {
      return 'Normal';
    }
  }

  Color getSuhuColor() {
    if (suhu < 24) {
      return Colors.blue;
    } else if (suhu > 28) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  IconData getSuhuIcon() {
    if (suhu < 24) {
      return Icons.ac_unit;
    } else if (suhu > 28) {
      return Icons.whatshot;
    } else {
      return Icons.thermostat;
    }
  }

  bool isOutOfRange() {
    return suhu < 24 || suhu > 28;
  }

  String getNotificationTitle() {
    if (suhu < 24) {
      return 'Suhu Terlalu Rendah!';
    } else if (suhu > 28) {
      return 'Suhu Terlalu Tinggi!';
    }
    return '';
  }

  String getNotificationBody() {
    if (suhu < 24) {
      return 'Suhu saat ini ${suhu.toStringAsFixed(1)}°C - Di bawah batas normal (24°C)';
    } else if (suhu > 28) {
      return 'Suhu saat ini ${suhu.toStringAsFixed(1)}°C - Di atas batas normal (28°C)';
    }
    return '';
  }
}