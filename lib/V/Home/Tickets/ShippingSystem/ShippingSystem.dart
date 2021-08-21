import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/Tickets/CS/SelectPdfPage.dart';

class ShippingSystem extends StatefulWidget {
  final Ticket ticket;

  ShippingSystem(this.ticket);

  @override
  _ShippingSystemState createState() => _ShippingSystemState();
}

class _ShippingSystemState extends State<ShippingSystem> with TickerProviderStateMixin {
  var tabs = ["All", "Cross Production"];
  TabController? _tabBarController;
  late Ticket ticket;

  @override
  initState() {
    ticket = widget.ticket;
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: " + _tabBarController!.index.toString());
      });
    });


  }

  @override
  Widget build(BuildContext context) {
    return _tabBarController == null
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
                body: TabBarView(controller: _tabBarController, children: [Container(), Container()])),
          );
  }
}
