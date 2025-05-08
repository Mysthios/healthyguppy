import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/provider/jadwal_provider.dart';
import 'package:healthyguppy/core/constant.dart';
import 'package:healthyguppy/services/notification_service.dart';

class PopupTambahUpdateJadwal extends ConsumerStatefulWidget {
  final int? index;
  final JadwalModel? existingJadwal;

  const PopupTambahUpdateJadwal({super.key, this.index, this.existingJadwal});

  @override
  ConsumerState<PopupTambahUpdateJadwal> createState() =>
      _PopupTambahUpdateJadwalState();
}

class _PopupTambahUpdateJadwalState
    extends ConsumerState<PopupTambahUpdateJadwal> {
  int jam = 0;
  int menit = 0;
  List<String> selectedHari = [];
  bool isLoading = false;

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
    if (widget.existingJadwal != null) {
      jam = widget.existingJadwal!.jam;
      menit = widget.existingJadwal!.menit;
      selectedHari = List<String>.from(widget.existingJadwal!.hari);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukan Waktu',
              style: TextStyle(
                color: kPrimaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timePicker(isJam: true),
                const SizedBox(width: 8),
                const Text(":", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                _timePicker(isJam: false),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(width: 120, child: Text('Jam', textAlign: TextAlign.center)),
                SizedBox(width: 16),
                SizedBox(width: 120, child: Text('Menit', textAlign: TextAlign.center)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final hari = semuaHari[index];
                final isSelected = selectedHari.contains(hari);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected ? selectedHari.remove(hari) : selectedHari.add(hari);
                    });
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? kPrimaryColor : Colors.white,
                      border: Border.all(color: kPrimaryColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        hari[0],
                        style: TextStyle(
                          color: isSelected ? Colors.white : kSecondaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.index != null)
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/Hapus.png',
                      width: 24,
                      height: 24,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      final id = widget.existingJadwal?.id;
                      if (id != null) {
                        ref.read(jadwalListProvider.notifier).hapusJadwal(id);
                        Navigator.pop(context);
                      }
                    },
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: isLoading ? null : _simpanJadwal,
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryColor),
                        )
                      : const Text('Oke', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePicker({required bool isJam}) {
    return Container(
      width: 115,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kSecondaryTextColor, width: 2),
      ),
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(
          initialItem: isJam ? jam : menit,
        ),
        itemExtent: 32,
        backgroundColor: Colors.transparent,
        onSelectedItemChanged: (value) {
          setState(() {
            isJam ? jam = value : menit = value;
          });
        },
        children: List.generate(isJam ? 24 : 60, (index) {
          return Center(
            child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 26, color: kPrimaryTextColor)),
          );
        }),
      ),
    );
  }

  void _simpanJadwal() async {
    if (selectedHari.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu hari!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final newJadwal = JadwalModel(jam: jam, menit: menit, hari: selectedHari);

    if (widget.index != null && widget.existingJadwal?.id != null) {
      ref.read(jadwalListProvider.notifier).updateJadwal(widget.existingJadwal!.id!, newJadwal);
    } else {
      ref.read(jadwalListProvider.notifier).tambahJadwal(newJadwal);
    }

    final notificationService = NotificationService();
    final baseId = DateTime.now().millisecondsSinceEpoch;

    for (var hari in selectedHari) {
      notificationService.scheduleNotification(
        id: baseId + hari.hashCode,
        title: 'Pengingat Jadwal',
        body: 'Jadwal Anda pada pukul ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')}',
        scheduledDate: DateTime.now().add(Duration(hours: jam, minutes: menit)),
      );
    }

    if (mounted) Navigator.pop(context);
  }
}
