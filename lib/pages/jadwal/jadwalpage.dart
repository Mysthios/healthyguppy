import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/jadwal/widgets/headerJadwal.dart';
import 'package:healthyguppy/pages/jadwal/widgets/tambahJadwalButton.dart';
import 'package:healthyguppy/pages/jadwal/widgets/jadwalList.dart';

class HalamanJadwal extends StatelessWidget {
  const HalamanJadwal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderJadwal(),
          const Expanded(
            child: JadwalList(),
          ),
          const TombolTambah(),
        ],
      ),
    );
  }
}
