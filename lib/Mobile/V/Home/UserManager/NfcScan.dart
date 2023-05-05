import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/NsUser.dart';

class NfcScan extends StatefulWidget {
  final NsUser nsUser;

  const NfcScan(this.nsUser, {super.key});

  @override
  _NfcScanState createState() {
    return _NfcScanState();
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
