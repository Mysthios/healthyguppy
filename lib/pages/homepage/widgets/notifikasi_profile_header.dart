import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/notifikasi/notifikasipage.dart';
import 'package:healthyguppy/pages/profile/profile_page.dart';

class NotificationProfileHeader extends StatelessWidget {
  const NotificationProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Icon (Left)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ),
          
          // Notification Icon (Right)
          GestureDetector(
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
        ],
      ),
    );
  }
}