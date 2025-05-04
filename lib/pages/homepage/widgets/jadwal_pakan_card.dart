import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/homepage/widgets/jam_pakan.dart';
import 'package:healthyguppy/pages/homepage/widgets/semua_jadwal_button.dart';

class JadwalPakanCard extends StatelessWidget {
  const JadwalPakanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            JamPakan(),
            SemuaJadwalButton(),
          ],
        ),
      ),
    );
  }
}
