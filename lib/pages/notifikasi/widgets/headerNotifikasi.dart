import 'package:flutter/material.dart';
import 'package:healthyguppy/core/constant.dart';
import 'package:healthyguppy/pages/homepage/homepage.dart';

class HeaderNotifikasi extends StatelessWidget {
  const HeaderNotifikasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali
          GestureDetector(
          onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icons/Back.png', width: 24),
                const SizedBox(width: 4),
                const Text('Kembali', style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor, // Ganti dengan kPrimaryColor Anda
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}