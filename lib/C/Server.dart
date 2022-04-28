import 'package:flutter/foundation.dart';

class Server {
  static bool local = false;

  static String getServerAddress({onlineServer = false}) {
    local = true;
    if (kDebugMode && local) {
      return "http://192.168.0.101:3000";
    } else {
      return "https://smartwind.nsslsupportservices.com";
    }
  }

  static String getServerPath(String path, {onlineServer = false}) {
    return getServerAddress(onlineServer: onlineServer) + "/" + path;
  }

  static String getServerApiPath(String url, {onlineServer = false}) {
    print(getServerAddress(onlineServer: onlineServer) + "/api/" + url);
    return getServerAddress(onlineServer: onlineServer) + "/api/" + url;
  }
}
