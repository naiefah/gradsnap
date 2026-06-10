// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/user_model.dart';
// AuthProvider - Mengelola autentikasi Google Sign-In dan session dengan SharedPreferences

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  static const String BASE_URL = "http://192.168.1.19";
  
  static const String KEY_USER_DATA = 'user_data';
  static const String KEY_IS_LOGGED_IN = 'is_logged_in';
  
  firebase_auth.User? _firebaseUser;
  User? _appUser;
  bool _initialized = false;
  bool _isLoading = false;
  bool _isLoadingUser = false;
  bool _isAuthStateHandling = false;
  
  SharedPreferences? _prefs;

  User? get appUser => _appUser;
  firebase_auth.User? get firebaseUser => _firebaseUser;
  firebase_auth.FirebaseAuth get auth => _auth;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _appUser != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUserFromCache();
    _initAuthStateListener();
    _initGoogleSignIn();
  }

  // Load user dari cache
  Future<void> _loadUserFromCache() async {
    if (_prefs == null) return;
    
    final String? userJson = _prefs!.getString(KEY_USER_DATA);
    if (userJson != null) {
      try {
        _appUser = User.fromJsonString(userJson);
        debugPrint("✅ User loaded from cache: ${_appUser?.name}");
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading user from cache: $e");
      }
    }
  }

  // Save user ke cache
  Future<void> _saveUserToCache(User user) async {
    if (_prefs == null) return;
    
    try {
      await _prefs!.setString(KEY_USER_DATA, user.toJsonString());
      await _prefs!.setBool(KEY_IS_LOGGED_IN, true);
      debugPrint("✅ User saved to cache: ${user.name}");
    } catch (e) {
      debugPrint("Error saving user to cache: $e");
    }
  }

  // Clear cache
  Future<void> _clearUserCache() async {
    if (_prefs == null) return;
    
    await _prefs!.remove(KEY_USER_DATA);
    await _prefs!.setBool(KEY_IS_LOGGED_IN, false);
    debugPrint("🗑️ User cache cleared");
  }

  void _initAuthStateListener() {
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) async {
      if (_isAuthStateHandling) return;
      
      _isAuthStateHandling = true;
      _firebaseUser = firebaseUser;
      
      if (firebaseUser != null) {
        if (_appUser == null || _appUser?.firebaseUid != firebaseUser.uid) {
          await loadUserFromBackend(firebaseUser.uid);
        }
      } else {
        _appUser = null;
        await _clearUserCache();
      }
      
      _isAuthStateHandling = false;
      notifyListeners();
    });
  }

  Future<void> _initGoogleSignIn() async {
    if (_initialized) return;
    _initialized = true;
    await _googleSignIn.initialize();
    await _googleSignIn.attemptLightweightAuthentication();
  }

  Future<void> loadUserFromBackend(String firebaseUid) async {
    if (_isLoadingUser) return;
    
    _isLoadingUser = true;
    
    try {
      final response = await http.get(
        Uri.parse(
          "$BASE_URL/gradsnap_backend/user/get_user.php?firebase_uid=$firebaseUid",
        ),
      ).timeout(const Duration(seconds: 30));

      debugPrint("===== GET USER =====");
      debugPrint("STATUS : ${response.statusCode}");
      debugPrint("BODY : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "success" && data["user"] != null) {
          _appUser = User.fromJson(data["user"]);
          await _saveUserToCache(_appUser!);
          debugPrint("✅ USER LOADED FROM BACKEND: ${_appUser?.name}");
        } else {
          debugPrint("USER BELUM ADA, akan dibuat...");
          await createUserInBackend(firebaseUid);
          await _reloadUserAfterCreate(firebaseUid);
        }
      }
    } catch (e) {
      debugPrint("ERROR GET USER: $e");
      if (_appUser != null) {
        debugPrint("⚠️ Using cached user data");
      }
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }

  Future<void> _reloadUserAfterCreate(String firebaseUid) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$BASE_URL/gradsnap_backend/user/get_user.php?firebase_uid=$firebaseUid",
        ),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
          _appUser = User.fromJson(data["user"]);
          await _saveUserToCache(_appUser!);
        }
      }
    } catch (e) {
      debugPrint("ERROR RELOAD USER: $e");
    }
  }

  Future<void> createUserInBackend(String firebaseUid) async {
    try {
      final firebaseUser = _auth.currentUser;

      debugPrint("===== CREATE USER =====");
      debugPrint("UID: $firebaseUid");
      debugPrint("Display Name: ${firebaseUser?.displayName}");
      debugPrint("Email: ${firebaseUser?.email}");
      debugPrint("Photo: ${firebaseUser?.photoURL}");

      if (firebaseUser == null) {
        debugPrint("FIREBASE USER NULL");
        return;
      }

      final response = await http.post(
        Uri.parse("$BASE_URL/gradsnap_backend/user/create_user.php"),
        body: {
          "firebase_uid": firebaseUid,
          "name": firebaseUser.displayName ?? "",
          "email": firebaseUser.email ?? "",
          "photo_url": firebaseUser.photoURL ?? "",
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint("CREATE USER STATUS: ${response.statusCode}");
      debugPrint("CREATE USER BODY: ${response.body}");
    } catch (e) {
      debugPrint("ERROR CREATE USER: $e");
    }
  }

  Future<void> getCurrentUser() async {
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null && _appUser == null) {
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
        debugPrint("LOGIN DIBATALKAN");
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint("===== GOOGLE ACCOUNT =====");
      debugPrint("NAME : ${googleUser.displayName}");
      debugPrint("EMAIL : ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint("ID TOKEN NULL");
        _isLoading = false;
        notifyListeners();
        return;
      }

      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);
      _firebaseUser = userCredential.user;

      debugPrint("===== FIREBASE USER =====");
      debugPrint("UID : ${userCredential.user?.uid}");
      debugPrint("NAME : ${userCredential.user?.displayName}");
      debugPrint("EMAIL : ${userCredential.user?.email}");
      debugPrint("PHOTO : ${userCredential.user?.photoURL}");

      final response = await http.post(
        Uri.parse("$BASE_URL/gradsnap_backend/user/create_user.php"),
        body: {
          "firebase_uid": userCredential.user?.uid ?? "",
          "name": userCredential.user?.displayName ?? googleUser.displayName ?? "",
          "email": userCredential.user?.email ?? googleUser.email,
          "photo_url": userCredential.user?.photoURL ?? "",
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint("===== CREATE USER RESPONSE =====");
      debugPrint("STATUS : ${response.statusCode}");
      debugPrint("BODY : ${response.body}");

      await loadUserFromBackend(userCredential.user!.uid);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("===== LOGIN ERROR =====");
      debugPrint(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _firebaseUser = null;
    _appUser = null;
    await _clearUserCache();
    notifyListeners();
  }
  
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
      final response = await http.post(
        Uri.parse("$BASE_URL/gradsnap_backend/user/update_user.php"),
        body: {
          'user_id': _appUser!.id.toString(),
          'name': name ?? _appUser!.name,
          'phone': phone ?? _appUser!.phone ?? '',
          'location': location ?? _appUser!.location ?? '',
          'photo_url': photoUrl ?? _appUser!.photoUrl ?? '',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _appUser = _appUser!.copyWith(
            name: name,
            phone: phone,
            location: location,
            photoUrl: photoUrl,
          );
          await _saveUserToCache(_appUser!);
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

  Future<bool> updateUserRole(UserRole newRole) async {
    if (_appUser == null) return false;
    
    if (_appUser!.role == newRole) return true;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse("$BASE_URL/gradsnap_backend/user/update_role.php"),
        body: {
          'user_id': _appUser!.id.toString(),
          'role': newRole.toString().split('.').last,
        },
      ).timeout(const Duration(seconds: 30));
      
      debugPrint("===== UPDATE ROLE =====");
      debugPrint("STATUS : ${response.statusCode}");
      debugPrint("BODY : ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _appUser = _appUser!.copyWith(role: newRole);
          await _saveUserToCache(_appUser!);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Error updating role: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> upgradeToVendor({
    required UserRole role,
    required String priceRange,
    required String address,
    required String description,
    required List<File> portfolioImages,
  }) async {
    if (_appUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint("===== START UPGRADE TO VENDOR =====");
      debugPrint("Role: ${role.toString().split('.').last}");
      debugPrint("User ID: ${_appUser!.id}");
      
      List<String> imageUrls = [];
      for (var image in portfolioImages) {
        try {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse("$BASE_URL/gradsnap_backend/upload_portfolio.php"),
          );
          
          request.files.add(await http.MultipartFile.fromPath('portfolio', image.path));
          request.fields['user_id'] = _appUser!.id.toString();
          
          debugPrint("Uploading image: ${image.path}");
          
          var response = await request.send().timeout(const Duration(seconds: 30));
          var responseData = await response.stream.bytesToString();
          debugPrint("Upload response: $responseData");
          
          var jsonData = jsonDecode(responseData);
          if (jsonData['status'] == 'success') {
            imageUrls.add(jsonData['url']);
          }
        } catch (e) {
          debugPrint("Error uploading image: $e");
        }
      }
      
      debugPrint("Uploaded ${imageUrls.length} images");
      
      final roleResponse = await http.post(
        Uri.parse("$BASE_URL/gradsnap_backend/update_role.php"),
        body: {
          'user_id': _appUser!.id.toString(),
          'role': role.toString().split('.').last,
        },
      ).timeout(const Duration(seconds: 30));
      
      debugPrint("Update role response: ${roleResponse.body}");
      
      final vendorResponse = await http.post(
        Uri.parse("$BASE_URL/gradsnap_backend/save_vendor_data.php"),
        body: {
          'user_id': _appUser!.id.toString(),
          'role': role.toString().split('.').last,
          'price_range': priceRange,
          'address': address,
          'description': description,
          'portfolio_images': jsonEncode(imageUrls),
        },
      ).timeout(const Duration(seconds: 30));
      
      debugPrint("Save vendor response: ${vendorResponse.body}");
      
      if (vendorResponse.statusCode == 200) {
        final data = jsonDecode(vendorResponse.body);
        if (data['status'] == 'success') {
          _appUser = _appUser!.copyWith(role: role);
          await _saveUserToCache(_appUser!);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Error upgrade to vendor: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool hasRole(UserRole role) {
    return _appUser?.role == role;
  }

  bool get isCustomer => _appUser?.isCustomer ?? false;
  bool get isMUA => _appUser?.isMUA ?? false;
  bool get isPhotographer => _appUser?.isPhotographer ?? false;
  bool get isAdmin => _appUser?.isAdmin ?? false;
}
// AuthProvider - Mengelola autentikasi Google Sign-In dan session
