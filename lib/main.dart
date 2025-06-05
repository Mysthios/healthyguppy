import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthyguppy/firebase_options.dart';
import 'package:healthyguppy/pages/auth_wrapper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:healthyguppy/services/firebase_service.dart';
import 'package:healthyguppy/services/notification_service.dart';
import 'package:healthyguppy/services/jadwal_checker_service.dart';
import 'package:healthyguppy/services/background_task.dart'; // versi background_service
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi semua service
  await AndroidAlarmManager.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  await initializeDateFormatting('id_ID', null);
  await initializeBackgroundService();

  // Ambil jadwal dari Firebase
  final firebaseService = FirebaseService();
  final notificationService = NotificationService();
  final prefs = await SharedPreferences.getInstance();
  final activeNotifs = await firebaseService.getActiveSchedules();

  for (var notif in activeNotifs) {
    final id = notif.waktu.millisecondsSinceEpoch ~/ 1000;

    // Simpan isi alarm ke SharedPreferences
    await prefs.setString('alarm_title_$id', notif.judul);
    await prefs.setString('alarm_body_$id', notif.isi);

    // Jadwalkan notifikasi
    await notificationService.scheduleNotification(
      id: id,
      title: notif.judul,
      body: notif.isi,
      scheduledDate: notif.waktu,
    );

    // Jadwalkan alarm
    await AndroidAlarmManager.oneShotAt(
      notif.waktu,
      id,
      alarmCallback,
      exact: true,
      wakeup: true,
    );
  }

  // Start background checker
  final checker = JadwalCheckerService();
  checker.startChecking();

  // Jalankan aplikasi
  runApp(const ProviderScope(child: MyApp()));
}

/// Fungsi yang akan dipanggil saat alarm berbunyi
@pragma('vm:entry-point')
void alarmCallback() async {
  final prefs = await SharedPreferences.getInstance();

  // Contoh: Ambil data terakhir yang disimpan
  // Jika kamu ingin alarm yang berbeda-beda, ambil berdasarkan ID alarm juga
  final title = prefs.getString('alarm_title_0') ?? 'Alarm!';
  final body = prefs.getString('alarm_body_0') ?? 'Waktunya memberi makan ikan!';
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: backgroundTaskEntryPoint,
      isForegroundMode: true,
      autoStart: true,
      foregroundServiceNotificationId: 777,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Healthy Guppy Aktif',
      initialNotificationContent: 'Mengecek jadwal harian...',
    ),  
    iosConfiguration: IosConfiguration(
      onForeground: (service) {},
      onBackground: (_) async => true,
    ),
  );
  await service.startService();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Guppy',
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}
