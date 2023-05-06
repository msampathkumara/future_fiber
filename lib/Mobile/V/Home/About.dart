import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartwind_future_fibers/res.dart';

import '../../../C/Api.dart';
import '../../../C/App.dart';
import '../../../C/Server.dart';
import '../../../M/EndPoints.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  _AboutState createState() {
    return _AboutState();
  }
}

class _AboutState extends State<About> {
  String? appVersion;

  String serverUrl = "";
  String? dbName;
  String env = "";

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((appInfo) {
      print(appInfo);
      appVersion = appInfo.version;
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  int lastTap = DateTime.now().millisecondsSinceEpoch;
  int consecutiveTaps = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Center(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: () {
              int now = DateTime.now().millisecondsSinceEpoch;
              if (now - lastTap < 1000) {
                print("Consecutive tap");
                consecutiveTaps++;
                print("taps = $consecutiveTaps");
                if (consecutiveTaps > 4) {
                  App.changeToTestMode();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Activate Test Mode")));
                }
              } else {
                consecutiveTaps = 0;
              }
              lastTap = now;
            },
            child: Padding(padding: const EdgeInsets.all(8.0), child: CircleAvatar(radius: 100, child: Image.asset(Res.smartwindlogo)))),
        const Text("NS Smart Wind", textScaleFactor: 1.5),
        Text("$appVersion", textScaleFactor: 1),
        ListTile(title: const Text('server url'), trailing: Text(serverUrl)),
        ListTile(title: const Text('db Name'), trailing: dbName == null ? const CircularProgressIndicator() : Text("$dbName")),
        ListTile(title: const Text('env'), trailing: Text(env))
      ],
    )));
  }
}
