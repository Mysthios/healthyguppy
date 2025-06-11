import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/jadwal/widgets/popupJadwal.dart';

class TombolTambah extends StatelessWidget {
  const TombolTambah({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF8A50), // Orange terang
            Color(0xFFFF6B35), // Orange lebih gelap
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const PopupTambahUpdateJadwal(),
            );
          },
          child: const Icon(
            Icons.add_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}