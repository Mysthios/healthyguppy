import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/homepage/homepage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthyguppy/services/jadwal_checker_service.dart';
import 'package:healthyguppy/services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  await initializeDateFormatting('id_ID', null);
  final checker = JadwalCheckerService();
  checker.startChecking(); // Start cek otomatis
  runApp(ProviderScope(child: MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Guppy',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
