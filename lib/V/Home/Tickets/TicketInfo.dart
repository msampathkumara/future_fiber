import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/M/Ticket.dart';

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
  }

  @override
  void dispose() {
    super.dispose();
  }

  var bottomNavigationBarItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: const Icon(Icons.info),
      label: "Info",
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.flag),
      label: "Flags",
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: bottomNavigationBarItems,
        backgroundColor: Colors.orange,
        selectedItemColor: Colors.black,
        currentIndex: bottomNavigationBarSelectedIndex,
        unselectedItemColor: Colors.white,
        onTap: (index) {
          setState(() {
            bottomNavigationBarSelectedIndex = index;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
    double height = MediaQuery.of(context).size.height;
    var ts = TextStyle(color: Colors.white, fontSize: 24);
    var smallText = TextStyle(fontSize: 16);
    return AppBar(
      backgroundColor: Colors.orange,
      elevation: 10,
      toolbarHeight: (bottomNavigationBarSelectedIndex == 0) ? (height - kBottomNavigationBarHeight) : 230,
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

  _body(int index) {}
}
