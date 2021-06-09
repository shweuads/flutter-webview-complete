import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Connection extends ChangeNotifier {
  bool isConnected =false;

  bool get getConnection{
    checkConnection();
    return isConnected;
  }

  Future<void>  checkConnection() async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.mobile) {
        isConnected=true;
        notifyListeners();
    } else if (connection == ConnectivityResult.wifi) {
        isConnected=true;
        notifyListeners();
    } else {
      isConnected=false;
      notifyListeners();
    }
  }
}
