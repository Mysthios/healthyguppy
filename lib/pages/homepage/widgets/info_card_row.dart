// info_cards.dart - Modern Reset Design
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/provider/sisaPakan_provider.dart';
import 'package:healthyguppy/provider/suhu_provider.dart';
import 'package:healthyguppy/services/jadwal_checker_service.dart';

class InfoCards extends ConsumerStatefulWidget {
  const InfoCards({super.key});

  @override
  ConsumerState<InfoCards> createState() => _InfoCardsState();
}

class _InfoCardsState extends ConsumerState<InfoCards> 
    with TickerProviderStateMixin {
  bool _showResetButton = false;
  JadwalCheckerService? _jadwalCheckerService;
  
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation controllers for modern effects
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Start pulse animation when showing reset button
    _pulseController.repeat(reverse: true);
    
    // Initialize notification listener untuk suhu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(suhuNotificationProvider);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_jadwalCheckerService == null) {
      _jadwalCheckerService = JadwalCheckerService(
        providerContainer: ProviderScope.containerOf(context),
      );
    }
  }

  // 🌡️ Temperature helper methods
  Color _getTemperatureStatusColor(double temperature) {
    if (temperature < 24.0 || temperature > 28.0) return Colors.red;
    if (temperature < 25.0 || temperature > 27.0) return Colors.orange;
    return Colors.green;
  }

  IconData _getTemperatureStatusIcon(double temperature) {
    if (temperature < 24.0) return Icons.ac_unit;
    if (temperature > 28.0) return Icons.whatshot;
    if (temperature < 25.0 || temperature > 27.0) return Icons.warning_amber;
    return Icons.check_circle;
  }

  String _getTemperatureStatus(double temp) {
    if (temp < 24.0) return 'Terlalu Rendah';
    if (temp > 28.0) return 'Terlalu Tinggi';
    if (temp < 25.0 || temp > 27.0) return 'Perlu Perhatian';
    return 'Normal';
  }

  Color _getConnectionStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.error:
        return Colors.red;
    }
  }

  String _getConnectionStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Terhubung';
      case ConnectionStatus.connecting:
        return 'Menghubungkan';
      case ConnectionStatus.disconnected:
        return 'Terputus';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  // 🍽️ Pakan helper methods
  Color _getPakanStatusColor(int sisaPakan) {
    if (sisaPakan <= 0) return Colors.red;
    if (sisaPakan <= 35) return Colors.orange;
    if (sisaPakan <= 70) return Colors.yellow[700]!;
    return Colors.green;
  }

  IconData _getPakanStatusIcon(int sisaPakan) {
    if (sisaPakan <= 0) return Icons.warning;
    if (sisaPakan <= 35) return Icons.error_outline;
    if (sisaPakan <= 70) return Icons.info_outline;
    return Icons.check_circle;
  }

  // 🍽️ Modern Pakan dialogs
  void _showPakanMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
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
              const SizedBox(height: 24),
              
              const Text(
                'Kelola Pakan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              
              // Modern menu item
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _showModernResetDialog();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade50, 
                        Colors.orange.shade100
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reset Sisa Pakan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kembalikan ke kapasitas maksimal',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.orange,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showModernResetDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: AlwaysStoppedAnimation<double>(Curves.elasticOut.transform(anim1.value)),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
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
                  // Icon with gradient background
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.orange.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Reset Sisa Pakan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Apakah Anda yakin ingin mereset sisa pakan ke kapasitas maksimal?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Modern buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(sisaPakanProvider.notifier).resetPakan();
                            Navigator.of(context).pop();
                            
                            // Hide reset button and return to normal view
                            setState(() {
                              _showResetButton = false;
                            });
                            
                            // Modern snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Sisa pakan berhasil direset',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sisaPakan = ref.watch(sisaPakanProvider);
    final sisaPakanNotifier = ref.read(sisaPakanProvider.notifier);
    
    // Watch suhu stream dan connection status
    final suhuAsyncValue = ref.watch(suhuStreamProvider);
    final connectionStatus = ref.watch(connectionStatusProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🍽️ Info Card Sisa Pakan with Modern Reset Design
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                setState(() {
                  _showResetButton = !_showResetButton;
                });
                // Haptic feedback
                // HapticFeedback.mediumImpact();
              },
              onTap: () {
                if (_showResetButton) {
                  _showModernResetDialog();
                } else {
                  _showPakanMenu();
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(0, 0.3), end: Offset.zero),
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _showResetButton 
                  ? AnimatedBuilder(
                      key: const ValueKey('modern_reset'),
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: GestureDetector(
                            onTapDown: (_) => _scaleController.forward(),
                            onTapUp: (_) => _scaleController.reverse(),
                            onTapCancel: () => _scaleController.reverse(),
                            child: AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.orange.shade400,
                                          Colors.orange.shade600,
                                          Colors.orange.shade800,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.2),
                                          blurRadius: 40,
                                          offset: const Offset(0, 16),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Animated background pattern
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.1),
                                                  Colors.transparent,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        // Floating particles effect
                                        Positioned(
                                          top: 10,
                                          right: 15,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.3),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 30,
                                          right: 25,
                                          child: Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.4),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          left: 20,
                                          child: Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        
                                        // Main content
                                        Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Modern refresh icon dengan glow effect
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.3),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white.withOpacity(0.2),
                                                      blurRadius: 12,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.refresh_rounded,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                              
                                              const SizedBox(height: 12),
                                              
                                              const Text(
                                                'Reset Pakan',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              
                                              const SizedBox(height: 4),
                                              
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'Tap untuk reset',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      key: const ValueKey('normal'),
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getPakanStatusColor(sisaPakan).withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getPakanStatusColor(sisaPakan).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _getPakanStatusColor(sisaPakan),
                            ),
                            child: Text('${sisaPakan}x'),
                          ),
                          
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.grey[200],
                            ),
                            child: AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              widthFactor: (sisaPakan / sisaPakanNotifier.kapasitasMaksimal).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: _getPakanStatusColor(sisaPakan),
                                ),
                              ),
                            ),
                          ),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sisaPakanNotifier.statusPakan,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getPakanStatusColor(sisaPakan),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Tap untuk kelola',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey[400],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 🌡️ Info Card Temperatur (Firebase Stream) - unchanged
          Expanded(
            child: suhuAsyncValue.when(
              data: (suhuData) {
                final temperatur = suhuData.suhu;
                
                return Container(
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getTemperatureStatusColor(temperatur).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getTemperatureStatusColor(temperatur).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header dengan connection status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Suhu',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              // Connection status indicator
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getConnectionStatusColor(connectionStatus),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getConnectionStatusColor(connectionStatus).withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _getTemperatureStatusIcon(temperatur),
                            color: _getTemperatureStatusColor(temperatur),
                            size: 20,
                          ),
                        ],
                      ),
                      
                      // Temperature value dengan animasi
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _getTemperatureStatusColor(temperatur),
                        ),
                        child: Text('${temperatur.toStringAsFixed(1)}°C'),
                      ),
                      
                      // Temperature range indicator
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.grey[200],
                        ),
                        child: Stack(
                          children: [
                            // Ideal zone indicator (24-28°C)
                            Positioned(
                              left: MediaQuery.of(context).size.width * 0.15 * 0.33,
                              width: MediaQuery.of(context).size.width * 0.15 * 0.33,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                            ),
                            // Current temperature indicator
                            AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              widthFactor: ((temperatur - 20.0) / 12.0).clamp(0.0, 1.0),
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: _getTemperatureStatusColor(temperatur),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Status dan connection info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getTemperatureStatus(temperatur),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getTemperatureStatusColor(temperatur),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.sensors,
                                size: 8,
                                color: _getConnectionStatusColor(connectionStatus),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _getConnectionStatusText(connectionStatus),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: _getConnectionStatusColor(connectionStatus),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Menghubungkan...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stack) => Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Koneksi Error',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Tap untuk retry',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}