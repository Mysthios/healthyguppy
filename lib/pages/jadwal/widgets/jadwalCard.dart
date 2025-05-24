import 'package:flutter/material.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
import 'package:healthyguppy/core/constant.dart';

class JadwalCard extends StatelessWidget {
  final JadwalModel jadwal;
  final bool isActive;
  final VoidCallback onToggle;

  const JadwalCard({
    Key? key,
    required this.jadwal,
    required this.isActive,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${jadwal.jam.toString().padLeft(2, '0')}:${jadwal.menit.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  jadwal.hari.join(', '),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            Switch(
              value: isActive,
              onChanged: (val) {
                onToggle(); // akan dipanggil dari parent
              },
              activeColor: kPrimaryColor,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
