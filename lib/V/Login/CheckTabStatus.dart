import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

import 'SectionSelector.dart';

class CheckTabStatus extends StatefulWidget {
  final NsUser nsUser;

  const CheckTabStatus(this.nsUser);

  @override
  _CheckTabStatusState createState() => _CheckTabStatusState();
}

class _CheckTabStatusState extends State<CheckTabStatus> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
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
                      ElevatedButton(
                        child: SizedBox(width: double.infinity, height: 50, child: Center(child: Text("Continue"))),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SectionSelector(widget.nsUser)), (Route<dynamic> route) => false);
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

  bool isTabWorking = false;
  bool haveStylus = false;
}
