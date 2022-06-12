import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../M/AppUser.dart';

class Server {
  static bool local = false;
  static String devServerIp = '192.168.0.100';

  static String getServerAddress({onlineServer = false}) {
    local = true;
    if (kDebugMode && local && (!onlineServer)) {
      print(devServerIp);
      return "http://$devServerIp:3000";
    } else {
      return "https://smartwind.nsslsupportservices.com";
    }
  }

  static String getServerPath(String path, {onlineServer = false}) {
    print("${getServerAddress(onlineServer: onlineServer)}/$path");
    return "${getServerAddress(onlineServer: onlineServer)}/$path";
  }

  static String getServerApiPath(String url, {onlineServer = false}) {
    print("${getServerAddress(onlineServer: onlineServer)}/api/$url");
    return "${getServerAddress(onlineServer: onlineServer)}/api/$url";
  }

  ///   [url] must be after api part without /
  static Future<Response> apiPost(String url, Map<String, dynamic> data, {FormData? formData}) async {
    final idToken = await AppUser.getIdToken();

    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";
    print('apiPost - ${Server.getServerApiPath(url)}');
    return dio.post(Server.getServerApiPath(url), data: formData ?? (data));
  }

  ///   [url] must be after api part without /
  static Future<Response> apiGet(String url, Map<String, dynamic> data, {onlineServer = false}) async {
    final idToken = await AppUser.getIdToken();
    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";

    return dio.get(Server.getServerApiPath(url, onlineServer: onlineServer), queryParameters: data);
  }

  static Future<Response> serverGet(String url, Map<String, dynamic> data, {onlineServer = false}) async {
    final idToken = await AppUser.getIdToken();
    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";

    return dio.get(Server.getServerPath(url, onlineServer: onlineServer), queryParameters: data);
  }

  static Future<Response> serverPost(String url, Map<String, dynamic> data, {onlineServer = false}) async {
    final idToken = await AppUser.getIdToken();
    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";

    return dio.post(Server.getServerPath(url, onlineServer: onlineServer), data: data);
  }
}
