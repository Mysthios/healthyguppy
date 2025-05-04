import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/homepage/widgets/info_card_row.dart';
import 'package:healthyguppy/pages/homepage/widgets/jadwal_pakan_card.dart';
import 'package:healthyguppy/pages/homepage/widgets/pakan_button.dart';

class KontenUtama extends StatelessWidget {
  const KontenUtama({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            PakanButton(),
            SizedBox(height: 16),
            InfoCards(),
            SizedBox(height: 16),
            JadwalPakanCard(),
          ],
        ),
      ),
    );
  }
}
