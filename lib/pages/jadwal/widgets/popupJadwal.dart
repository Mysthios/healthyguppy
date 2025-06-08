// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:healthyguppy/models/jadwal_model.dart';
// import 'package:healthyguppy/provider/jadwal_provider.dart';
// import 'package:healthyguppy/core/constant.dart';
// import 'package:healthyguppy/services/notification_service.dart';

// class PopupTambahUpdateJadwal extends ConsumerStatefulWidget {
//   final int? index;
//   final JadwalModel? existingJadwal;

//   const PopupTambahUpdateJadwal({super.key, this.index, this.existingJadwal});

//   @override
//   ConsumerState<PopupTambahUpdateJadwal> createState() =>
//       _PopupTambahUpdateJadwalState();
// }

// class _PopupTambahUpdateJadwalState
//     extends ConsumerState<PopupTambahUpdateJadwal> with TickerProviderStateMixin {
//   int jam = 0;
//   int menit = 0;
//   List<String> selectedHari = [];
//   bool isLoading = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;

//   final List<String> semuaHari = [
//     'Minggu',
//     'Senin',
//     'Selasa',
//     'Rabu',
//     'Kamis',
//     'Jumat',
//     'Sabtu',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
//     );

//     _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
//     );

//     if (widget.existingJadwal != null) {
//       jam = widget.existingJadwal!.jam;
//       menit = widget.existingJadwal!.menit;
//       selectedHari = List<String>.from(widget.existingJadwal!.hari);
//     }

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.black54,
//       child: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return FadeTransition(
//             opacity: _fadeAnimation,
//             child: Transform.translate(
//               offset: Offset(0, _slideAnimation.value),
//               child: Center(
//                 child: Container(
//                   margin: const EdgeInsets.all(20),
//                   constraints: BoxConstraints(
//                     maxWidth: 400,
//                     maxHeight: MediaQuery.of(context).size.height * 0.85,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.15),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _buildHeader(),
//                       Flexible(
//                         child: SingleChildScrollView(
//                           child: _buildContent(),
//                         ),
//                       ),
//                       _buildActionButtons(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           // Icon dengan background biru
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: const Color(0xFF1DA1F2),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Icon(
//               Icons.access_time_rounded,
//               color: Colors.white,
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Title
//           Text(
//             widget.existingJadwal != null ? 'Edit Jadwal' : 'Tambah Jadwal Baru',
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1A1A1A),
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Subtitle
//           const Text(
//             'Atur waktu dan hari untuk pengingat Anda',
//             style: TextStyle(
//               fontSize: 14,
//               color: Color(0xFF666666),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildTimeSection(),
//           const SizedBox(height: 24),
//           _buildDaySection(),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.access_time_rounded,
//               color: const Color(0xFF1DA1F2),
//               size: 20,
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'Pilih Waktu',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1A1A1A),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildTimePicker(isJam: true),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 12),
//               child: const Text(
//                 ":",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1DA1F2),
//                 ),
//               ),
//             ),
//             _buildTimePicker(isJam: false),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 70,
//               child: const Text(
//                 'Jam',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Color(0xFF666666),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 36),
//             Container(
//               width: 70,
//               child: const Text(
//                 'Menit',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Color(0xFF666666),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildTimePicker({required bool isJam}) {
//     return Container(
//       width: 135,
//       height: 140,
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F9FA),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: const Color(0xFFE1E8ED),
//           width: 1,
//         ),
//       ),
//       child: CupertinoPicker(
//         scrollController: FixedExtentScrollController(
//           initialItem: isJam ? jam : menit,
//         ),
//         itemExtent: 36,
//         backgroundColor: Colors.transparent,
//         squeeze: 1.0,
//         onSelectedItemChanged: (value) {
//           setState(() {
//             isJam ? jam = value : menit = value;
//           });
//         },
//         children: List.generate(isJam ? 24 : 60, (index) {
//           return Center(
//             child: Text(
//               index.toString().padLeft(2, '0'),
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1A1A1A),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildDaySection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.calendar_today_rounded,
//               color: const Color(0xFF1DA1F2),
//               size: 20,
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'Pilih Hari',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1A1A1A),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Column(
//           children: semuaHari.map((hari) {
//             final isSelected = selectedHari.contains(hari);
//             return _buildDayCard(hari, isSelected);
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildDayCard(String hari, bool isSelected) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             isSelected ? selectedHari.remove(hari) : selectedHari.add(hari);
//           });
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? const Color(0xFF1DA1F2).withOpacity(0.1)
//                 : const Color(0xFFF8F9FA),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isSelected
//                   ? const Color(0xFF1DA1F2)
//                   : const Color(0xFFE1E8ED),
//               width: 1.5,
//             ),
//           ),
//           child: Row(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: 20,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? const Color(0xFF1DA1F2)
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(4),
//                   border: Border.all(
//                     color: isSelected
//                         ? const Color(0xFF1DA1F2)
//                         : const Color(0xFFCCCCCC),
//                     width: 2,
//                   ),
//                 ),
//                 child: isSelected
//                     ? const Icon(
//                         Icons.check,
//                         color: Colors.white,
//                         size: 14,
//                       )
//                     : null,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 hari,
//                 style: TextStyle(
//                   color: isSelected
//                       ? const Color(0xFF1DA1F2)
//                       : const Color(0xFF1A1A1A),
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: Row(
//         children: [
//           // Delete button (hanya tampil saat edit)
//           if (widget.index != null)
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFF2F2),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: const Color(0xFFFFE1E1),
//                   width: 1,
//                 ),
//               ),
//               child: IconButton(
//                 icon: const Icon(
//                   Icons.delete_outline_rounded,
//                   color: Color(0xFFE53E3E),
//                   size: 20,
//                 ),
//                 onPressed: () {
//                   _showDeleteConfirmation();
//                 },
//               ),
//             ),
//           const Spacer(),
//           // Cancel button
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text(
//               'Batal',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF666666),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           // Save button
//           ElevatedButton(
//             onPressed: isLoading ? null : _simpanJadwal,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1DA1F2),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 0,
//             ),
//             child: isLoading
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   )
//                 : const Text(
//                     'Simpan',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeleteConfirmation() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Hapus Jadwal',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1A1A1A),
//           ),
//         ),
//         content: const Text(
//           'Apakah Anda yakin ingin menghapus jadwal ini?',
//           style: TextStyle(color: Color(0xFF666666)),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Batal',
//               style: TextStyle(color: Color(0xFF666666)),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final id = widget.existingJadwal?.id;
//               if (id != null) {
//                 ref.read(jadwalListProvider.notifier).hapusJadwal(id);
//                 Navigator.pop(context); // Close confirmation
//                 Navigator.pop(context); // Close main dialog
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE53E3E),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Hapus',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _simpanJadwal() async {
//     if (selectedHari.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.warning_rounded, color: Colors.white),
//               const SizedBox(width: 8),
//               const Text('Pilih minimal satu hari!'),
//             ],
//           ),
//           backgroundColor: const Color(0xFFFF8C00),
//           behavior: SnackBarBehavior.floating,
//           margin: const EdgeInsets.all(16),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//       return;
//     }

//     setState(() => isLoading = true);
//     await Future.delayed(const Duration(milliseconds: 500));

//     final newJadwal = JadwalModel(jam: jam, menit: menit, hari: selectedHari);

//     if (widget.index != null && widget.existingJadwal?.id != null) {
//       ref.read(jadwalListProvider.notifier).updateJadwal(widget.existingJadwal!.id!, newJadwal);
//     } else {
//       ref.read(jadwalListProvider.notifier).tambahJadwal(newJadwal);
//     }

//     // Schedule notifications
//     final baseId = DateTime.now().millisecondsSinceEpoch;
//     final now = DateTime.now();

//     for (int i = 0; i < selectedHari.length; i++) {
//       final hari = selectedHari[i];
//       final hariIndex = semuaHari.indexOf(hari);

//       DateTime nextScheduledDate = _getNextScheduledDate(now, hariIndex, jam, menit);
//       final notificationId = baseId + i;

//       try {
//         await NotificationService.scheduleNotification(
//           id: notificationId,
//           title: 'Pengingat Jadwal',
//           body: 'Jadwal Anda pada pukul ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')} - $hari',
//           scheduledDate: nextScheduledDate,
//         );

//         debugPrint('✅ Scheduled notification for $hari at $nextScheduledDate');
//       } catch (e) {
//         debugPrint('❌ Failed to schedule notification for $hari: $e');
//       }
//     }

//     if (mounted) Navigator.pop(context);
//   }

//   DateTime _getNextScheduledDate(DateTime now, int targetDayOfWeek, int targetHour, int targetMinute) {
//     int currentDayOfWeek = now.weekday == 7 ? 0 : now.weekday;
//     int daysUntilTarget = (targetDayOfWeek - currentDayOfWeek) % 7;

//     if (daysUntilTarget == 0) {
//       final targetTime = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
//       if (targetTime.isBefore(now)) {
//         daysUntilTarget = 7;
//       }
//     }

//     final scheduledDate = DateTime(
//       now.year,
//       now.month,
//       now.day + daysUntilTarget,
//       targetHour,
//       targetMinute,
//     );

//     return scheduledDate;
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/helper/jadwal_notification_helper.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/provider/jadwal_provider.dart';
import 'package:healthyguppy/core/constant.dart';
import 'package:healthyguppy/services/notification_service.dart';
import 'package:healthyguppy/services/jadwal_checker_service.dart'; // Import service

class PopupTambahUpdateJadwal extends ConsumerStatefulWidget {
  final int? index;
  final JadwalModel? existingJadwal;

  const PopupTambahUpdateJadwal({super.key, this.index, this.existingJadwal});

  @override
  ConsumerState<PopupTambahUpdateJadwal> createState() =>
      _PopupTambahUpdateJadwalState();
}

class _PopupTambahUpdateJadwalState
    extends ConsumerState<PopupTambahUpdateJadwal>
    with TickerProviderStateMixin {
  int jam = 0;
  int menit = 0;
  List<String> selectedHari = [];
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Instance dari JadwalCheckerService untuk menggunakan logika yang sama
  final JadwalCheckerService _jadwalChecker = JadwalCheckerService();

  final List<String> semuaHari = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    if (widget.existingJadwal != null) {
      jam = widget.existingJadwal!.jam;
      menit = widget.existingJadwal!.menit;
      selectedHari = List<String>.from(widget.existingJadwal!.hari);
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    maxWidth: 400,
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      Flexible(
                        child: SingleChildScrollView(child: _buildContent()),
                      ),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icon dengan background biru
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1DA1F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            widget.existingJadwal != null
                ? 'Edit Jadwal'
                : 'Tambah Jadwal Baru',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          const Text(
            'Atur waktu dan hari untuk pengingat Anda',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeSection(),
          const SizedBox(height: 24),
          _buildDaySection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: const Color(0xFF1DA1F2),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Pilih Waktu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimePicker(isJam: true),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: const Text(
                ":",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1DA1F2),
                ),
              ),
            ),
            _buildTimePicker(isJam: false),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              child: const Text(
                'Jam',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ),
            const SizedBox(width: 36),
            Container(
              width: 70,
              child: const Text(
                'Menit',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimePicker({required bool isJam}) {
    return Container(
      width: 135,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E8ED), width: 1),
      ),
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(
          initialItem: isJam ? jam : menit,
        ),
        itemExtent: 36,
        backgroundColor: Colors.transparent,
        squeeze: 1.0,
        onSelectedItemChanged: (value) {
          setState(() {
            isJam ? jam = value : menit = value;
          });
        },
        children: List.generate(isJam ? 24 : 60, (index) {
          return Center(
            child: Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: const Color(0xFF1DA1F2),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Pilih Hari',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children:
              semuaHari.map((hari) {
                final isSelected = selectedHari.contains(hari);
                return _buildDayCard(hari, isSelected);
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDayCard(String hari, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isSelected ? selectedHari.remove(hari) : selectedHari.add(hari);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF1DA1F2).withOpacity(0.1)
                    : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFF1DA1F2)
                      : const Color(0xFFE1E8ED),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF1DA1F2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF1DA1F2)
                            : const Color(0xFFCCCCCC),
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
              ),
              const SizedBox(width: 12),
              Text(
                hari,
                style: TextStyle(
                  color:
                      isSelected
                          ? const Color(0xFF1DA1F2)
                          : const Color(0xFF1A1A1A),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Delete button (hanya tampil saat edit)
          if (widget.index != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE1E1), width: 1),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE53E3E),
                  size: 20,
                ),
                onPressed: () {
                  _showDeleteConfirmation();
                },
              ),
            ),
          const Spacer(),
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Save button
          ElevatedButton(
            onPressed: isLoading ? null : _simpanJadwal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DA1F2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Hapus Jadwal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus jadwal ini?',
              style: TextStyle(color: Color(0xFF666666)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Color(0xFF666666)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final id = widget.existingJadwal?.id;
                  if (id != null) {
                    ref.read(jadwalListProvider.notifier).hapusJadwal(id);
                    Navigator.pop(context); // Close confirmation
                    Navigator.pop(context); // Close main dialog
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _simpanJadwal() async {
    if (selectedHari.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Pilih minimal satu hari!'),
            ],
          ),
          backgroundColor: const Color(0xFFFF8C00),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final newJadwal = JadwalModel(jam: jam, menit: menit, hari: selectedHari);

    try {
      // Simpan jadwal ke database
      if (widget.index != null && widget.existingJadwal?.id != null) {
        ref
            .read(jadwalListProvider.notifier)
            .updateJadwal(widget.existingJadwal!.id!, newJadwal);
      } else {
        ref.read(jadwalListProvider.notifier).tambahJadwal(newJadwal);
      }

      // ✨ MENGGUNAKAN HELPER CLASS YANG SUDAH DISEDERHANAKAN ✨
      await JadwalNotificationHelper.setupNotificationsForJadwal(
        jadwal: newJadwal,
        isUpdate: widget.index != null,
        // oldNotificationIds bisa di-generate atau di-track jika diperlukan
        // oldNotificationIds: widget.existingJadwal?.notificationIds,
      );

      print('✅ Successfully saved jadwal and set up notifications');

      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('❌ Error saving jadwal: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Gagal menyimpan jadwal!'),
              ],
            ),
            backgroundColor: const Color(0xFFE53E3E),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
