import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/pages/login/loginpage.dart';
import 'package:healthyguppy/pages/homepage/homepage.dart';
import 'package:healthyguppy/provider/jadwal_provider.dart';
import 'package:healthyguppy/provider/sisaPakan_provider.dart';
import 'package:healthyguppy/services/jadwal_checker_service.dart';

// ✅ SOLUSI TERBAIK: Gunakan Provider untuk JadwalCheckerService
final jadwalCheckerServiceProvider = Provider<JadwalCheckerService>((ref) {
  return JadwalCheckerService(providerContainer: ref.container);
});

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _splashFinished = false;
  Timer? _splashTimer;
  
  // ✅ Tidak perlu instance variable lagi, langsung gunakan provider

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
    print('🚀 AuthWrapper initialized');
  }

  void _startSplashTimer() {
    print('AuthWrapper: Starting 5 second splash timer...');
    _splashFinished = false;
    _splashTimer?.cancel();

    _splashTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        print('AuthWrapper: Splash timer completed!');
        setState(() {
          _splashFinished = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(AuthWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_splashFinished) {
      print('AuthWrapper: Hot reload detected, restarting splash timer');
      _startSplashTimer();
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    // ✅ Stop jadwal checker saat dispose
    try {
      final jadwalChecker = ref.read(jadwalCheckerServiceProvider);
      jadwalChecker.stopChecking();
    } catch (e) {
      print('Error stopping jadwal checker: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // ✅ Listen to auth state changes
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, current) {
      current.when(
        data: (user) {
          if (user != null) {
            // User login, start jadwal checker
            print('AuthWrapper: User logged in, starting jadwal checker');
            
            // ✅ Gunakan provider untuk mengakses JadwalCheckerService
            try {
              final jadwalChecker = ref.read(jadwalCheckerServiceProvider);
              jadwalChecker.restartForUser();
              
              // Print status pakan saat user login
              final statusPakan = jadwalChecker.getStatusPakan();
              print('🍽️ Status pakan saat login: $statusPakan');
            } catch (e) {
              print('❌ Error starting jadwal checker: $e');
            }
          } else {
            // User logout, stop jadwal checker
            print('AuthWrapper: User logged out, stopping jadwal checker');
            
            try {
              final jadwalChecker = ref.read(jadwalCheckerServiceProvider);
              jadwalChecker.stopChecking();
              // Clear jadwal dari state
              ref.read(jadwalListProvider.notifier).clearJadwal();
            } catch (e) {
              print('❌ Error stopping jadwal checker: $e');
            }
          }
        },
        loading: () {
          // Loading state - tidak perlu action
        },
        error: (error, stack) {
          print('AuthWrapper: Auth error: $error');
          try {
            final jadwalChecker = ref.read(jadwalCheckerServiceProvider);
            jadwalChecker.stopChecking();
          } catch (e) {
            print('Error stopping jadwal checker on auth error: $e');
          }
        },
      );
    });

    // Show splash until timer finished AND auth resolved
    final authResolved = authState.when(
      data: (_) => true,
      loading: () => false,
      error: (_, __) => true,
    );

    if (!_splashFinished || !authResolved) {
      print('AuthWrapper: Showing splash - timer: $_splashFinished, auth: $authResolved');
      return const AnimatedSplashScreen();
    }

    // After splash finished, check authentication
    final user = authState.asData?.value;

    if (user != null) {
      print('AuthWrapper: User authenticated, showing HomePage');
      return const HomePage(key: ValueKey('homepage'));
    } else {
      print('AuthWrapper: User not authenticated, showing LoginPage');
      return const LoginPage(key: ValueKey('loginpage'));
    }
  }
}

// ✅ ALTERNATIF SOLUSI: Jika ingin tetap menggunakan manual initialization
class AuthWrapperManual extends ConsumerStatefulWidget {
  const AuthWrapperManual({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapperManual> createState() => _AuthWrapperManualState();
}

class _AuthWrapperManualState extends ConsumerState<AuthWrapperManual> {
  bool _splashFinished = false;
  Timer? _splashTimer;
  JadwalCheckerService? _jadwalChecker;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
    
    // ✅ Delay initialization hingga setelah first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initJadwalChecker();
    });
  }

  void _initJadwalChecker() {
    if (_isInitialized) return;
    
    try {
      // ✅ Gunakan ProviderScope.containerOf setelah widget selesai di-build
      final container = ProviderScope.containerOf(context);
      _jadwalChecker = JadwalCheckerService(
        providerContainer: container,
      );
      _isInitialized = true;
      print('🚀 JadwalChecker initialized with ProviderContainer');
    } catch (e) {
      print('❌ Error initializing JadwalChecker: $e');
      // Retry setelah delay
      Timer(const Duration(milliseconds: 100), () {
        if (mounted && !_isInitialized) {
          _initJadwalChecker();
        }
      });
    }
  }

  void _startSplashTimer() {
    print('AuthWrapper: Starting 5 second splash timer...');
    _splashFinished = false;
    _splashTimer?.cancel();

    _splashTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        print('AuthWrapper: Splash timer completed!');
        setState(() {
          _splashFinished = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _jadwalChecker?.stopChecking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Ensure jadwal checker is initialized
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initJadwalChecker();
      });
    }

    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, current) {
      current.when(
        data: (user) {
          if (user != null && _jadwalChecker != null) {
            print('AuthWrapper: User logged in, starting jadwal checker');
            _jadwalChecker!.restartForUser();
            
            final statusPakan = _jadwalChecker!.getStatusPakan();
            print('🍽️ Status pakan saat login: $statusPakan');
          } else if (user == null && _jadwalChecker != null) {
            print('AuthWrapper: User logged out, stopping jadwal checker');
            _jadwalChecker!.stopChecking();
            ref.read(jadwalListProvider.notifier).clearJadwal();
          }
        },
        loading: () {},
        error: (error, stack) {
          print('AuthWrapper: Auth error: $error');
          _jadwalChecker?.stopChecking();
        },
      );
    });

    final authResolved = authState.when(
      data: (_) => true,
      loading: () => false,
      error: (_, __) => true,
    );

    if (!_splashFinished || !authResolved) {
      return const AnimatedSplashScreen();
    }

    final user = authState.asData?.value;

    if (user != null) {
      return const HomePage(key: ValueKey('homepage'));
    } else {
      return const LoginPage(key: ValueKey('loginpage'));
    }
  }
}

// ✅ SOLUSI 3: StateNotifierProvider untuk state management yang lebih baik
final jadwalCheckerStateProvider = StateNotifierProvider<JadwalCheckerNotifier, JadwalCheckerState>((ref) {
  return JadwalCheckerNotifier(ref.container);
});

class JadwalCheckerState {
  final bool isRunning;
  final String? lastStatus;
  final bool isInitialized;
  
  const JadwalCheckerState({
    this.isRunning = false,
    this.lastStatus,
    this.isInitialized = false,
  });
  
  JadwalCheckerState copyWith({
    bool? isRunning,
    String? lastStatus,
    bool? isInitialized,
  }) {
    return JadwalCheckerState(
      isRunning: isRunning ?? this.isRunning,
      lastStatus: lastStatus ?? this.lastStatus,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class JadwalCheckerNotifier extends StateNotifier<JadwalCheckerState> {
  final ProviderContainer container;
  JadwalCheckerService? _service;
  
  JadwalCheckerNotifier(this.container) : super(const JadwalCheckerState()) {
    _initialize();
  }
  
  void _initialize() {
    try {
      _service = JadwalCheckerService(providerContainer: container);
      state = state.copyWith(isInitialized: true);
      print('🚀 JadwalChecker StateNotifier initialized');
    } catch (e) {
      print('❌ Error initializing JadwalChecker StateNotifier: $e');
    }
  }
  
  void startForUser() {
    if (_service != null) {
      _service!.restartForUser();
      state = state.copyWith(isRunning: true);
      print('✅ JadwalChecker started for user');
    }
  }
  
  void stop() {
    if (_service != null) {
      _service!.stopChecking();
      state = state.copyWith(isRunning: false);
      print('🛑 JadwalChecker stopped');
    }
  }
  
  Map<String, dynamic>? getStatusPakan() {
    return _service?.getStatusPakan();
  }
  
  @override
  void dispose() {
    _service?.stopChecking();
    super.dispose();
  }
}

// Tetap sama untuk class lainnya...
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({Key? key}) : super(key: key);

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    print('AnimatedSplashScreen: Splash screen displayed');
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    print('AnimatedSplashScreen: Splash screen disposed');
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade600,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        child: Image.asset(
                          'assets/images/Heppy_Logo.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Column(
                      children: [
                        Text(
                          'Healthy Guppy',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Rawat Ikan Guppy Anda',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Column(
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Memuat aplikasi...',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}