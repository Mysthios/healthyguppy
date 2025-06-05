// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:healthyguppy/pages/login/loginpage.dart';
// import 'package:healthyguppy/pages/homepage/homepage.dart';
// import 'package:healthyguppy/provider/auth_provider.dart';

// // PENTING: Provider untuk auth state stream
// final authStateProvider = StreamProvider<User?>((ref) {
//   final authService = ref.watch(authServiceProvider);
//   print('AuthStateProvider: Creating stream from authService'); // Debug
  
//   // Pastikan AuthService Anda memiliki getter authStateChanges
//   return authService.authStateChanges;
// });

// class AuthWrapper extends ConsumerWidget {
//   const AuthWrapper({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authStateProvider);

//     print('AuthWrapper: Building widget'); // Debug

//     return authState.when(
//       data: (user) {
//         print('AuthWrapper: Received user data - ${user?.email}'); // Debug
        
//         if (user != null) {
//           print('AuthWrapper: User is authenticated, showing HomePage'); // Debug
//           return const HomePage();
//         } else {
//           print('AuthWrapper: User is null, showing LoginPage'); // Debug
//           return const LoginPage();
//         }
//       },
//       loading: () {
//         print('AuthWrapper: Auth state is loading'); // Debug
//         return const Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 Text('Memuat...'),
//               ],
//             ),
//           ),
//         );
//       },
//       error: (error, stack) {
//         print('AuthWrapper: Auth state error - $error'); // Debug
//         print('AuthWrapper: Stack trace - $stack'); // Debug
//         return Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.error_outline,
//                   size: 64,
//                   color: Colors.red,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Terjadi kesalahan: $error',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     print('AuthWrapper: Refreshing auth state provider'); // Debug
//                     ref.refresh(authStateProvider);
//                   },
//                   child: const Text('Coba Lagi'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:healthyguppy/pages/login/loginpage.dart';
// // import 'package:healthyguppy/pages/homepage/homepage.dart';
// // import 'package:healthyguppy/provider/auth_provider.dart';

// // // PERBAIKAN: Provider untuk auth state stream dengan lebih detail
// // final authStateProvider = StreamProvider<User?>((ref) {
// //   final authService = ref.watch(authServiceProvider);
// //   print('🔄 AuthStateProvider: Creating NEW stream from authService');
  
// //   // Return stream dengan tambahan logging
// //   return authService.authStateChanges.map((user) {
// //     print('🔥 AuthStateProvider: Stream emitted user = ${user?.email ?? 'NULL'}');
// //     return user;
// //   });
// // });

// // class AuthWrapper extends ConsumerWidget {
// //   const AuthWrapper({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     print('🏗️ AuthWrapper: Building widget (REBUILD)');
    
// //     final authState = ref.watch(authStateProvider);

// //     return authState.when(
// //       data: (user) {
// //         print('📊 AuthWrapper: Received user data');
// //         print('   - User: ${user?.email ?? 'NULL'}');
// //         print('   - UID: ${user?.uid ?? 'NULL'}');
        
// //         if (user != null) {
// //           print('✅ AuthWrapper: User AUTHENTICATED -> Showing HomePage');
// //           return const HomePage();
// //         } else {
// //           print('❌ AuthWrapper: User NOT authenticated -> Showing LoginPage');
// //           return const LoginPage();
// //         }
// //       },
// //       loading: () {
// //         print('⏳ AuthWrapper: Auth state LOADING');
// //         return const Scaffold(
// //           body: Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 CircularProgressIndicator(),
// //                 SizedBox(height: 16),
// //                 Text('Memuat...'),
// //                 SizedBox(height: 8),
// //                 Text('Checking authentication...', 
// //                      style: TextStyle(fontSize: 12, color: Colors.grey)),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //       error: (error, stack) {
// //         print('💥 AuthWrapper: Auth state ERROR');
// //         print('   - Error: $error');
// //         print('   - Stack: $stack');
        
// //         return Scaffold(
// //           body: Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(Icons.error_outline, size: 64, color: Colors.red),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   'Auth Error: $error',
// //                   textAlign: TextAlign.center,
// //                   style: const TextStyle(color: Colors.red, fontSize: 12),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     print('🔄 AuthWrapper: Manually refreshing auth state');
// //                     ref.refresh(authStateProvider);
// //                   },
// //                   child: const Text('Refresh'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:healthyguppy/pages/login/loginpage.dart';
// // import 'package:healthyguppy/pages/homepage/homepage.dart';
// // import 'package:healthyguppy/provider/auth_provider.dart';

// // // PERBAIKAN: Provider untuk auth state stream dengan lebih detail
// // final authStateProvider = StreamProvider<User?>((ref) {
// //   final authService = ref.watch(authServiceProvider);
// //   print('🔄 AuthStateProvider: Creating NEW stream from authService');
  
// //   // Return stream dengan tambahan logging
// //   return authService.authStateChanges.map((user) {
// //     print('🔥 AuthStateProvider: Stream emitted user = ${user?.email ?? 'NULL'}');
// //     return user;
// //   });
// // });

// // class AuthWrapper extends ConsumerWidget {
// //   const AuthWrapper({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     print('🏗️ AuthWrapper: Building widget (REBUILD)');
    
// //     final authState = ref.watch(authStateProvider);

// //     return authState.when(
// //       data: (user) {
// //         print('📊 AuthWrapper: Received user data');
// //         print('   - User: ${user?.email ?? 'NULL'}');
// //         print('   - UID: ${user?.uid ?? 'NULL'}');
        
// //         if (user != null) {
// //           print('✅ AuthWrapper: User AUTHENTICATED -> Showing HomePage');
          
// //           // TAMBAHAN: Debug widget yang akan di-return
// //           final homePage = const HomePage();
// //           print('🏠 AuthWrapper: Returning HomePage widget: $homePage');
          
// //           return homePage;
// //         } else {
// //           print('❌ AuthWrapper: User NOT authenticated -> Showing LoginPage');
// //           return const LoginPage();
// //         }
// //       },
// //       loading: () {
// //         print('⏳ AuthWrapper: Auth state LOADING');
// //         return const Scaffold(
// //           body: Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 CircularProgressIndicator(),
// //                 SizedBox(height: 16),
// //                 Text('Memuat...'),
// //                 SizedBox(height: 8),
// //                 Text('Checking authentication...', 
// //                      style: TextStyle(fontSize: 12, color: Colors.grey)),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //       error: (error, stack) {
// //         print('💥 AuthWrapper: Auth state ERROR');
// //         print('   - Error: $error');
// //         print('   - Stack: $stack');
        
// //         return Scaffold(
// //           body: Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(Icons.error_outline, size: 64, color: Colors.red),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   'Auth Error: $error',
// //                   textAlign: TextAlign.center,
// //                   style: const TextStyle(color: Colors.red, fontSize: 12),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     print('🔄 AuthWrapper: Manually refreshing auth state');
// //                     ref.refresh(authStateProvider);
// //                   },
// //                   child: const Text('Refresh'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/pages/login/loginpage.dart';
import 'package:healthyguppy/pages/homepage/homepage.dart';
import 'package:healthyguppy/provider/auth_provider.dart';

// PENTING: Provider untuk auth state stream - dipindah ke sini untuk memastikan tidak ada duplikasi
final authStateProvider = StreamProvider<User?>((ref) {
  print('AuthStateProvider: Creating Firebase Auth stream'); // Debug
  
  // Langsung gunakan Firebase Auth stream tanpa melalui AuthService
  // untuk memastikan tidak ada masalah dengan implementation
  return FirebaseAuth.instance.authStateChanges();
});

// Provider tambahan untuk current user yang lebih mudah diakses
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    print('AuthWrapper: Building widget with state: ${authState.runtimeType}'); // Debug

    return authState.when(
      data: (user) {
        print('AuthWrapper: Auth data received');
        print('AuthWrapper: User is ${user != null ? "authenticated" : "not authenticated"}');
        if (user != null) {
          print('AuthWrapper: User email: ${user.email}');
          print('AuthWrapper: User UID: ${user.uid}');
        }

        // Tambahkan delay kecil untuk memastikan UI stabil
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: user != null 
            ? const HomePage(key: ValueKey('homepage'))
            : const LoginPage(key: ValueKey('loginpage')),
        );
      },
      loading: () {
        print('AuthWrapper: Auth state is loading');
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 24),
                Text(
                  'Memeriksa status login...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stack) {
        print('AuthWrapper: Auth state error - $error');
        print('AuthWrapper: Stack trace - $stack');
        
        // Untuk error, default ke LoginPage
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          print('AuthWrapper: Refreshing auth state provider');
                          ref.refresh(authStateProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print('AuthWrapper: Navigating to LoginPage manually');
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Ke Login'),
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
}

// Helper widget untuk debug auth state (opsional, bisa dihapus di production)
class AuthDebugWidget extends ConsumerWidget {
  const AuthDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Auth State: ${authState.runtimeType}'),
          Text('Current User: ${currentUser?.email ?? "null"}'),
          Text('Firebase User: ${FirebaseAuth.instance.currentUser?.email ?? "null"}'),
        ],
      ),
    );
  }
}