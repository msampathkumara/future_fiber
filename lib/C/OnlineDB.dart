import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';

import 'DB/DB.dart';

class OnlineDB {
  static var idToken;

  OnlineDB() {
    final user = FirebaseAuth.instance.currentUser;
    user!.getIdToken().then((value) => idToken);
  }

  ///   [url] must be after api part without /
  static Future<Response> apiPost(String url, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";

    return dio.post(Server.getServerApiPath(url), data: (data));
  }

  static Future<Response> apiGet(String url, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "$idToken";

    return dio.get(Server.getServerApiPath('$url'), queryParameters: data);
  }

  static updateStandardTicketsDB(context) async {
    return DB
        .getDB()
        .then((value) => value!.rawQuery("select  (select ifnull(max(uptime),0) uptime from standardTickets) uptime ").then((value) {
              print("last update on == " + value.toString());
              Map<Object, Object?> xx = value.length > 0 ? value[0] : {'uptime': '0'};
              Map<String, String> uptime = xx.map((key, value) => MapEntry("$key", "$value"));
              print(uptime.toString());

              return OnlineDB.apiGet("tickets/standard/getListByUptime", uptime).then((response) async {
                Map res = (response.data);
                print("----------------------------------------------------------------");
                print(res);
                await DB.processData(res);
                await DB.callChangesCallBack(res);
              }).onError((error, stackTrace) {
                print(stackTrace);
                ErrorMessageView(errorMessage: error.toString()).show(context);
              });
            }))
        .onError((onError, st) {
      print(onError);
      ErrorMessageView(errorMessage: onError.toString()).show(context);
    });
  }
}
