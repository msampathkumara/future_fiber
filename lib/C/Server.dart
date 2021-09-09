import 'package:flutter/foundation.dart';

class Server {
  static bool local = false;

  static String getServerAddress() {
    if (kDebugMode) {
      // if (local) {
      return "http://192.168.0.104:3000";
    } else {
      return "https://smartwind.nsslsupportservices.com";
    }
  }

  static String getServerPath(String path) {
    return getServerAddress() + "/" + path;
  }

  static String getServerApiPath(String url) {
    return getServerAddress() + "/api/" + url;
  }
}
