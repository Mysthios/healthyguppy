// info_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/pages/homepage/widgets/info_cards.dart';
import 'package:healthyguppy/provider/riverpod_provider.dart';
import 'package:healthyguppy/services/jadwal_checker_service.dart';

class InfoCards extends ConsumerStatefulWidget {
  const InfoCards({super.key});

  @override
  ConsumerState<InfoCards> createState() => _InfoCardsState();
}

class _InfoCardsState extends ConsumerState<InfoCards> {
  bool _showResetButton = false;
  JadwalCheckerService? _jadwalCheckerService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 🔥 PINDAHKAN INISIALISASI KE didChangeDependencies
    // Ini dipanggil setelah widget tree sepenuhnya tersedia
    if (_jadwalCheckerService == null) {
      _jadwalCheckerService = JadwalCheckerService(
        providerContainer: ProviderScope.containerOf(context),
      );
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon dengan background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Reset Sisa Pakan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Content
              Text(
                'Apakah Anda yakin ingin mereset sisa pakan?\n\nPastikan Anda sudah mengisi tabung pakan hingga penuh.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _showResetButton = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4757), Color(0xFFFF3742)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4757).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            // 🔥 Reset pakan menggunakan JadwalCheckerService
                            await _jadwalCheckerService?.resetPakan();
                            
                            Navigator.of(context).pop();
                            setState(() {
                              _showResetButton = false;
                            });
                            
                            // Show success message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 12),
                                      Text('Sisa pakan berhasil direset'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            Navigator.of(context).pop();
                            setState(() {
                              _showResetButton = false;
                            });
                            
                            // Show error message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.error, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text('Gagal reset pakan: $e'),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 Method untuk menampilkan dialog isi pakan manual
  void _showIsiPakanDialog() {
    int jumlahPakan = 10; // Default 10
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Isi Pakan Manual',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Input jumlah pakan
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (jumlahPakan > 1) {
                          setDialogState(() {
                            jumlahPakan--;
                          });
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.orange,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$jumlahPakan',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (jumlahPakan < 50) { // Max 50
                          setDialogState(() {
                            jumlahPakan++;
                          });
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await _jadwalCheckerService?.isiPakan(jumlah: jumlahPakan);
                            Navigator.of(context).pop();
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Berhasil menambah $jumlahPakan pakan'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            Navigator.of(context).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menambah pakan: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Isi Pakan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 Method untuk mendapatkan warna berdasarkan status pakan
  Color _getPakanStatusColor(int sisaPakan) {
    if (sisaPakan <= 0) return Colors.red;
    if (sisaPakan <= 10) return Colors.orange;
    if (sisaPakan <= 20) return Colors.yellow[700]!;
    return Colors.green;
  }

  // 🔥 Method untuk mendapatkan icon berdasarkan status pakan
  IconData _getPakanStatusIcon(int sisaPakan) {
    if (sisaPakan <= 0) return Icons.warning;
    if (sisaPakan <= 10) return Icons.error_outline;
    if (sisaPakan <= 20) return Icons.info_outline;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Watch sisa pakan dari provider
    final sisaPakan = ref.watch(sisaPakanProvider);
    final sisaPakanNotifier = ref.read(sisaPakanProvider.notifier);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // InfoCard Sisa Pakan dengan Long Press
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                setState(() {
                  _showResetButton = !_showResetButton;
                });
              },
              onTap: () {
                // 🔥 Tap untuk menampilkan menu pakan
                _showPakanMenu();
              },
              child: _showResetButton 
                ? Container(
                    height: 120, // Sesuaikan dengan tinggi InfoCard
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: _showResetDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: const Center(
                        child: Text(
                          'Reset Sisa Pakan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: 120,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header dengan icon status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sisa Pakan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            Icon(
                              _getPakanStatusIcon(sisaPakan),
                              color: _getPakanStatusColor(sisaPakan),
                              size: 20,
                            ),
                          ],
                        ),
                        
                        // Value dengan warna dinamis
                        Text(
                          '${sisaPakan}x',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _getPakanStatusColor(sisaPakan),
                          ),
                        ),
                        
                        // Status bar
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.grey[200],
                          ),
                          child: FractionallySizedBox(
                            widthFactor: (sisaPakan / sisaPakanNotifier.kapasitasMaksimal).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: _getPakanStatusColor(sisaPakan),
                              ),
                            ),
                          ),
                        ),
                        
                        // Status text
                        Text(
                          sisaPakanNotifier.statusPakan,
                          style: TextStyle(
                            fontSize: 10,
                            color: _getPakanStatusColor(sisaPakan),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 16),
          // InfoCard Temperatur (tidak berubah)
          const Expanded(
            child: InfoCard(
              imagePath: 'assets/images/Temperatur.png',
              title: "Temperatur",
              value: "19°C", // This will be dynamically updated by Riverpod
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Method untuk menampilkan menu pakan
  void _showPakanMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Kelola Pakan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Info status pakan
            Consumer(
              builder: (context, ref, child) {
                final sisaPakan = ref.watch(sisaPakanProvider);
                final status = _jadwalCheckerService?.getStatusPakan();
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sisa Pakan:'),
                          Text(
                            '${sisaPakan}x',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getPakanStatusColor(sisaPakan),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status:'),
                          Text(
                            status?['statusPakan'] ?? 'Normal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getPakanStatusColor(sisaPakan),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Menu buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showIsiPakanDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Isi Pakan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showResetDialog,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // 🔥 Debug/Test button (bisa dihapus di production)
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await _jadwalCheckerService?.testKurangiPakan();
                Navigator.of(context).pop();
              },
              child: const Text('🧪 Test Kurangi Pakan'),
            ),
          ],
        ),
      ),
    );
  }
}