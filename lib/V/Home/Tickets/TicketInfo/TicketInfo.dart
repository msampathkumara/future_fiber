import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/M/TicketHistory.dart';
import 'package:smartwind/V/Home/Tickets/TicketInfo/info_Printing.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/ns_icons_icons.dart';

import '../../../../C/DB/DB.dart';
import '../../../../C/ServerResponse/Progress.dart';
import '../../../../C/ServerResponse/ServerResponceMap.dart';
import '../../../../M/TicketPrint.dart';
import '../../../../M/hive.dart';
import 'info_Flags.dart';
import 'info_History.dart';
import 'info_Progress.dart';

class TicketInfo extends StatefulWidget {
  final Ticket ticket;

  const TicketInfo(this.ticket, {Key? key}) : super(key: key);

  @override
  _TicketInfoState createState() {
    return _TicketInfoState();
  }

  void show(context) {
    kIsWeb
        ? showDialog(
            context: context,
            builder: (_) => this,
          )
        : Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => this),
          );
  }
}

class _TicketInfoState extends State<TicketInfo> {
  late Ticket _ticket;
  late int _progress = 0;

  bool _loading = true;
  late DbChangeCallBack _dbChangeCallBack;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _progress = _ticket.progress;
      });
    });

    getData(_ticket);
    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update tickets');
      if (mounted) {
        var _ticket_ = HiveBox.ticketBox.get(_ticket.id);
        if (_ticket_ != null && _ticket_.uptime != _ticket.uptime) {
          _ticket = _ticket_;
          getData(_ticket);
        }
      }
    }, context, collection: DataTables.standardTickets);
  }

  @override
  void dispose() {
    _dbChangeCallBack.dispose();
    super.dispose();
  }

  var bottomNavigationBarItems = <BottomNavigationBarItem>[
    const BottomNavigationBarItem(
      icon: Icon(Icons.data_usage),
      label: "Progress",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.flag),
      label: "Flags",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.print),
      label: "Printing",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.history),
      label: "History",
    ),
  ];
  int bottomNavigationBarSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? DialogView(child: getWebUi(), width: 1000)
        : Scaffold(
      body: _loading ? const Center(child: CircularProgressIndicator()) : _body(bottomNavigationBarSelectedIndex),
            appBar: _appBar(),
            backgroundColor: Colors.white,
            bottomNavigationBar: BottomAppBar(
                color: Colors.orange,
                shape: const CircularNotchedRectangle(),
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
            floatingActionButton: _ticket.isHold == 1
                ? null
                : FloatingActionButton(
                    child: const Icon(Icons.import_contacts),
                    onPressed: () {
                      _ticket.open(context);
                    },
                  ),
          );
  }

  var ts = const TextStyle(color: Colors.white, fontSize: 24);
  var smallText = const TextStyle(fontSize: 16);
  var xsmallText = const TextStyle(fontSize: 12);

  _appBar() {
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
                      Text(_ticket.mo ?? "_", style: ts),
                      Text(_ticket.oe ?? "_", style: ts),
                      Text(_ticket.production ?? "_", style: ts.merge(smallText)),
                      Text("update on : " + (_ticket.getUpdateDateTime()), style: ts.merge(smallText)),
                      Text("Ship Date : ${_ticket.shipDate}", style: ts.merge(smallText)),
                      Text("Delivery Date : ${_ticket.deliveryDate}", style: ts.merge(smallText)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          child: Wrap(
                            children: [
                              if (_ticket.inPrint == 1)
                                IconButton(
                                    icon: const CircleAvatar(child: Icon(Icons.print_rounded, color: Colors.deepOrangeAccent), backgroundColor: Colors.white), onPressed: () {}),
                              if (_ticket.isHold == 1)
                                IconButton(icon: const CircleAvatar(child: Icon(Icons.pan_tool_rounded, color: Colors.black), backgroundColor: Colors.white), onPressed: () {}),
                              if (_ticket.isGr == 1)
                                IconButton(icon: const CircleAvatar(child: Icon(NsIcons.gr, color: Colors.blue), backgroundColor: Colors.white), onPressed: () {}),
                              if (_ticket.isSk == 1)
                                IconButton(icon: const CircleAvatar(child: Icon(NsIcons.sk, color: Colors.pink), backgroundColor: Colors.white), onPressed: () {}),
                              if (_ticket.isError == 1)
                                IconButton(icon: const CircleAvatar(child: Icon(Icons.report_problem_rounded, color: Colors.red), backgroundColor: Colors.white), onPressed: () {}),
                              if (_ticket.isSort == 1)
                                IconButton(icon: const CircleAvatar(child: Icon(Icons.local_mall_rounded, color: Colors.green), backgroundColor: Colors.white), onPressed: () {}),
                              if (_ticket.isRush == 1)
                                IconButton(
                                    icon: const CircleAvatar(child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent), backgroundColor: Colors.white), onPressed: () {}),
                              if (_ticket.isRed == 1)
                                IconButton(icon: const CircleAvatar(child: Icon(Icons.tour_rounded, color: Colors.red), backgroundColor: Colors.white), onPressed: () {})
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularPercentIndicator(
                      radius: 50.0,
                      lineWidth: 4.0,
                      percent: (_progress / 100).toDouble(),
                      center: Text(_ticket.progress.toString() + "%", style: ts),
                      progressColor: Colors.blue,
                      animateFromLastPercent: true,
                      animation: true,
                      animationDuration: 500),
                )
              ],
            ),
          ),
          preferredSize: const Size.fromHeight(4.0)),
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
        return InfoHistory(ticketHistory);
    }
  }

  List<Progress> progressList = [];
  List<TicketFlag> flags = [];
  List<TicketFlag> flagsHistory = [];
  List<TicketPrint> printList = [];
  List<TicketHistory> ticketHistory = [];

  void getData(Ticket _ticket) {
    setState(() {
      _loading = true;
    });
    print('requesting data---------------');
    OnlineDB.apiGet(("tickets/info/getTicketInfo"), {'ticket': _ticket.id.toString()}).then((value) {
      print(' data recived---------------');
      print((value.data));

      setState(() {
        ServerResponseMap res = ServerResponseMap.fromJson((value.data));
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
      ErrorMessageView(errorMessage: stackTrace.toString()).show(context);
    }).whenComplete(() {
      setState(() {
        _loading = false;
      });
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

  var visualDensity = const VisualDensity(horizontal: 0, vertical: -4);

  getWebUi() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          SizedBox(
              width: 300,
              child: Container(
                color: Colors.orange,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ListTile(visualDensity: visualDensity, title: Text(_ticket.mo ?? "_", style: ts), subtitle: Text(_ticket.oe ?? "_", style: ts)),
                          ListTile(
                              visualDensity: visualDensity,
                              title: Text(_ticket.production ?? "_", style: ts.merge(smallText)),
                              subtitle: Text(_ticket.atSection, style: ts.merge(smallText))),
                          ListTile(
                              visualDensity: visualDensity,
                              title: Text("Update on : ", style: ts.merge(xsmallText)),
                              subtitle: Text(_ticket.getUpdateDateTime(), style: ts.merge(smallText))),
                          if (_ticket.shipDate.isNotEmpty)
                            ListTile(
                                visualDensity: visualDensity,
                                title: Text("Ship Date : ", style: ts.merge(xsmallText)),
                                subtitle: Text(_ticket.shipDate, style: ts.merge(smallText))),
                          if (_ticket.deliveryDate.isNotEmpty)
                            ListTile(
                                visualDensity: visualDensity,
                                title: Text("Delivery Date : ", style: ts.merge(xsmallText)),
                                subtitle: Text(_ticket.deliveryDate, style: ts.merge(smallText))),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              child: Wrap(
                                children: [
                                  if (_ticket.inPrint == 1)
                                    IconButton(
                                        icon: const CircleAvatar(child: Icon(Icons.print_rounded, color: Colors.deepOrangeAccent), backgroundColor: Colors.white),
                                        onPressed: () {}),
                                  if (_ticket.isHold == 1)
                                    IconButton(icon: const CircleAvatar(child: Icon(Icons.pan_tool_rounded, color: Colors.black), backgroundColor: Colors.white), onPressed: () {}),
                                  if (_ticket.isGr == 1)
                                    IconButton(icon: const CircleAvatar(child: Icon(NsIcons.gr, color: Colors.blue), backgroundColor: Colors.white), onPressed: () {}),
                                  if (_ticket.isSk == 1)
                                    IconButton(icon: const CircleAvatar(child: Icon(NsIcons.sk, color: Colors.pink), backgroundColor: Colors.white), onPressed: () {}),
                                  if (_ticket.isError == 1)
                                    IconButton(
                                        icon: const CircleAvatar(child: Icon(Icons.report_problem_rounded, color: Colors.red), backgroundColor: Colors.white), onPressed: () {}),
                                  if (_ticket.isSort == 1)
                                    IconButton(
                                        icon: const CircleAvatar(child: Icon(Icons.local_mall_rounded, color: Colors.green), backgroundColor: Colors.white), onPressed: () {}),
                                  if (_ticket.isRush == 1)
                                    IconButton(
                                        icon: const CircleAvatar(child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent), backgroundColor: Colors.white), onPressed: () {}),
                                  if (_ticket.isRed == 1)
                                    IconButton(icon: const CircleAvatar(child: Icon(Icons.tour_rounded, color: Colors.red), backgroundColor: Colors.white), onPressed: () {}),
                                  if (_ticket.crossPro == 1)
                                    IconButton(
                                        icon: const CircleAvatar(child: Icon(Icons.merge_type_rounded, color: Colors.green), backgroundColor: Colors.white), onPressed: () {})
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularPercentIndicator(
                          radius: 50.0,
                          lineWidth: 4.0,
                          percent: (_progress / 100).toDouble(),
                          center: Text(_ticket.progress.toString() + "%", style: ts),
                          progressColor: Colors.blue,
                          animateFromLastPercent: true,
                          animation: true,
                          animationDuration: 500),
                    )
                  ],
                ),
              )),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Row(children: [
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, color: Colors.black))
                  ]),
                  backgroundColor: Colors.white),
              body: _loading ? const Center(child: CircularProgressIndicator()) : _body(bottomNavigationBarSelectedIndex),
              backgroundColor: Colors.white,
              bottomNavigationBar: BottomAppBar(
                  elevation: 16,
                  color: Colors.orange,
                  shape: const CircularNotchedRectangle(),
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
              floatingActionButton: _ticket.isHold == 1
                  ? null
                  : FloatingActionButton(
                child: const Icon(Icons.import_contacts),
                      onPressed: () {
                        _ticket.open(context);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
