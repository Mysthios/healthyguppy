import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/pages/auth_wrapper.dart';
import 'package:healthyguppy/services/app_initializer.dart';
import 'package:healthyguppy/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  // 1. WAJIB: Inisialisasi Flutter binding terlebih dahulu
  WidgetsFlutterBinding.ensureInitialized();
  
  await Permission.notification.request();
  
  // 2. Inisialisasi NotificationService setelah binding siap
  await NotificationService.init();

  
  // 3. Inisialisasi Firebase dan service lainnya
  await AppInitializer.initialize();
  
  // 4. Terakhir jalankan app dengan semua provider
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Healthy Guppy',
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}