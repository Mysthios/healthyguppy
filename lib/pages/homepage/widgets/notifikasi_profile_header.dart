import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/notifikasi/notifikasipage.dart';
import 'package:healthyguppy/pages/profile/profile_page.dart';

class NotificationProfileHeader extends StatelessWidget {
  const NotificationProfileHeader({
    super.key,
    this.hasNewNotification = false, // Parameter untuk menandai ada notifikasi baru
  });

  final bool hasNewNotification;

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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.blue.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 22,
                color: Color(0xFF2196F3), // Warna biru modern
              ),
            ),
          ),
          
          // Notification Icon (Right) with Badge
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notifikasipage()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  // Main notification container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      size: 22,
                      color: Color(0xFF2196F3), // Warna biru modern
                    ),
                  ),
                  
                  // Red dot indicator for new notifications
                  if (hasNewNotification)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252), // Red color for notification badge
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
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