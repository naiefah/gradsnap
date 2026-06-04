// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ApiService {
  // Ganti dengan IP laptop kamu (cek di ipconfig)
  static const String baseUrl = 'http://192.168.18.43'; // Contoh, ganti dengan IP kamu

  // Google Sign In
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
      
      await _googleSignIn.initialize();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Google sign in cancelled',
        };
      }

      // Cara ambil idToken yang benar (tanpa .then)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {
          'success': false,
          'message': 'ID Token tidak ditemukan',
        };
      }

      // Login ke Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );
      
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
      
      final String firebaseUid = userCredential.user!.uid;
      final String? firebaseToken = await userCredential.user?.getIdToken();

      // Kirim token ke backend PHP
      final response = await http.post(
        Uri.parse('$baseUrl/gradsnap_backend/login.php'),
        body: {"id_token": idToken},
      );
      
      final data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        return {
          'success': true,
          'message': data['message'],
          'token': firebaseToken,
          'user': {
            'id': 0,
            'firebase_uid': firebaseUid,
            'name': userCredential.user?.displayName ?? '',
            'email': userCredential.user?.email ?? '',
            'role': 'customer',
            'phone': '',
            'location': '',
            'photo_url': userCredential.user?.photoURL ?? '',
          }
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to save user data',
        };
      }
      
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<void> logout() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}