import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/C/ServerResponce/Progress.dart';
import 'package:smartwind/C/ServerResponce/ServerResponceMap.dart';
import 'package:smartwind/C/ServerResponce/TicketHistory.dart';
import 'package:smartwind/C/ServerResponce/TicketPrint.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/V/Home/Tickets/TicketInfo/info_Printing.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';

import 'info_Flags.dart';
import 'info_History.dart';
import 'info_Progress.dart';

class TicketInfo extends StatefulWidget {
  Ticket ticket;

  TicketInfo(this.ticket, {Key? key}) : super(key: key);

  @override
  _TicketInfoState createState() {
    return _TicketInfoState();
  }

  void show(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => this),
    );
  }
}

class _TicketInfoState extends State<TicketInfo> {
  late Ticket _ticket;
  late int _progress = 0;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    new Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _progress = _ticket.progress;
      });
    });

    getData(_ticket);
  }

  @override
  void dispose() {
    super.dispose();
  }

  var bottomNavigationBarItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: const Icon(Icons.data_usage),
      label: "Progress",
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.flag),
      label: "Flags",
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.print),
      label: "Printing",
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.history),
      label: "History",
    ),
  ];
  int bottomNavigationBarSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(bottomNavigationBarSelectedIndex),
      appBar: _appBar(),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
          color: Colors.orange,
          shape: CircularNotchedRectangle(),
          notchMargin: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _getBottomNavigationBarItem(Icons.tour_rounded, ("Flags"), 0),
                _getBottomNavigationBarItem(Icons.data_usage_rounded, ("Progress"), 1),
                _getBottomNavigationBarItem(Icons.print_rounded, ("Printing"), 2),
                _getBottomNavigationBarItem(Icons.history_rounded, ("History"), 3),
              ],
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.import_contacts),
        onPressed: () {
          setState(() {
            _ticket.open(context);
          });
        },
      ),
    );
  }

  _appBar() {
    double height = MediaQuery
        .of(context)
        .size
        .height;
    var ts = TextStyle(color: Colors.white, fontSize: 24);
    var smallText = TextStyle(fontSize: 16);
    return AppBar(
      backgroundColor: Colors.orange,
      elevation: 10,
      // toolbarHeight: (bottomNavigationBarSelectedIndex == 0) ? (height - kBottomNavigationBarHeight) : 230,
      toolbarHeight: 230,
      bottom: PreferredSize(
          child: Container(
            color: Colors.orange,
            height: 200.0,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _ticket.mo ?? "_",
                        style: ts,
                      ),
                      Text(
                        _ticket.oe ?? "_",
                        style: ts,
                      ),
                      Text(
                        _ticket.production ?? "_",
                        style: ts.merge(smallText),
                      ),
                      Text(
                        "update on : " + (_ticket.getUpdateDateTime()),
                        style: ts.merge(smallText),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          child: Wrap(
                            children: [
                              if (_ticket.inPrint == 1)
                                IconButton(
                                  icon: CircleAvatar(child: Icon(Icons.print_rounded, color: Colors.deepOrangeAccent), backgroundColor: Colors.white),
                                  onPressed: () {},
                                ),
                              if (_ticket.isHold == 1)
                                IconButton(
                                  icon: CircleAvatar(child: Icon(Icons.pan_tool_rounded, color: Colors.black), backgroundColor: Colors.white),
                                  onPressed: () {},
                                ),
                              if (_ticket.isGr == 1)
                                IconButton(
                                  icon: CircleAvatar(backgroundColor: Colors.blue, child: Center(child: Text("GR", style: TextStyle(color: Colors.white)))),
                                  onPressed: () {},
                                ),
                              if (_ticket.isSk == 1)
                                IconButton(
                                  icon: CircleAvatar(backgroundColor: Colors.pink, child: Center(child: Text("SK", style: TextStyle(color: Colors.white)))),
                                  onPressed: () {},
                                ),
                              if (_ticket.isError == 1)
                                IconButton(
                                  icon: CircleAvatar(child: Icon(Icons.report_problem_rounded, color: Colors.red), backgroundColor: Colors.white),
                                  onPressed: () {},
                                ),
                              if (_ticket.isSort == 1)
                                IconButton(
                                  icon: CircleAvatar(child: Icon(Icons.local_mall_rounded, color: Colors.green), backgroundColor: Colors.white),
                                  onPressed: () {},
                                ),
                              if (_ticket.isRush == 1)
                                IconButton(
                                  icon: CircleAvatar(child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent), backgroundColor: Colors.white),
                                  onPressed: () {},
                                ),
                              if (_ticket.isRed == 1)
                                IconButton(
                                  icon: CircleAvatar(child: Icon(Icons.tour_rounded, color: Colors.red), backgroundColor: Colors.white),
                                  onPressed: () {},
                                )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      new CircularPercentIndicator(
                          radius: 100.0,
                          lineWidth: 4.0,
                          percent: (_progress / 100).toDouble(),
                          center: new Text(_ticket.progress.toString() + "%", style: ts),
                          progressColor: Colors.blue,
                          animateFromLastPercent: true,
                          animation: true,
                          animationDuration: 500)
                    ],
                  ),
                )
              ],
            ),
          ),
          preferredSize: Size.fromHeight(4.0)),
    );
  }

  _body(int index) {
    switch (index) {
      case 0:
        return info_Flags(flags, flagsHistory);
      case 1:
        return info_Progress(progressList);
      case 2:
        return info_Printing(printList);
      case 3:
        return info_History(ticketHistory);
    }
  }

  List<Progress> progressList = [];
  List<TicketFlag> flags = [];
  List<TicketFlag> flagsHistory = [];
  List<TicketPrint> printList = [];
  List<TicketHistory> ticketHistory = [];

  void getData(Ticket _ticket) {
    print('requesting data---------------');
    OnlineDB.apiGet(("tickets/info/getTicketInfo"), {'ticket': _ticket.id.toString()}).then((value) {
      print(' data recived---------------');
      print((value.body));
      setState(() {
        ServerResponceMap res = ServerResponceMap.fromJson(json.decode(value.body));
        progressList = res.progressList;
        flags = res.flags;
        flagsHistory = res.flagsHistory;
        printList = res.printList;
        ticketHistory = res.ticketHistory;
      });

      // ErrorMessageView(errorMessage: value.body).show(context);
    }).onError((error, stackTrace) {
      print(stackTrace.toString());
      ErrorMessageView(errorMessage: error.toString()).show(context);
    });
  }

  _getBottomNavigationBarItem(IconData icon, String text, int i) {
    return InkResponse(
        splashColor: Colors.white,
        radius: 110,
        child: SizedBox(
          width: 100,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: bottomNavigationBarSelectedIndex == i ? Colors.white : Colors.black),
            Text(text, style: TextStyle(color: bottomNavigationBarSelectedIndex == i ? Colors.white : Colors.black))
          ]),
        ),
        onTap: () {
          setState(() {
            bottomNavigationBarSelectedIndex = i;
          });
        });
  }
}
