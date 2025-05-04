import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/notifikasi/notifikasipage.dart';

class NotificationHeaderHomepage extends StatelessWidget {
  const NotificationHeaderHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
      child: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Notifikasipage()),
            );
          },
          child: Image.asset(
            'assets/images/Notification.png',
            width: 32,
            height: 32,
          ),
        ),
      ),
    );
  }
}
