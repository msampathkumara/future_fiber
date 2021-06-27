import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/M/NsUser.dart';

class App {
  App();

  factory App.fromJson(Map<String, dynamic> json) {
    return App();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }

  static NsUser? currentUser;

  static getCurrentUser() async {
    var prefs = await SharedPreferences.getInstance();
    var u = prefs.getString("user");
    if (u != null) {
      currentUser = NsUser.fromJson(json.decode(u));
    }
    return currentUser;
  }
}
