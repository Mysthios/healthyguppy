import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/homepage/widgets/header_dan_salam.dart';
import 'package:healthyguppy/pages/homepage/widgets/konten_utama.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: const [
              HeaderDanSalam(),
              KontenUtama(),
            ],
          ),
        ),
      ),
    );
  }
}
