import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authservice {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signUp(String username, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      await user?.updateDisplayName(username);
      await user?.reload();
      return null; // Berhasil, tidak ada error
    } on FirebaseAuthException catch (e) {
      // Kembalikan pesan error yang mudah dimengerti dari Firebase
      if (e.code == 'weak-password') {
        return 'Password yang digunakan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        return 'Email ini sudah terdaftar.';
      } else if (e.code == 'invalid-email') {
        return 'Format email tidak valid.';
      }
      return e.message; // Untuk error lainnya
    } catch (e) {
      return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User?> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      return result.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }
}
