import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/core/constant.dart';
import 'package:healthyguppy/provider/riverpod_provider.dart'; // Impor provider yang sudah dibuat

class PakanButton extends ConsumerWidget {
  const PakanButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // <-- perbaiki ini
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // rounded dialog
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/Peringatan.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Apakah anda yakin ingin mereset sisa pakan?\n\n'
                    'Pastikan sudah melakukan pengisian tabung pakan hingga penuh',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // Reset nilai sisa pakan
                            ref.read(sisaPakanProvider.notifier).state = 0; // <-- pakai ref.read
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
        child: Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/images/Pakan.png',
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }
}
