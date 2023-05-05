import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../M/AppUser.dart';
import '../globals.dart';

class Server {
  static bool local = true;
  static String devServerIp = '192.168.0.100';

  static Future<String> getServerAddress({onlineServer = false}) async {
    local = false;

    // if (await isV2) {
    // return "https://v2.smartwind.nsslsupportservices.com";
    // }

    if (kDebugMode && local && (!onlineServer)) {
      print(devServerIp);
      return "http://$devServerIp:3000";
    }

    return "https://futurefibers.smartwind.nsslsupportservices.com";
  }

  static Future<String> getServerPath(String path, {onlineServer = false}) async {
    print('path ==== $path');
    print(await getServerAddress(onlineServer: onlineServer));
    print("${await getServerAddress(onlineServer: onlineServer)}/$path");
    return "${await getServerAddress(onlineServer: onlineServer)}/$path";
  }

  static Future<String> getServerApiPath(String url, {onlineServer = false}) async {
    print("${await getServerAddress(onlineServer: onlineServer)}/api/$url");
    return "${await getServerAddress(onlineServer: onlineServer)}/api/$url";
  }

  ///   [url] must be after api part without /
  static Future<Response> apiPost(String url, Map<String, dynamic> data, {FormData? formData}) async {
    final idToken = await AppUser.getIdToken();

    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";
    print('apiPost - ${await Server.getServerApiPath(url)}');
    return dio.post(await Server.getServerApiPath(url), data: formData ?? (data));
  }

  static Future<Response> serverGet(String url, Map<String, dynamic> data, {onlineServer = false}) async {
    final idToken = await AppUser.getIdToken();
    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";

    return dio.get(await Server.getServerPath(url, onlineServer: onlineServer), queryParameters: data);
  }

  static Future<Response> serverPost(String url, Map<String, dynamic> data, {bool onlineServer = false}) async {
    final idToken = await AppUser.getIdToken();
    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";

    return dio.post(await Server.getServerPath(url, onlineServer: onlineServer), data: data);
  }
}
