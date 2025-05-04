import 'package:flutter/material.dart';
import 'package:healthyguppy/core/constant.dart';
import 'package:healthyguppy/pages/jadwal/jadwalpage.dart';

class SemuaJadwalButton extends StatelessWidget {
  const SemuaJadwalButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HalamanJadwal()),
                      );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20, 
          vertical: 20),
        decoration: BoxDecoration(
          color: kSecondaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Semua",
              style: kTextStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Jadwal",
              style: kTextStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
