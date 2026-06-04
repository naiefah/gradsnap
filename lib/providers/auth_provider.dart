// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart'; // Import model User Anda

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  firebase_auth.User? _firebaseUser;
  User? _appUser; // Ini dari user_model.dart
  bool _initialized = false;
  bool _isLoading = false;

  // Getter
  User? get appUser => _appUser;
  firebase_auth.User? get firebaseUser => _firebaseUser;
  firebase_auth.FirebaseAuth get auth => _auth;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _appUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) async {
      _firebaseUser = firebaseUser;
      if (firebaseUser != null) {
        await loadUserFromBackend(firebaseUser.uid);
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    if (_initialized) return;
    _initialized = true;
    await _googleSignIn.initialize();
    await _googleSignIn.attemptLightweightAuthentication();
  }

  // Load user data dari backend
  Future<void> loadUserFromBackend(String firebaseUid) async {
    try {
      final String baseUrl = "http://192.168.18.43";
      final response = await http.get(
        Uri.parse("$baseUrl/gradsnap_backend/get_user.php?firebase_uid=$firebaseUid"),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['user'] != null) {
          _appUser = User.fromJson(data['user']);
          debugPrint("User loaded: ${_appUser?.name}");
        } else {
          debugPrint("User not found in backend, need to create");
          await createUserInBackend(firebaseUid);
        }
      }
    } catch (e) {
      debugPrint("Error loading user from backend: $e");
    }
    notifyListeners();
  }

  // Buat user baru di backend
  Future<void> createUserInBackend(String firebaseUid) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return;
      
      final String baseUrl = "http://192.168.18.43";
      final response = await http.post(
        Uri.parse("$baseUrl/gradsnap_backend/create_user.php"),
        body: {
          'firebase_uid': firebaseUid,
          'name': firebaseUser.displayName ?? '',
          'email': firebaseUser.email ?? '',
          'photo_url': firebaseUser.photoURL ?? '',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          await loadUserFromBackend(firebaseUid);
          debugPrint("User created in backend: ${data['message']}");
        }
      }
    } catch (e) {
      debugPrint("Error creating user in backend: $e");
    }
  }

  // Ambil current user
  Future<void> getCurrentUser() async {
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) {
      await loadUserFromBackend(_firebaseUser!.uid);
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        debugPrint("User membatalkan login");
        _isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint("Error: ID Token tidak ditemukan.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: idToken,
      );
      final firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);
      _firebaseUser = userCredential.user;
      
      final String baseUrl = "http://192.168.18.43";
      
      final response = await http.post(
        Uri.parse("$baseUrl/gradsnap_backend/login.php"),
        body: {"id_token": idToken},
      ).timeout(const Duration(seconds: 10));
      
      debugPrint("Status HTTP: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
      
      if (userCredential.user != null) {
        await loadUserFromBackend(userCredential.user!.uid);
      }
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      debugPrint("Error login: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _firebaseUser = null;
    _appUser = null;
    notifyListeners();
  }
  
  // Update profil
  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    String? location,
    String? photoUrl,
  }) async {
    if (_appUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final String baseUrl = "http://192.168.18.43";
      final response = await http.post(
        Uri.parse("$baseUrl/gradsnap_backend/update_user.php"),
        body: {
          'user_id': _appUser!.id.toString(),
          'name': name ?? _appUser!.name,
          'phone': phone ?? _appUser!.phone ?? '',
          'location': location ?? _appUser!.location ?? '',
          'photo_url': photoUrl ?? _appUser!.photoUrl ?? '',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _appUser = _appUser!.copyWith(
            name: name,
            phone: phone,
            location: location,
            photoUrl: photoUrl,
          );
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Error updating profile: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}