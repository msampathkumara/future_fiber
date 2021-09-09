import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartwind/M/NsUser.dart';

class NfcScan extends StatefulWidget {
    late _NfcScanState state;
  final NsUser nsUser;

  NfcScan(this.nsUser);

  @override
  _NfcScanState createState() {
    state = _NfcScanState();
    return state;
  }

  void show(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => this),
    );
  }

  void close(context) {
    Navigator.of(context).pop();
  }
}

class _NfcScanState extends State<NfcScan> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container();

    // TODO: implement build
    // return Scaffold(
    //   body: Center(
    //       child: Wrap(
    //     alignment: WrapAlignment.center,
    //     direction: Axis.vertical,
    //     crossAxisAlignment: WrapCrossAlignment.center,
    //     children: [
    //       Icon(Icons.badge_outlined, size: 255, color: Colors.grey),
    //       Text("Scan ID Card",
    //           style: TextStyle(fontSize: 48), textAlign: TextAlign.center)
    //     ],
    //   )),
    // );
  }
}