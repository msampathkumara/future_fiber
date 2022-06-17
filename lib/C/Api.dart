import 'package:dio/dio.dart';

import '../M/AppUser.dart';
import 'Server.dart';

class Api {
  ///   [url] must be after api part without /
  static Future<Response> post(String url, Map<String, dynamic> data, {FormData? formData, Null Function(int sent, int total)? onSendProgress, bool reFreshToken = false}) async {
    try {
      final idToken = await AppUser.getIdToken(reFreshToken);

      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "$idToken";
      print('apiPost - ${Server.getServerApiPath(url)}');
      return dio.post(Server.getServerApiPath(url), data: formData ?? (data), onSendProgress: onSendProgress);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        print(e.response?.statusCode);
        return post(url, data, formData: formData, onSendProgress: onSendProgress, reFreshToken: true);
      }
      throw Exception(e.message);
    }
  }

  static Future<Response> get(String url, Map<String, dynamic> data, {onlineServer = false, bool reFreshToken = false}) async {
    try {
      final idToken = await AppUser.getIdToken(reFreshToken);
      Dio dio = new Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "$idToken";

      return dio.get(Server.getServerApiPath('$url', onlineServer: onlineServer), queryParameters: data);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        print(e.response?.statusCode);
        return get(url, data, onlineServer: onlineServer, reFreshToken: true);
      }
      throw Exception(e.message);
    }
  }
}
