import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:smartwind/C/Server.dart';

class OnlineDB {
  // static String _apiUrl = Server.getServerApiPath("");

  static Future<http.Response> apiPost(String url, Map data) async {
    final user = await FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();
    // final token = idToken.token;

    return http.post(
      Uri.parse(Server.getServerApiPath(url)),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "authorization": '$idToken'},
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> apiGet(String url, Map<String, dynamic> data) async {
    final user = await FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();

    final header = {"authorization": '$idToken'};

    String queryString = Uri(queryParameters: data).query;
    print(Uri.parse(Server.getServerApiPath('$url?$queryString')));
    return http.get(Uri.parse(Server.getServerApiPath('$url?$queryString')), headers: header);
  }

  static getImage(String s) async {
    final user = await FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();
    return Image.network(s, headers: {"authorization": '$idToken'});
  }
}
