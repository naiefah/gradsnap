// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';

class ApiService {
  // ============ KONFIGURASI BASE URL ============
  // Gunakan IP dari hasil curl: 192.168.195.22
  // Untuk emulator Android: 10.0.2.2
  // Untuk device fisik: 192.168.195.22 (IP komputer Anda)
  static const String baseUrl = 'http://192.168.1.19'; // Ganti dengan IP Anda
  
  static const String phpBaseUrl = '$baseUrl/gradsnap_backend';

  // ============ AUTH API ============
  
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
        Uri.parse('$phpBaseUrl/login.php'),
        body: {"id_token": idToken},
      );
      
      final data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        return {
          'success': true,
          'message': data['message'],
          'token': firebaseToken,
          'user': {
            'id': data['user_id'] ?? 0,
            'firebase_uid': firebaseUid,
            'name': userCredential.user?.displayName ?? '',
            'email': userCredential.user?.email ?? '',
            'role': data['role'] ?? 'customer',
            'phone': data['phone'] ?? '',
            'location': data['location'] ?? '',
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

  // Logout
  static Future<void> logout() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  // ============ BOOKING API ============
  
  // Get all bookings
  static Future<Map<String, dynamic>> getBookings({
    String? bookingStatus,
    String? paymentStatus,
    String? serviceType,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (bookingStatus != null) queryParams['booking_status'] = bookingStatus;
      if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;
      if (serviceType != null) queryParams['service_type'] = serviceType;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();
      
      final uri = Uri.parse('$phpBaseUrl/bookings/read.php').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal mengambil data booking'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get user's bookings
  static Future<Map<String, dynamic>> getUserBookings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$phpBaseUrl/bookings/get_user_bookings.php?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal mengambil data booking user'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Create booking
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await http.post(
        Uri.parse('$phpBaseUrl/bookings/create.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookingData),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal membuat booking'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get booking by ID
  static Future<Map<String, dynamic>> getBookingById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$phpBaseUrl/bookings/read_one.php?id=$id'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Booking tidak ditemukan'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update booking
  static Future<Map<String, dynamic>> updateBooking(int id, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('$phpBaseUrl/bookings/update.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal update booking'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update booking status
  static Future<Map<String, dynamic>> updateBookingStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$phpBaseUrl/bookings/update_status.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'booking_status': status}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal update status booking'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update payment status
  static Future<Map<String, dynamic>> updatePaymentStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$phpBaseUrl/bookings/update_status.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'payment_status': status}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal update status pembayaran'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Delete booking (soft delete)
  static Future<Map<String, dynamic>> deleteBooking(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$phpBaseUrl/bookings/delete.php?id=$id'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal hapus booking'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Check availability
  static Future<Map<String, dynamic>> checkAvailability(
    String date, 
    String time, 
    String serviceType
  ) async {
    try {
      final uri = Uri.parse('$phpBaseUrl/bookings/availability.php').replace(
        queryParameters: {
          'date': date,
          'time': time,
          'service_type': serviceType,
        },
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal cek ketersediaan'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$phpBaseUrl/bookings/statistics.php'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal ambil statistik'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============ MUA & PHOTOGRAPHER API ============
  
  // Get all MUAs
  static Future<Map<String, dynamic>> getMuaList() async {
    try {
      final response = await http.get(
        Uri.parse('$phpBaseUrl/mua/read.php'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal mengambil data MUA'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get all photographers
  static Future<Map<String, dynamic>> getPhotographerList() async {
    try {
      final response = await http.get(
        Uri.parse('$phpBaseUrl/photographers/read.php'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal mengambil data Photographer'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get MUA by ID
  static Future<Map<String, dynamic>> getMuaById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$phpBaseUrl/mua/read_one.php?id=$id'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'MUA tidak ditemukan'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get photographer by ID
  static Future<Map<String, dynamic>> getPhotographerById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$phpBaseUrl/photographers/read_one.php?id=$id'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Photographer tidak ditemukan'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============ USER API ============
  
  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$phpBaseUrl/user/get_user.php?firebase_uid=$userId'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'User tidak ditemukan'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile(String userId, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('$phpBaseUrl/users/update.php?id=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal update profil'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}