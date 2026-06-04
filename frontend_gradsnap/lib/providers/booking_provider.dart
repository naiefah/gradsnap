import 'package:flutter/material.dart';

import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {

  List<BookingModel> bookingList = [];

  void setBooking(
    List<BookingModel> data,
  ) {

    bookingList = data;

    notifyListeners();
  }
}