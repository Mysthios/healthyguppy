import 'package:flutter/material.dart';
import 'package:healthyguppy/core/constant.dart';

class JamPakan extends StatelessWidget {
  const JamPakan({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Jadwal Makanan",
          style: kTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kPrimaryTextColor,
          ),
        ),

        const SizedBox(height: 9),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/Jadwal.png',
              width: 50,
              height: 50,
            ),

            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "08.00 AM",
                  style: kTextStyle.copyWith(
                    fontSize: 33,
                    fontWeight: FontWeight.w500,
                    color: kSecondaryTextColor,
                  ),
                ),
                Text(
                  "Jadwal makan berikutnya",
                  style: kTextStyle.copyWith(
                    fontWeight: FontWeight.w400,
                    color: kSecondaryTextColor,
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
