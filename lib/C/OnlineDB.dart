import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smartwind/C/Server.dart';

class OnlineDB {
  // static String _apiUrl = Server.getServerApiPath("");

  static Future<http.Response> apiPost(String url, Map data) {
    return http.post(
      Uri.parse(Server.getServerApiPath(url)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> apiGet(String url, Map<String, dynamic> data) {
    String queryString = Uri(queryParameters: data).query;
    print(queryString);
    return http.get(Uri.parse(Server.getServerApiPath('$url?$queryString')));
  }
}
