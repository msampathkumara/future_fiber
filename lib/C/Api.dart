import 'dart:math';

import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;

import '../M/AppUser.dart';
import '../globals.dart';
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

      data["userCurrentSection"] = (AppUser.getSelectedSection()?.id ?? 0).toString();

      return dio.post(Server.getServerApiPath(url), data: formData ?? (data), onSendProgress: onSendProgress);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        print(e.response?.statusCode);
        return post(url, data, formData: formData, onSendProgress: onSendProgress, reFreshToken: true);
      }
      throw Exception(e.message);
    }
  }

  static Future<Response> get(String url, Map<String, dynamic> data, {onlineServer = false, bool reFreshToken = false, cancelToken}) async {
    print('url == $url');

    try {
      final idToken = await AppUser.getIdToken(reFreshToken);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "$idToken";

      data["userCurrentSection"] = (AppUser.getSelectedSection()?.id ?? 0).toString();
      print('userCurrentSection ${data["userCurrentSection"]}');

      return dio.get(Server.getServerApiPath(url, onlineServer: onlineServer), queryParameters: data, cancelToken: cancelToken);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        print(e.response?.statusCode);
        return get(url, data, onlineServer: onlineServer, reFreshToken: true);
      }
      if (e.type == DioErrorType.cancel) {
        printError('Request Cancel for --> $url');
      }

      throw Exception(e.message);
    }
  }

  static Future downloadFile(String url, Map<String, dynamic> data, fileName, {onlineServer = false, bool reFreshToken = false, cancelToken}) async {
    try {
      final idToken = await AppUser.getIdToken(reFreshToken);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "$idToken";

      data["userCurrentSection"] = (AppUser.getSelectedSection()?.id ?? 0).toString();
      print('userCurrentSection ${data["userCurrentSection"]}');

      Response response = await dio.get<List<int>>(Server.getServerApiPath(url), options: Options(responseType: ResponseType.bytes));

      print(response.headers['content-type']);

      // var file = File.fromRawPath(response.data);
      final blob = html.Blob([response.data], (response.headers.value('content-type')));
      final url_ = html.Url.createObjectUrlFromBlob(blob);
      // html.window.open(url_, "_blank");

      html.AnchorElement(href: url_)
        ..setAttribute("download", fileName)
        ..click();
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        print(e.response?.statusCode);
        return get(url, data, onlineServer: onlineServer, reFreshToken: true);
      }
      throw Exception(e.message);
    }
  }
}
