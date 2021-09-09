import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Home/Home.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

import 'SectionSelector.dart';

class CheckTabStatus extends StatefulWidget {
  final NsUser nsUser;

  const CheckTabStatus(this.nsUser);

  @override
  _CheckTabStatusState createState() => _CheckTabStatusState();
}

class _CheckTabStatusState extends State<CheckTabStatus> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
                child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Wrap(
                      direction: Axis.vertical,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        UserImage(nsUser: widget.nsUser, radius: 100),
                        SizedBox(
                          height: 48,
                        ),
                        Text("Hi", textScaleFactor: 3),
                        Text(widget.nsUser.name, textScaleFactor: 3)
                      ],
                    ),
                  ),
                ),
                // Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                      width: width - 200,
                      child: Column(
                        children: [
                          CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              value: isTabWorking,
                              onChanged: (bool? value) {
                                isTabWorking = value!;
                                setState(() {});
                              },
                              title: Text("Is Tab working without any problem ? \n( ටැබ් යන්ත්‍රය ගැටලුවකින් තොරව ක්‍රියා කරයිද ? )"),
                              subtitle: Text("")),
                          CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              value: haveStylus,
                              onChanged: (bool? value) {
                                haveStylus = value!;
                                setState(() {});
                              },
                              title: Text("Is Stylus pen available ?\n( ස්ටයිලස් පෑන තිබේද ? )"),
                              subtitle: Text("")),
                          Text(
                            "If you are unable to agree with all of above conditions. please contact a production leader. \n( ඉහත සඳහන් කොන්දේසි සමග එකඟ විය නොහැකි නම්. ප්‍රොඩක්ශන් ලීඩර් අමතන්න ) ",
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          if (!(isTabWorking && haveStylus)) SizedBox(height: 50),
                          if (isTabWorking && haveStylus)
                            ElevatedButton(
                              child: SizedBox(width: double.infinity, height: 50, child: Center(child: Text("Continue"))),
                              onPressed: () {
                                check();
                                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SectionSelector(widget.nsUser)), (Route<dynamic> route) => false);
                              },
                            )
                        ],
                      )),
                )
              ],
            )),
          ),
        ));
  }

  Future check() async {
    String imei = await ImeiPlugin.getImei();
    List<String> multiImei = await ImeiPlugin.getImeiMulti(); //for double-triple SIM phones
    String uuid = await ImeiPlugin.getId();
    var build = await deviceInfoPlugin.androidInfo;

    var deviceInfo = {
      'tab': 1,
      'stylus': 1,
      'imei': imei,
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };

    // print(imei);
    // print(multiImei);
    // print(uuid);
    // print(build.manufacturer);
    // print(build.model);
    // print(  build.systemFeatures);

    print(deviceInfo);

    return OnlineDB.apiPost("tabs/check", {"deviceInfo": deviceInfo}).then((response) async {
      if (response.data["saved"] == true) {
        print("----------------------------------------");

        if (widget.nsUser.sections.length > 1) {
          await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SectionSelector(widget.nsUser)), (Route<dynamic> route) => false);
        }
        await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
      } else {
        ErrorMessageView(errorMessage: response.data).show(context);
      }
      print(response.data);

      return 1;
    }).catchError((onError) {
      print(onError);
    });
  }

  bool isTabWorking = false;
  bool haveStylus = false;
}
