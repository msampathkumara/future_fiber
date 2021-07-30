import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:smartwind/C/Server.dart';

class OnlineDB {
  static var idToken;

  // static String _apiUrl = Server.getServerApiPath("");

  OnlineDB() {
    final user = FirebaseAuth.instance.currentUser;
    user!.getIdToken().then((value) => idToken);
  }

  static Future<http.Response> apiPost(String url, Map data) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();
    // final token = idToken.token;

    return http.post(
      Uri.parse(Server.getServerApiPath(url)),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "authorization": '$idToken'},
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> apiGet(String url, Map<String, String> data) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();

    final header = {"authorization": '$idToken'};

    String queryString = Uri(queryParameters: data).query;
    // print(Uri.parse(Server.getServerApiPath('$url?$queryString')));
    return http.get(Uri.parse(Server.getServerApiPath('$url?$queryString')), headers: header);
  }

  static getImage(String s) {
    // final user = FirebaseAuth.instance.currentUser;
    // final idToken =   user!.getIdToken();
    return Image.network(s, headers: {"authorization": '$idToken'});
  }

  static getUserImage(String image, int size) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<String>(
      future: user!.getIdToken(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Please wait its loading...'));
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else
            idToken = snapshot.data;
          print("**************************************************************************************************************");
          print(image);
          return Image.network(Server.getServerApiPath("users/getImage?img=" + image + "&size=$size"), headers: {"authorization": '$idToken'});
        }
      },
    );
  }
}
