import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as dev;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FIX 1: The constructor is gone. Use the Singleton instance (v7.0.0+)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // --- GOOGLE SIGN IN ---
  Future<User?> signInWithGoogle() async {
    try {
      dev.log('AUTH_DEBUG: Starting Google Sign In');

      // FIX 2: Mandatory Initialization before any auth calls
      await _googleSignIn.initialize();

      // FIX 3: Use authenticate() instead of signIn() to trigger the system picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        dev.log('AUTH_DEBUG: User cancelled Google selection');
        return null;
      }

      // FIX 4: Request Authorization explicitly to get the accessToken
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email']);

      // Get the Identity Token
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // FIX 5: Create credential with the newly split tokens
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken, // Comes from Authorization
        idToken: googleAuth.idToken,         // Comes from Authentication
      );

      // Sign in to Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      dev.log('AUTH_DEBUG: Successfully signed in: ${userCredential.user?.email}');

      return userCredential.user;
    } catch (e) {
      dev.log('AUTH_DEBUG: Google Error: $e');
      rethrow;
    }
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    try {
      // FIX 6: Simplified sign out for the new API
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      dev.log('AUTH_DEBUG: Sign out error: $e');
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<User?> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    UserCredential userCredential = await _auth.signInWithProvider(appleProvider);
    return userCredential.user;
  }
}