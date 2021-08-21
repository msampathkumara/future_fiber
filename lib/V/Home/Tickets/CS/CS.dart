import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';

import 'SelectPdfPage.dart';

class CS extends StatefulWidget {
  final Ticket ticket;

  CS(this.ticket);

  @override
  _CSState createState() => _CSState();
}

class _CSState extends State<CS> with TickerProviderStateMixin {
  var tabs = ["All", "Cross Production"];
  TabController? _tabBarController;

  late Ticket ticket;
  var selectedPage;

  @override
  initState() {
    super.initState();
    ticket = widget.ticket;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: " + _tabBarController!.index.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectedPage == null
        ? SelectPdfPage(ticket, (selectedPage) {
          setState(() {
            this.selectedPage = selectedPage;
          });
          })
        : _tabBarController == null
            ? Container()
            : DefaultTabController(
                length: tabs.length,
                child: Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      toolbarHeight: 50,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.green,
                      elevation: 4.0,
                      bottom: TabBar(
                        controller: _tabBarController,
                        indicatorWeight: 4.0,
                        indicatorColor: Colors.white,
                        isScrollable: true,
                        tabs: [
                          for (final tab in tabs) Tab(text: tab),
                        ],
                      ),
                    ),
                    body: Column(
                      children: [
                        Expanded(
                          child: TabBarView(controller: _tabBarController, children: [
                            Container(),
                            Container(),
                          ]),
                        ),
                      ],
                    )),
              );
  }
}
