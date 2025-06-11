import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/core/constant.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/provider/jadwal_provider.dart';

class JamPakan extends ConsumerWidget {
  const JamPakan({super.key});

  // Method untuk mendapatkan jadwal selanjutnya
  JadwalModel? _getNextSchedule(List<JadwalModel> jadwalList) {
    if (jadwalList.isEmpty) return null;
    
    final now = DateTime.now();
    final currentDay = now.weekday; // 1 = Monday, 7 = Sunday
    final currentHour = now.hour;
    final currentMinute = now.minute;
    
    // Filter jadwal yang aktif saja
    final activeSchedules = jadwalList.where((jadwal) => jadwal.isActive).toList();
    if (activeSchedules.isEmpty) return null;
    
    // Cari jadwal hari ini yang belum lewat
    final todaySchedules = activeSchedules.where((jadwal) {
      return jadwal.hari.contains(_getDayName(currentDay)) &&
             (jadwal.jam > currentHour || 
              (jadwal.jam == currentHour && jadwal.menit > currentMinute));
    }).toList();
    
    if (todaySchedules.isNotEmpty) {
      // Sort berdasarkan waktu dan ambil yang paling dekat
      todaySchedules.sort((a, b) {
        if (a.jam != b.jam) return a.jam.compareTo(b.jam);
        return a.menit.compareTo(b.menit);
      });
      return todaySchedules.first;
    }
    
    // Jika tidak ada jadwal hari ini, cari jadwal hari berikutnya
    for (int i = 1; i <= 7; i++) {
      final nextDay = (currentDay + i - 1) % 7 + 1;
      final nextDaySchedules = activeSchedules.where((jadwal) {
        return jadwal.hari.contains(_getDayName(nextDay));
      }).toList();
      
      if (nextDaySchedules.isNotEmpty) {
        nextDaySchedules.sort((a, b) {
          if (a.jam != b.jam) return a.jam.compareTo(b.jam);
          return a.menit.compareTo(b.menit);
        });
        return nextDaySchedules.first;
      }
    }
    
    return null;
  }
  
  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return '';
    }
  }
  
  String _formatTime(int jam, int menit) {
    return '${jam.toString().padLeft(2, '0')}.${menit.toString().padLeft(2, '0')}';
  }
  
  String _getTimeUntilNext(JadwalModel jadwal) {
    final now = DateTime.now();
    final currentDay = now.weekday;
    
    // Tentukan hari target
    int targetDay = -1;
    for (int i = 1; i <= 7; i++) {
      if (jadwal.hari.contains(_getDayName(i))) {
        targetDay = i;
        break;
      }
    }
    
    if (targetDay == -1) return '';
    
    // Hitung waktu target
    DateTime targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      jadwal.jam,
      jadwal.menit,
    );
    
    // Jika jadwal untuk hari yang berbeda atau sudah lewat hari ini
    if (targetDay != currentDay || targetTime.isBefore(now)) {
      int daysToAdd = (targetDay - currentDay + 7) % 7;
      if (daysToAdd == 0 && targetTime.isBefore(now)) {
        daysToAdd = 7; // Minggu depan
      }
      targetTime = targetTime.add(Duration(days: daysToAdd));
    }
    
    final difference = targetTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      return 'dalam $hours jam ${minutes > 0 ? '$minutes menit' : ''}';
    } else if (minutes > 0) {
      return 'dalam $minutes menit';
    } else {
      return 'sekarang';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jadwalList = ref.watch(jadwalListProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);
    
    if (!isLoggedIn) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Jadwal Makanan",
                        style: kTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Login untuk melihat jadwal",
                        style: kTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    final nextSchedule = _getNextSchedule(jadwalList);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: nextSchedule != null 
            ? [Colors.green.shade50, Colors.green.shade100]
            : [Colors.grey.shade50, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: nextSchedule != null 
                    ? Colors.green.shade100 
                    : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  nextSchedule != null ? Icons.schedule : Icons.schedule_outlined,
                  color: nextSchedule != null 
                    ? Colors.green.shade700 
                    : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jadwal Makanan",
                      style: kTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kPrimaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextSchedule != null 
                        ? "Jadwal selanjutnya"
                        : "Tidak ada jadwal aktif",
                      style: kTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (nextSchedule != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(nextSchedule.jam, nextSchedule.menit),
                      style: kTextStyle.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        nextSchedule.hari.join(', '),
                        style: kTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTimeUntilNext(nextSchedule),
                      style: kTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Belum ada jadwal yang diatur",
                    style: kTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tambahkan jadwal makanan untuk ikan Anda",
                    style: kTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}