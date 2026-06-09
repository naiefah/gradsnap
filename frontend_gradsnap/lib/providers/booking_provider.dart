// providers/booking_provider.dart
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookingList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get bookingList => _bookingList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Ambil semua booking
  Future<bool> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getBookings();
      
      if (response['success'] == true) {
        List<dynamic> data = response['data'];
        _bookingList = data.map((json) => BookingModel.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal mengambil data';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Ambil booking by ID
  Future<BookingModel?> getBookingById(int id) async {
    try {
      final response = await ApiService.getBookingById(id);
      
      if (response['success'] == true) {
        return BookingModel.fromJson(response['data']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Buat booking baru
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.createBooking(bookingData);
      
      if (response['success'] == true) {
        // Tambahkan booking baru ke list
        final newBooking = BookingModel.fromJson(response['data']);
        _bookingList.insert(0, newBooking);
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': response['message'], 'data': newBooking};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': response['message']};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update booking
  Future<Map<String, dynamic>> updateBooking(int id, Map<String, dynamic> updateData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.updateBooking(id, updateData);
      
      if (response['success'] == true) {
        // Update booking di list
        final updatedBooking = BookingModel.fromJson(response['data']);
        final index = _bookingList.indexWhere((b) => b.id == id);
        if (index != -1) {
          _bookingList[index] = updatedBooking;
        }
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': response['message'], 'data': updatedBooking};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': response['message']};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update status booking
  Future<bool> updateBookingStatus(int id, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.updateBookingStatus(id, status);
      
      if (response['success'] == true) {
        // Update status di list
        final index = _bookingList.indexWhere((b) => b.id == id);
        if (index != -1) {
          final updatedBooking = BookingModel.fromJson({
            ..._bookingList[index].toJson(),
            'booking_status': status,
          });
          _bookingList[index] = updatedBooking;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus(int id, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.updatePaymentStatus(id, status);
      
      if (response['success'] == true) {
        // Update status di list
        final index = _bookingList.indexWhere((b) => b.id == id);
        if (index != -1) {
          final updatedBooking = BookingModel.fromJson({
            ..._bookingList[index].toJson(),
            'payment_status': status,
          });
          _bookingList[index] = updatedBooking;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Hapus booking
  Future<bool> deleteBooking(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.deleteBooking(id);
      
      if (response['success'] == true) {
        // Hapus dari list
        _bookingList.removeWhere((b) => b.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cek ketersediaan
  Future<Map<String, dynamic>> checkAvailability(String date, String time, String serviceType) async {
    try {
      return await ApiService.checkAvailability(date, time, serviceType);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Reset error
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear semua booking
  void clearBookings() {
    _bookingList = [];
    notifyListeners();
  }
}