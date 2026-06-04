class BookingModel {

  final int id;
  final String customerName;
  final String serviceName;
  final String bookingDate;

  BookingModel({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.bookingDate,
  });

  factory BookingModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return BookingModel(
      id: json['id'],
      customerName: json['customer_name'],
      serviceName: json['service_name'],
      bookingDate: json['booking_date'],
    );
  }
}