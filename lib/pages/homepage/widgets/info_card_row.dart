// info_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/pages/homepage/widgets/info_cards.dart';

class InfoCards extends ConsumerWidget {
  const InfoCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          InfoCard(
            imagePath: 'assets/images/Guppy.png',
            title: "Sisa Pakan",
            value: "130x", // This will be dynamically updated by Riverpod
          ),
          SizedBox(width: 16),
          InfoCard(
            imagePath: 'assets/images/Temperatur.png',
            title: "Temperatur",
            value: "19°C", // This will be dynamically updated by Riverpod
          ),
        ],
      ),
    );
  }
}
