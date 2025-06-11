import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/core/constant.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/provider/jadwal_provider.dart';
import 'package:healthyguppy/pages/jadwal/jadwalpage.dart';

class ModernScheduleSection extends ConsumerWidget {
  const ModernScheduleSection({super.key});

  // Method untuk mendapatkan jadwal selanjutnya (same as before)
  JadwalModel? _getNextSchedule(List<JadwalModel> jadwalList) {
    if (jadwalList.isEmpty) return null;
    
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentHour = now.hour;
    final currentMinute = now.minute;
    
    final activeSchedules = jadwalList.where((jadwal) => jadwal.isActive).toList();
    if (activeSchedules.isEmpty) return null;
    
    final todaySchedules = activeSchedules.where((jadwal) {
      return jadwal.hari.contains(_getDayName(currentDay)) &&
             (jadwal.jam > currentHour || 
              (jadwal.jam == currentHour && jadwal.menit > currentMinute));
    }).toList();
    
    if (todaySchedules.isNotEmpty) {
      todaySchedules.sort((a, b) {
        if (a.jam != b.jam) return a.jam.compareTo(b.jam);
        return a.menit.compareTo(b.menit);
      });
      return todaySchedules.first;
    }
    
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
  
  // Updated to 24-hour format to match first document
  String _formatTime(int jam, int menit) {
    return '${jam.toString().padLeft(2, '0')}.${menit.toString().padLeft(2, '0')}';
  }
  
  String _getTimeUntilNext(JadwalModel jadwal) {
    final now = DateTime.now();
    final currentDay = now.weekday;
    
    int targetDay = -1;
    for (int i = 1; i <= 7; i++) {
      if (jadwal.hari.contains(_getDayName(i))) {
        targetDay = i;
        break;
      }
    }
    
    if (targetDay == -1) return '';
    
    DateTime targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      jadwal.jam,
      jadwal.menit,
    );
    
    if (targetDay != currentDay || targetTime.isBefore(now)) {
      int daysToAdd = (targetDay - currentDay + 7) % 7;
      if (daysToAdd == 0 && targetTime.isBefore(now)) {
        daysToAdd = 7;
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section - Reduced height
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced from 12
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 22, // Reduced from 24
                ),
              ),
              const SizedBox(width: 14), // Reduced from 16
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jadwal Makanan",
                      style: TextStyle(
                        fontSize: screenWidth < 360 ? 16 : 18, // Reduced sizes
                        fontWeight: FontWeight.bold,
                        color: kPrimaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced from 4
                    Text(
                      isLoggedIn 
                        ? (jadwalList.isNotEmpty ? "Jadwal pakan terdaftar" : "Belum ada jadwal")
                        : "Login untuk melihat jadwal",
                      style: TextStyle(
                        fontSize: 11, // Reduced from 12
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 14), // Reduced from 20
          
          // Schedule Content
          if (!isLoggedIn) 
            _buildLoginContent()
          else if (jadwalList.isEmpty)
            _buildEmptyScheduleContent()
          else
            _buildScheduleContent(jadwalList, screenWidth),
          
          const SizedBox(height: 12), // Reduced from 16
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HalamanJadwal()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kSecondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 16
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 18), // Reduced from 20
                  const SizedBox(width: 8),
                  Text(
                    isLoggedIn ? "Kelola Jadwal" : "Login & Atur Jadwal",
                    style: const TextStyle(
                      fontSize: 15, // Reduced from 16
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginContent() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade600,
            size: 28, // Reduced from 32
          ),
          const SizedBox(width: 14), // Reduced from 16
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Login Diperlukan",
                  style: TextStyle(
                    fontSize: 15, // Reduced from 16
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 3), // Reduced from 4
                Text(
                  "Masuk untuk melihat dan mengatur jadwal pemberian makan ikan",
                  style: TextStyle(
                    fontSize: 12, // Reduced from 13
                    color: Colors.blue.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScheduleContent() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            color: Colors.grey.shade500,
            size: 40, // Reduced from 48
          ),
          const SizedBox(height: 10), // Reduced from 12
          Text(
            "Belum Ada Jadwal",
            style: TextStyle(
              fontSize: 16, // Reduced from 18
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6), // Reduced from 8
          Text(
            "Tambahkan jadwal pemberian makan untuk ikan kesayangan Anda",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13, // Reduced from 14
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(List<JadwalModel> jadwalList, double screenWidth) {
    final nextSchedule = _getNextSchedule(jadwalList);
    
    if (nextSchedule == null) {
      return _buildEmptyScheduleContent();
    }

    return Container(
      padding: const EdgeInsets.all(14), // Reduced from 20
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Next Schedule Time - More compact header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                color: Colors.green.shade700,
                size: 16, // Reduced from 24
              ),
              const SizedBox(width: 6), // Reduced from 8
              Text(
                "Jadwal Selanjutnya",
                style: TextStyle(
                  fontSize: 12, // Reduced from 14
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10), // Reduced from 16
          
          // Time Display - Much more compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Reduced significantly
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatTime(nextSchedule.jam, nextSchedule.menit),
                  style: TextStyle(
                    fontSize: screenWidth < 360 ? 20 : 22, // Significantly reduced from 28:32
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4), // Reduced from 8
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    nextSchedule.hari.join(', '),
                    style: TextStyle(
                      fontSize: 10, // Reduced from 12
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 4), // Reduced from 8
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 12, // Reduced from 16
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _getTimeUntilNext(nextSchedule),
                        style: TextStyle(
                          fontSize: 10, // Reduced from 12
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}