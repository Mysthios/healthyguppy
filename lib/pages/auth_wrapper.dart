import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/pages/login/loginpage.dart';
import 'package:healthyguppy/pages/homepage/homepage.dart';
import 'package:healthyguppy/provider/jadwal_provider.dart';
import 'package:healthyguppy/services/jadwal_checker_service.dart'; // Import jadwal checker

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _splashFinished = false;
  Timer? _splashTimer;
  JadwalCheckerService? _jadwalChecker;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
    _initJadwalChecker();
  }

  void _initJadwalChecker() {
    _jadwalChecker = JadwalCheckerService();
  }

  void _startSplashTimer() {
    print('AuthWrapper: Starting 5 second splash timer...');

    // Reset state
    _splashFinished = false;

    // Cancel existing timer if any
    _splashTimer?.cancel();

    // Start new timer
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
    // Restart timer on hot reload
    if (!_splashFinished) {
      print('AuthWrapper: Hot reload detected, restarting splash timer');
      _startSplashTimer();
    }
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

    // Listen to auth state changes untuk handle jadwal checker
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, current) {
      current.when(
        data: (user) {
          if (user != null) {
            // User login, start jadwal checker
            print('AuthWrapper: User logged in, starting jadwal checker');
            _jadwalChecker?.restartForUser();
          } else {
            // User logout, stop jadwal checker
            print('AuthWrapper: User logged out, stopping jadwal checker');
            _jadwalChecker?.stopChecking();
            // Clear jadwal dari state
            ref.read(jadwalListProvider.notifier).clearJadwal();
          }
        },
        loading: () {
          // Loading state
        },
        error: (error, stack) {
          print('AuthWrapper: Auth error: $error');
          _jadwalChecker?.stopChecking();
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
      print(
        'AuthWrapper: Showing splash - timer: $_splashFinished, auth: $authResolved',
      );
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
              // Animated Logo/Icon
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

              // App Title
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

              // Loading Indicator
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
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

// Widget untuk melindungi halaman yang memerlukan authentication
class RequireAuth extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const RequireAuth({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (isLoggedIn) {
      return child;
    } else {
      return fallback ?? 
        const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Anda harus login terlebih dahulu',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Silakan login untuk mengakses fitur ini',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
    }
  }
}