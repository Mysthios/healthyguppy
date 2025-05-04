import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/provider/jadwal_provider.dart';
import 'package:healthyguppy/core/constant.dart';

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
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timePicker(isJam: true),
                const SizedBox(width: 8),
                const Text(
                  ":",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                _timePicker(isJam: false),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 120,
                  child: Text(
                    'Jam',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: Text(
                    'Menit',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
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
                      if (isSelected) {
                        selectedHari.remove(hari);
                      } else {
                        selectedHari.add(hari);
                      }
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
                          color:
                              isSelected ? Colors.white : kSecondaryTextColor,
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
                      'assets/icons/Hapus.png', // Ganti sesuai path file kamu
                      width: 24,
                      height: 24,
                      color:
                          Colors
                              .orange, // Hanya berfungsi jika gambar hitam putih
                    ),
                    onPressed: () {
                      ref
                          .read(jadwalListProvider.notifier)
                          .hapusJadwal(widget.index!);
                      Navigator.pop(context);
                    },
                  ),

                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: kPrimaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isLoading ? null : _simpanJadwal,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kPrimaryColor,
                            ),
                          )
                          : Text(
                            'Oke',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
      child: Align(
        alignment: Alignment.center, // Menjaga agar picker tetap terpusat
        child: CupertinoPicker(
          scrollController: FixedExtentScrollController(
            initialItem: isJam ? jam : menit,
          ),
          itemExtent: 32,
          backgroundColor: Colors.transparent,
          onSelectedItemChanged: (value) {
            setState(() {
              if (isJam) {
                jam = value;
              } else {
                menit = value;
              }
            });
          },
          children: List.generate(isJam ? 24 : 60, (index) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: const TextStyle(fontSize: 26, color: kPrimaryTextColor),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _simpanJadwal() async {
    if (selectedHari.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih minimal satu hari!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final newJadwal = JadwalModel(jam: jam, menit: menit, hari: selectedHari);
    if (widget.index != null) {
      ref
          .read(jadwalListProvider.notifier)
          .updateJadwal(widget.index!, newJadwal);
    } else {
      ref.read(jadwalListProvider.notifier).tambahJadwal(newJadwal);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
