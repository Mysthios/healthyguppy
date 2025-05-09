import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/pages/notifikasi/widgets/headerNotifikasi.dart';
import 'package:healthyguppy/models/notifikasi_model.dart';
import 'package:healthyguppy/provider/notifikasi_provider.dart';
import 'package:healthyguppy/services/notification_service.dart';

class Notifikasipage extends ConsumerStatefulWidget {
  const Notifikasipage({super.key});

  @override
  ConsumerState<Notifikasipage> createState() => _NotifikasipageState();
}

class _NotifikasipageState extends ConsumerState<Notifikasipage> {
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();

  final NotificationService _notificationService = NotificationService(); // ✅ instance NotificationService

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderNotifikasi(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _judulController,
                    decoration: const InputDecoration(labelText: 'Judul Notifikasi'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _isiController,
                    decoration: const InputDecoration(labelText: 'Isi Notifikasi'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final scheduledTime = now.add(const Duration(seconds: 10));

                      final notif = NotifikasiModel(
                        judul: _judulController.text,
                        isi: _isiController.text,
                        waktu: scheduledTime,
                      );

                      // Simpan ke Firebase
                      ref.read(addNotificationProvider)(notif);

                      // Jadwalkan notifikasi lokal
                      await _notificationService.scheduleNotification(
                        id: scheduledTime.millisecondsSinceEpoch ~/ 1000,
                        title: notif.judul,
                        body: notif.isi,
                        scheduledDate: scheduledTime,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifikasi dijadwalkan!')),
                      );
                    },
                    child: const Text('Simpan & Jadwalkan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
