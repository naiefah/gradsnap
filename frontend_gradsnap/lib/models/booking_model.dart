import 'package:flutter/material.dart';

class BookingModel {
  final int id;
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final String serviceType;
  final String bookingDate;
  final String bookingTime;
  final String location;
  final String additionalRequest;
  final String? customerNote;
  final double totalPrice;
  final String paymentStatus;
  final String bookingStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BookingModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.serviceType,
    required this.bookingDate,
    required this.bookingTime,
    required this.location,
    required this.additionalRequest,
    this.customerNote,
    required this.totalPrice,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      serviceName: json['service_name'] ?? '',
      serviceType: json['service_type'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      bookingTime: json['booking_time'] ?? '',
      location: json['location'] ?? '',
      additionalRequest: json['additional_request'] ?? '',
      customerNote: json['customer_note'],
      totalPrice: json['total_price'] is String 
          ? double.parse(json['total_price']) 
          : (json['total_price'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? 'pending',
      bookingStatus: json['booking_status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'service_name': serviceName,
      'service_type': serviceType,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'location': location,
      'additional_request': additionalRequest,
      'customer_note': customerNote,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
      'booking_status': bookingStatus,
    };
  }

  // Getter untuk label service type
  String get serviceTypeLabel {
    switch (serviceType) {
      case 'mua':
        return 'Makeup Artist';
      case 'photographer':
        return 'Photographer';
      case 'both':
        return 'MUA & Photographer';
      default:
        return serviceType;
    }
  }

  // Getter untuk label payment status
  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Sudah Dibayar';
      case 'failed':
        return 'Pembayaran Gagal';
      case 'refunded':
        return 'Dikembalikan';
      default:
        return paymentStatus;
    }
  }

  // Getter untuk label booking status
  String get bookingStatusLabel {
    switch (bookingStatus) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'in_progress':
        return 'Sedang Berlangsung';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return bookingStatus;
    }
  }

  // Getter untuk color booking status
  Color get bookingStatusColor {
    switch (bookingStatus) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Getter untuk color payment status
  Color get paymentStatusColor {
    switch (paymentStatus) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}