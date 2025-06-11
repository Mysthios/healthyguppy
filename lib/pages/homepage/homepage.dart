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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              // Changed from Column with Expanded to Column with mainAxisSize.min
              child: const Column(
                mainAxisSize: MainAxisSize.min, // This is the key fix
                children: [
                  HeaderDanSalam(),
                  KontenUtama(), // Removed Expanded wrapper
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}