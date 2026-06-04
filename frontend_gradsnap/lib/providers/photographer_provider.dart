import 'package:flutter/material.dart';

import '../models/photographer_model.dart';

class PhotographerProvider
    extends ChangeNotifier {

  List<PhotographerModel> photographerList = [];

  void setPhotographer(
    List<PhotographerModel> data,
  ) {

    photographerList = data;

    notifyListeners();
  }
}