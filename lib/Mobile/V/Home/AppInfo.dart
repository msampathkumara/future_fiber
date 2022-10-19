import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartwind/res.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SizedBox(
        width: 500,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(width: 150, child: Image.asset(Res.splash)),
              ListTile(title: const Text('App Name'), subtitle: Text('$appName')),
              ListTile(title: const Text('App Version'), subtitle: Text('$appVersion')),
              ListTile(title: const Text('App Build Number'), subtitle: Text('$buildNumber')),
            ]),
          ),
        ),
      ),
    ));
  }
}
