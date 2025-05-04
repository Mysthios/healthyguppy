import 'package:flutter/material.dart';
import 'package:healthyguppy/core/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/provider/riverpod_provider.dart';

class InfoCard extends ConsumerWidget {
  final String imagePath;
  final String title;
  final String value;

  const InfoCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext, WidgetRef ref) {
    ref.watch(sisaPakanProvider);
    ref.watch(temperaturProvider);

    return Container(
      width: 165,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: kTextStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(imagePath, width: 44, height: 34),
              const SizedBox(width: 8),
              Text(
                value, 
                style: kTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 33,
                  color: kSecondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
