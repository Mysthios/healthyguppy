import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/jadwal/widgets/popupJadwal.dart';

class TombolTambah extends StatelessWidget {
  const TombolTambah({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Transform.translate(
        offset: const Offset(20, 20),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const PopupTambahUpdateJadwal(),
            );
          },
          child: Image.asset(
            'assets/icons/Tambah.png',
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
