import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/homepage/homepage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthyguppy/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final notificationService = NotificationService();
  await notificationService.initialize(); // ✅ Panggil method initialize() dari OOP class
  
  runApp(const ProviderScope(child: MyApp()));
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
