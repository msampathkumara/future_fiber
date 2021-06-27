import 'package:flutter/foundation.dart';

class Server {
  static bool local = true;

  static String getServerAddress() {
    if (kDebugMode && local) {
      return "http://192.168.0.104:3000";
    } else {
      return "http://smartwind.nsslsupportservices.com";
    }
  }

  static String getServerPath(String path) {
    return getServerAddress() + "/" + path;
  }

  static String getServerApiPath(String url) {
    return getServerAddress() + "/api/" + url;
  }
}
