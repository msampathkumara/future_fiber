import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:smartwind/C/App.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/C/ServerResponce/ServerResponceMap.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Widgets/Loading.dart';

import 'RF.dart';

class FinishCheckList extends StatefulWidget {
  Ticket ticket;

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
                return Scaffold(
                    appBar: AppBar(title: Text("Check List")),
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
                                    style: TextStyle(fontSize: 30),
                                  ),
                                );
                              }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                        textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      var loadingWidget = Loading(
                                        loadingText: "Loading",
                                        showProgress: false,
                                      );

                                      loadingWidget.show(context);
                                      OnlineDB.apiGet("users/getRfCredentials", {}).then((http.Response response) async {
                                        print(response.body);
                                        ServerResponceMap res = ServerResponceMap.fromJson(json.decode(response.body));
                                        var r = await OnlineDB.apiGet("tickets/finish/getMaxMinOpNo", {'ticket': ticket.id.toString()});
                                        ServerResponceMap res1 = ServerResponceMap.fromJson(json.decode(r.body));

                                        NsUser? user = await App.getCurrentUser();

                                        print(user!.toJson());

                                        loadingWidget.close(context);
                                        if (res.userRFCredentials != null) {
                                          print("-------------------------------------");
                                          print(ticket.toJson());
                                          await ticket.getFile(context);
                                          if (res1.done != null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Already Completed')));
                                          } else if (ticket.ticketFile != null) {
                                            await Navigator.push(context,
                                                MaterialPageRoute(builder: (context) => RF(ticket, res.userRFCredentials!, res1.operationMinMax!)));
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
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.redAccent,
                                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                        textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                                    onPressed: () {},
                                    child: Text("Disagree")),
                              ),
                            ),
                          ],
                        )
                      ],
                    ));
          }
        });
  }

  _loadData() async {
    var x = DefaultAssetBundle.of(context);
    var data = await x.loadString("assets/QACheckList.json");
    checkListMap = json.decode(data);
    return checkListMap;
  }
}
