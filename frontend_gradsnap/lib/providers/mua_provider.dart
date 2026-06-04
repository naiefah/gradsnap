import 'package:flutter/material.dart';

import '../models/mua_model.dart';

class MuaProvider extends ChangeNotifier {

  List<MUAModel> muaList = [];

  void setMua(List<MUAModel> data) {

    muaList = data;

    notifyListeners();
  }
}