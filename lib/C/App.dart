import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_app/restart_app.dart';
import 'package:smartwind/C/DB/hive.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/NsUser.dart';

class App {
  App();

  static Future getAppInfo() {
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
    final Map<String, dynamic> data = <String, dynamic>{};
    return data;
  }

  static NsUser? get currentUser => getCurrentUser();

  static NsUser? getCurrentUser() {
    return AppUser.getUser();
  }

  static changeToProduction() async {
    var x = await HiveBox.getUserConfig();
    x.isTest = false;
    if (x.isInBox) {
      await x.save();
    } else {
      await HiveBox.userConfigBox.put(0, x);
    }

    await HiveBox.cleanDb();
    await HiveBox.getDataFromServer(clean: true);
    Restart.restartApp(webOrigin: '/');
  }

  static changeToTestMode() async {
    var x = await HiveBox.getUserConfig();
    x.isTest = true;
    if (x.isInBox) {
      await x.save();
    } else {
      await HiveBox.userConfigBox.put(0, x);
    }
    await HiveBox.getDataFromServer(clean: true);
    Restart.restartApp(webOrigin: '/');
  }

// static Future<void> tryOtaUpdate(Function(OtaEvent) onChange) async {
//   try {
//     //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
//     OtaUpdate()
//         .execute(
//       Server.getServerAddress() + "/apk/app.apk",
//       destinationFilename: 'app.apk',
//       //FOR NOW ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
//       // sha256checksum: 'd6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478',
//     )
//         .listen(
//       (OtaEvent event) {
//         onChange(event);
//         // setState(() => currentEvent = event);
//       },
//     );
//     // ignore: avoid_catches_without_on_clauses
//   } catch (e) {
//     print('Failed to make OTA update. Details: $e');
//   }
// }
}
