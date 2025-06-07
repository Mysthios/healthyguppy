import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/pages/auth_wrapper.dart';
import 'package:healthyguppy/services/app_initializer.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // PENTING: Tunggu inisialisasi Firebase selesai SEBELUM runApp
  await AppInitializer.initialize();
  
  // Baru jalankan app setelah semua service siap
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