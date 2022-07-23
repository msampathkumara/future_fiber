import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/Ticket.dart';

import '../../../../../C/ServerResponse/ServerResponceMap.dart';
import 'RF.dart';

class FinishCheckList extends StatefulWidget {
  final Ticket ticket;

  const FinishCheckList(this.ticket, {Key? key}) : super(key: key);

  @override
  _FinishCheckListState createState() {
    return _FinishCheckListState();
  }
}

class _FinishCheckListState extends State<FinishCheckList> {
  Map? checkListMap;

  late Ticket ticket;

  @override
  void initState() {
    super.initState();
    ticket = widget.ticket;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return FutureBuilder(
        future: _loadData(), // async work
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Text('Loading....');
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return AlertDialog(
                    actions: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.green, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            finish("Excellent");
                          },
                          child: const Text("Excellent")),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.lightGreen, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            finish("Good");
                          },
                          child: const Text("Good")),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.redAccent, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              SystemNavigator.pop();
                            }

                            var isQc = false;
                            if (AppUser.getSelectedSection()?.sectionTitle.toLowerCase() == "qc") {
                              isQc = true;
                            }

                            var xx = await platform.invokeMethod('qcEdit', {
                              "qc": isQc,
                              "sectionId": "${AppUser.getSelectedSection()?.id}",
                              "serverUrl": Server.getServerApiPath("tickets/qc/uploadEdits"),
                              'ticket': {'id': ticket.id, "qc": isQc}.toString()
                            });
                          },
                          child: const Text("Quality Reject"))
                    ],
                    content: SizedBox(
                        height: 200,
                        child: Scaffold(
                            body: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: const [
                          Text("Please Rate the quality of your work", textScaleFactor: 1.5, textAlign: TextAlign.center),
                          Text("කරුණාකර ඔබගේ කාර්යය ගුණාත්මකභාවය ඇගයීමට ලක්කරන්න", textScaleFactor: 1.2, textAlign: TextAlign.center)
                        ]))));
              }
          }
        });
  }

  static const platform = MethodChannel('editPdf');

  _loadData() async {
    var x = DefaultAssetBundle.of(context);
    var data = await x.loadString("assets/QACheckList.json");
    checkListMap = json.decode(data);
    return checkListMap;
  }

  Future<void> finish(String quality) async {
    var isQc = false;
    if (AppUser.getSelectedSection()?.sectionTitle.toLowerCase() == "qc") {
      isQc = true;
    }

    await showDialog(
        context: context,
        builder: (BuildContext context1) {
          Api.get("users/getRfCredentials", {}).then((response) async {
            ServerResponseMap res = ServerResponseMap.fromJson((response.data));
            var r = await OnlineDB.apiGet("tickets/finish/getProgress", {'ticket': ticket.id.toString()});
            ServerResponseMap res1 = ServerResponseMap.fromJson((r.data));

            if (mounted) Navigator.of(context1).pop();

            if (res.userRFCredentials != null) {
              if (mounted) await ticket.getFile(context);
              if (res1.done != null) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('Already Completed')));
              } else if (ticket.ticketFile != null) {
                if (mounted) {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => RF(ticket, res.userRFCredentials!, res1.operationMinMax!, res1.progressList)));
                  await LoadingDialog(
                      Api.post("tickets/qc/uploadEdits", {'quality': quality, 'ticketId': ticket.id, 'type': isQc, "sectionId": "${AppUser.getSelectedSection()?.id}"}).then((res) {
                    Map data = res.data;
                  }));
                }
              }

              if (mounted) Navigator.pop(context);
            }
          });

          return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(builder: (context) {
                return const SizedBox(height: 150, width: 50, child: Center(child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator())));
              }));
        });
  }

  Future LoadingDialog(Future future) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context1) {
          future.then((value) {
            Navigator.of(context1).pop();
          });

          return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(builder: (context) {
                return const SizedBox(height: 150, width: 50, child: Center(child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator())));
              }));
        });
  }
}
