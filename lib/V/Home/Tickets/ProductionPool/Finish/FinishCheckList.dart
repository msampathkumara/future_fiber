import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind/C/App.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/C/ServerResponce/ServerResponceMap.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Widgets/Loading.dart';

import 'RF.dart';

class FinishCheckList extends StatefulWidget {
  final Ticket ticket;

  FinishCheckList(this.ticket, {Key? key}) : super(key: key);

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
              return Text('Loading....');
            default:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              else
                return AlertDialog(
                  title: Text("Check List"),
                  content: Container(
                    height: height / 2,
                    width: width - 200,
                    child: Scaffold(
                        body: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              itemCount: checkListMap!["layout"].length,
                              itemBuilder: (BuildContext context, int index) {
                                var t = checkListMap!["layout"][index];
                                return ListTile(
                                  title: Text(
                                    t,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                );
                              }),
                        )
                      ],
                    )),
                  ),
                  actions: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.green, textStyle: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          var loadingWidget = Loading(
                            loadingText: "Loading",
                            showProgress: false,
                          );

                          loadingWidget.show(context);
                          OnlineDB.apiGet("users/getRfCredentials", {}).then((response) async {
                            print(response.data);
                            ServerResponceMap res = ServerResponceMap.fromJson((response.data));
                            var r = await OnlineDB.apiGet("tickets/finish/getProgress", {'ticket': ticket.id.toString()});
                            ServerResponceMap res1 = ServerResponceMap.fromJson((r.data));

                            loadingWidget.close(context);
                            if (res.userRFCredentials != null) {
                              print("-------------------------------------");
                              print(res1.toJson());
                              await ticket.getFile(context);
                              if (res1.done != null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Already Completed')));
                              } else if (ticket.ticketFile != null) {
                                await Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => RF(ticket, res.userRFCredentials!, res1.operationMinMax!, res1.progressList)));
                              }
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                SystemNavigator.pop();
                              }
                            }
                          });
                        },
                        child: Text("Agree")),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.redAccent, textStyle: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            SystemNavigator.pop();
                          }
                          App.getCurrentUser().then((user) async {
                            var isQc = false;
                            if (user!.section!.sectionTitle.toLowerCase() == "qc") {
                              isQc = true;
                            }

                            var xx = await platform.invokeMethod('qcEdit', {
                              'ticket': {'id': ticket.id, "qc": isQc}.toString()
                            });
                          });



                        },
                        child: Text("Disagree"))
                  ],
                );
          }
        });
  }

  static const platform = const MethodChannel('editPdf');

  _loadData() async {
    var x = DefaultAssetBundle.of(context);
    var data = await x.loadString("assets/QACheckList.json");
    checkListMap = json.decode(data);
    return checkListMap;
  }
}
