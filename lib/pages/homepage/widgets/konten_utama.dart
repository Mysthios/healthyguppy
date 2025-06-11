// 3. KontenUtama - Modern Main Content
import 'package:flutter/material.dart';
import 'package:healthyguppy/pages/homepage/widgets/info_card_row.dart';
import 'package:healthyguppy/pages/homepage/widgets/jadwal_pakan_card.dart';

class KontenUtama extends StatelessWidget {
  const KontenUtama({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info Cards (existing modern design)
          const InfoCards(),
          
          const SizedBox(height: 20),
          
          // Modern Schedule Section (new)
          const ModernScheduleSection(),
          
          // Add some bottom spacing for better scrolling
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}