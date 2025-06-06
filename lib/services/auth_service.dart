import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // PENTING: Stream untuk auth state changes
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // Getter untuk current user
  User? get currentUser {
    final user = _auth.currentUser;
    return user;
  }

  // Login method
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      return user;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak ditemukan';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan login. Coba lagi nanti';
          break;
        case 'invalid-credential':
          message = 'Email atau password salah';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan saat login';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Register method
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      return user;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password terlalu lemah';
          break;
        case 'email-already-in-use':
          message = 'Email sudah digunakan';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan saat mendaftar';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Reset password method
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak ditemukan';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan saat mengirim email reset';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Terjadi kesalahan saat logout: $e');
    }
  }
}
