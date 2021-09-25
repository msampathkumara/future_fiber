import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/M/NsUser.dart';

class App {


  App()  ;

 static Future getAppInfo(){
   return PackageInfo.fromPlatform().then((PackageInfo packageInfo) {

      String version = packageInfo.version;
      print('version $version');
      return packageInfo;
    });
  }

  factory App.fromJson(Map<String, dynamic> json) {
    return App();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }

  static NsUser? currentUser;

  static Future<NsUser?> getCurrentUser() async {
    var prefs = await SharedPreferences.getInstance();
    var u = prefs.getString("user");
    if (u != null) {
      currentUser = NsUser.fromJson(json.decode(u));
    }
    return currentUser;
  }
}
