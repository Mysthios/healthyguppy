import 'package:flutter/material.dart';
import 'package:healthyguppy/core/constant.dart';
import 'package:healthyguppy/pages/homepage/widgets/notifikasi_profile_header.dart';

class HeaderDanSalam extends StatelessWidget {
  const HeaderDanSalam({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        NotificationProfileHeader(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hai",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              Text(
                "Semoga Harimu Menyenangkan",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
