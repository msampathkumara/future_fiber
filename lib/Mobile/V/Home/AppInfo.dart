import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartwind_future_fibers/C/Server.dart';
import 'package:smartwind_future_fibers/res.dart';

import '../../../C/Api.dart';
import '../../../M/EndPoints.dart';

class AppInfo extends StatefulWidget {
  const AppInfo({Key? key}) : super(key: key);

  @override
  State<AppInfo> createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  String? appVersion;
  String? buildNumber;
  String? appName;
  String? buildSignature;

  String serverUrl = "";

  String? dbName;

  String env = "";

  @override
  void initState() {
    // TODO: implement initState
    PackageInfo.fromPlatform().then((appInfo) {
      print(appInfo);
      setState(() {
        appVersion = appInfo.version;
        buildNumber = appInfo.buildNumber;
        appName = appInfo.appName;
        buildSignature = appInfo.buildSignature;
      });
    });

    Server.getServerAddress().then((value) => setState(() => {serverUrl = value}));
    Api.get(EndPoints.getServerInfo, {}).then((res) {
      var data = res.data;
      setState(() {
        dbName = data["dbName"];
      });
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {});
    env = const String.fromEnvironment("flavor");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SizedBox(
        width: 500,
        height: 550,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  width: 150,
                  child: Image.asset(
                    Res.smartwindlogo150,
                    height: 100,
                    width: 100,
                    cacheWidth: 500,
                  )),
              ListTile(title: const Text('App Name'), trailing: Text('$appName')),
              ListTile(title: const Text('App Version'), trailing: Text('$appVersion')),
              ListTile(title: const Text('App Build Number'), trailing: Text('$buildNumber')),
              ListTile(title: const Text('server url'), trailing: Text(serverUrl)),
              ListTile(title: const Text('db Name'), trailing: dbName == null ? const CircularProgressIndicator() : Text("$dbName")),
              ListTile(title: const Text('env'), trailing: Text(env))
            ]),
          ),
        ),
      ),
    ));
  }
}
