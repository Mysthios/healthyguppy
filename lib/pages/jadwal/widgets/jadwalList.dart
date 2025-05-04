import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/pages/jadwal/widgets/jadwalCard.dart';
import 'package:healthyguppy/pages/jadwal/widgets/popupJadwal.dart';
import 'package:healthyguppy/provider/jadwal_provider.dart';

class JadwalList extends ConsumerWidget {
  const JadwalList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jadwalList = ref.watch(jadwalListProvider);

    return ListView.builder(
      itemCount: jadwalList.length,
      itemBuilder: (context, index) {
        final jadwal = jadwalList[index];

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return PopupTambahUpdateJadwal(
                  index: index,
                  existingJadwal: jadwal,
                );
              },
            );
          },
          child: JadwalCard(
            jadwal: jadwal,
            isActive: true, // atau sesuai logika on/off kamu
            onToggle: () {
              // logic toggle switch kalau ada
            },
          ),
        );
      },
    );
  }
}
