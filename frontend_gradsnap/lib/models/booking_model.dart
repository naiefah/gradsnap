class BookingModel {
  final int id;
  final String customerName;
  final String customerPhone;        // tambahan: kontak customer
  final String serviceName;
  final String serviceType;           // 'mua' atau 'photographer'
  final String bookingDate;
  final String bookingTime;           // tambahan: jam pelaksanaan
  final String location;              // lokasi acara
  final String additionalRequest;     // permintaan tambahan dari customer
  final String? customerNote;         // catatan khusus (optional)
  final double totalPrice;
  final String paymentStatus;         // 'pending', 'paid', 'failed'
  final String bookingStatus;         // 'pending', 'confirmed', 'completed', 'cancelled'
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
      id: json['id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      serviceName: json['service_name'],
      serviceType: json['service_type'],
      bookingDate: json['booking_date'],
      bookingTime: json['booking_time'],
      location: json['location'],
      additionalRequest: json['additional_request'] ?? '',
      customerNote: json['customer_note'],
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? 'pending',
      bookingStatus: json['booking_status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Copy dengan perubahan field tertentu
  BookingModel copyWith({
    int? id,
    String? customerName,
    String? customerPhone,
    String? serviceName,
    String? serviceType,
    String? bookingDate,
    String? bookingTime,
    String? location,
    String? additionalRequest,
    String? customerNote,
    double? totalPrice,
    String? paymentStatus,
    String? bookingStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceName: serviceName ?? this.serviceName,
      serviceType: serviceType ?? this.serviceType,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      location: location ?? this.location,
      additionalRequest: additionalRequest ?? this.additionalRequest,
      customerNote: customerNote ?? this.customerNote,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}