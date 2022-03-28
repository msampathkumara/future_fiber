import 'package:dio/dio.dart';

import '../M/AppUser.dart';
import 'Server.dart';

class Api {
  ///   [url] must be after api part without /
  static Future<Response> post(String url, Map<String, dynamic> data, {FormData? formData, Null Function(int sent, int total)? onSendProgress}) async {
    final idToken = await AppUser.getIdToken();

    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";
    print('apiPost - ' + Server.getServerApiPath(url));
    return dio.post(Server.getServerApiPath(url), data: formData ?? (data), onSendProgress: onSendProgress);
  }

  static Future<Response> get(String url, Map<String, dynamic> data, {onlineServer = false}) async {
    final idToken = await AppUser.getIdToken();
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";

    return dio.get(Server.getServerApiPath('$url', onlineServer: onlineServer), queryParameters: data);
  }
}
