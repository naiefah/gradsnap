// lib/providers/vendor_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/service_package.dart';
import '../models/booking_model.dart';

class VendorProvider extends ChangeNotifier {
  static const String BASE_URL = "http://192.168.1.19";
  
  List<ServicePackage> _packages = [];
  List<BookingModel> _vendorBookings = [];
  bool _isLoading = false;

  List<ServicePackage> get packages => _packages;
  List<BookingModel> get vendorBookings => _vendorBookings;
  bool get isLoading => _isLoading;

  // Load packages by vendor
  Future<void> loadPackages(int vendorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = "$BASE_URL/gradsnap_backend/vendor/get_packages.php?vendor_id=$vendorId";
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _packages = (data['packages'] as List)
              .map((p) => ServicePackage.fromJson(p))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error loading packages: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload package image
  Future<String?> uploadPackageImage(File image, int vendorId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$BASE_URL/gradsnap_backend/vendor/upload_package_image.php"),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
      request.fields['vendor_id'] = vendorId.toString();
      
      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);
      
      if (jsonData['status'] == 'success') {
        return jsonData['url'];
      }
      return null;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  // Add new package
  Future<bool> addPackage({
    required int vendorId,
    required String name,
    required String description,
    required double price,
    required String duration,
    required List<String> inclusions,
    String? imageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final inclusionsJson = jsonEncode(inclusions);
      
      final response = await http.post(
        Uri.parse("$BASE_URL/gradsnap_backend/vendor/add_package.php"),
        body: {
          'vendor_id': vendorId.toString(),
          'name': name,
          'description': description,
          'price': price.toString(),
          'duration': duration,
          'inclusions': inclusionsJson,
          'image_url': imageUrl ?? '',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          await loadPackages(vendorId);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error adding package: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update package
  Future<bool> updatePackage(ServicePackage package) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$BASE_URL/gradsnap_backend/vendor/update_package.php"),
        body: {
          'package_id': package.id.toString(),
          'vendor_id': package.vendorId.toString(),
          'name': package.name,
          'description': package.description,
          'price': package.price.toString(),
          'duration': package.duration,
          'inclusions': jsonEncode(package.inclusions),
          'image_url': package.imageUrl ?? '',
          'is_active': package.isActive ? '1' : '0',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          await loadPackages(package.vendorId);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error updating package: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete package
  Future<bool> deletePackage(int packageId, int vendorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$BASE_URL/gradsnap_backend/vendor/delete_package.php"),
        body: {
          'package_id': packageId.toString(),
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          await loadPackages(vendorId);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting package: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ BOOKING METHODS ============
  
  // Load vendor bookings
  Future<void> loadVendorBookings(int vendorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$BASE_URL/gradsnap_backend/bookings/read.php?vendor_id=$vendorId"),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _vendorBookings = (data['data'] as List)
              .map((b) => BookingModel.fromJson(b))
              .toList();
        }
      } else {
        _vendorBookings = [];
      }
    } catch (e) {
      debugPrint("Error loading vendor bookings: $e");
      _vendorBookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse("$BASE_URL/gradsnap_backend/bookings/update_booking.php?id=$bookingId"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'booking_status': status,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint("Error updating booking status: $e");
      return false;
    }
  }
}