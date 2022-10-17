import 'package:device_info/device_info.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/Mobile/V/Home/Home.dart';
import 'package:smartwind/Mobile/V/Widgets/ErrorMessageView.dart';

import '../../../C/Api.dart';
import '../../../M/AppUser.dart';
import '../Widgets/UserImage.dart';
import 'SectionSelector.dart';

class CheckTabStatus extends StatefulWidget {
  final NsUser nsUser;

  const CheckTabStatus(this.nsUser);

  @override
  _CheckTabStatusState createState() => _CheckTabStatusState();
}

class _CheckTabStatusState extends State<CheckTabStatus> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => prefs = value);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, systemOverlayStyle: SystemUiOverlayStyle.dark),
        backgroundColor: Colors.white,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Wrap(direction: Axis.vertical, crossAxisAlignment: WrapCrossAlignment.center, children: [
                            UserImage(nsUser: widget.nsUser, radius: 100),
                            const SizedBox(height: 48),
                            const Text("Hi", textScaleFactor: 3),
                            Text(widget.nsUser.name, textScaleFactor: 3)
                          ]),
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
                                    title: const Text("Is Tab working without any problem ? \n( ටැබ් යන්ත්‍රය ගැටලුවකින් තොරව ක්‍රියා කරයිද ? )"),
                                    subtitle: const Text("")),
                                CheckboxListTile(
                                    controlAffinity: ListTileControlAffinity.leading,
                                    value: haveStylus,
                                    onChanged: (bool? value) {
                                      haveStylus = value!;
                                      setState(() {});
                                    },
                                    title: const Text("Is Stylus pen available ?\n( ස්ටයිලස් පෑන තිබේද ? )"),
                                    subtitle: const Text("")),
                                const Text(
                                  "If you are unable to agree with all of above conditions. please contact a production leader. \n( ඉහත සඳහන් කොන්දේසි සමග එකඟ විය නොහැකි නම්. ප්‍රොඩක්ශන් ලීඩර් අමතන්න ) ",
                                  style: TextStyle(color: Colors.red),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                if (!(isTabWorking && haveStylus)) const SizedBox(height: 50),
                                if (isTabWorking && haveStylus)
                                  ElevatedButton(
                                    child: const SizedBox(width: double.infinity, height: 50, child: Center(child: Text("Continue"))),
                                    onPressed: () {
                                      check();
                                      // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SectionSelector(widget.nsUser)), (Route<dynamic> route) => false);
                                    },
                                  )
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              ));
  }

  Future check() async {
    setLoading(true);

    PermissionStatus ps = await Permission.phone.request();
    if (!ps.isGranted) {
      return;
    }
    String imeiNo = await DeviceInformation.deviceIMEINumber;
    var build = await deviceInfoPlugin.androidInfo;

    var deviceInfo = {
      'tab': 1,
      'stylus': 1,
      'imei': imeiNo,
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
      'deviceName': await DeviceInformation.deviceName,
      'productName': await DeviceInformation.productName,
    };

    // print(imei);
    // print(multiImei);
    // print(uuid);
    // print(build.manufacturer);
    // print(build.model);
    // print(  build.systemFeatures);

    print(await DeviceInformation.deviceIMEINumber);
    print(await DeviceInformation.deviceName);
    print(deviceInfo);

    return Api.post(EndPoints.tab_check, {"deviceInfo": deviceInfo}).then((response) async {
      if (response.data["saved"] == true) {
        print("----------------------------------------");
        await prefs.setBool('tabCheck', true);

        if (widget.nsUser.sections.length > 1) {
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => UserSectionSelector(widget.nsUser, (Section section) {
                        AppUser.setSelectedSection(section);
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Home()), (Route<dynamic> route) => false);
                      })),
              (Route<dynamic> route) => false);
        }
        await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Home()), (Route<dynamic> route) => false);
      } else {
        ErrorMessageView(errorMessage: response.data).show(context);
      }
      print(response.data);
      setLoading(false);
      return 1;
    }).catchError((onError) {
      setLoading(false);
      print(onError);
    });
  }

  bool isTabWorking = false;
  bool haveStylus = false;

  bool _loading = false;

  void setLoading(bool bool) {
    setState(() {
      _loading = bool;
    });
  }
}
