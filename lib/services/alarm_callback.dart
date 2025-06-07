import 'package:flutter/material.dart';
import 'package:healthyguppy/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void alarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final title = prefs.getString('alarm_title') ?? 'Judul default';
  final body = prefs.getString('alarm_body') ?? 'Isi default';

  final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await NotificationService.showNotification(
    // id: id,
    title: title,
    body: body,
  );
}
