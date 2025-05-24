import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/models/jadwal_model.dart';
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
              builder:
                  (_) => PopupTambahUpdateJadwal(
                    index: index,
                    existingJadwal: jadwal,
                  ),
            );
          },
          child: JadwalCard(
            jadwal: jadwal,
            isActive: jadwal.isActive,
            onToggle: () async {
              final updatedJadwal = JadwalModel(
                id: jadwal.id,
                jam: jadwal.jam,
                menit: jadwal.menit,
                hari: jadwal.hari,
                isActive: !jadwal.isActive, // Toggle nilainya
              );

              await ref
                  .read(jadwalListProvider.notifier)
                  .updateJadwal(jadwal.id!, updatedJadwal);
            },
          ),
        );
      },
    );
  }
}
