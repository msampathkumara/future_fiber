import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartwind/res.dart';

class About extends StatefulWidget {
  About({Key? key}) : super(key: key);

  @override
  _AboutState createState() {
    return _AboutState();
  }
}

class _AboutState extends State<About> {
  var appVersion;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((appInfo) {
      print(appInfo);
      appVersion = appInfo.version;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Center(
            child: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      direction: Axis.vertical,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(radius: 100, child: Image.asset(Res.north_sails_logo)),
        ),
        const Text("NS Smart Wind", textScaleFactor: 1.5),
        Text("$appVersion", textScaleFactor: 1)
      ],
    )));
  }
}
