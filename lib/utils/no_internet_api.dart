import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _hasInternet = true;

  bool get hasInternet => _hasInternet;

  ConnectivityProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _hasInternet = connectivityResult != ConnectivityResult.none;
    notifyListeners();

    Connectivity().onConnectivityChanged.listen((result) {
      _hasInternet = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  void checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _hasInternet = connectivityResult != ConnectivityResult.none;
    notifyListeners();
  }
}
