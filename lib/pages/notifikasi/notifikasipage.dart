// pages/notifikasi/notifikasipage.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/provider/notifikasi_provider.dart';
import 'package:intl/intl.dart';

class Notifikasipage extends ConsumerWidget {
  const Notifikasipage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifs = ref.watch(notifikasiListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Notifikasi')),
      body: asyncNotifs.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return const Center(child: Text('Belum ada notifikasi.'));
          }
          return ListView.builder(
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final notif = notifs[index];
              return ListTile(
                title: Text(notif.judul ?? ''),
                subtitle: Text(notif.isi ?? ''),
                trailing: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(notif.waktu),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
