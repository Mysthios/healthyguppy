import 'package:flutter/material.dart';
import 'package:healthyguppy/core/constant.dart';
import 'package:healthyguppy/pages/homepage/widgets/notifikasi_profile_header.dart';

class HeaderDanSalam extends StatelessWidget {
  const HeaderDanSalam({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize =
        screenWidth < 360
            ? 28.0
            : screenWidth < 400
            ? 32.0
            : 35.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NotificationProfileHeader(hasNewNotification: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hai",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Semoga Harimu Menyenangkan",
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryTextColor,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
