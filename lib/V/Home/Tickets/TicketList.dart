import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/Tickets/ProductionPool/Finish/FinishCheckList.dart';
import 'package:smartwind/V/Widgets/FlagDialog.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';

import 'TicketInfo.dart';

class TicketList extends StatefulWidget {
  TicketList();

  @override
  _TicketListState createState() {
    return _TicketListState();
  }
}

class _TicketListState extends State<TicketList>
    with SingleTickerProviderStateMixin {
  var database;
  late int _selectedTabIndex;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _TabBarcontroller = TabController(length: tabs.length, vsync: this);
      _TabBarcontroller!.addListener(() {
        // loadData().then((value) {
        //   setState(() {});
        // });
        print("Selected Index: " + _TabBarcontroller!.index.toString());
      });
      reloadData();
      DB.setOnDBChangeListener(() {
        reloadData();
      });
    });
  }

  late List listsArray;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (s) {
                print(s);
                _showAllTickets = !_showAllTickets;
              },
              itemBuilder: (BuildContext context) {
                return {"Show All Tickets"}.map((String choice) {
                  return CheckedPopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                    checked: _showAllTickets,
                  );
                }).toList();
              },
            ),
          ],
          elevation: 0.0,
          toolbarHeight: 150,
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Production Pool",
            textScaleFactor: 1.2,
          ),
          bottom: SearchBar(
            onSearchTextChanged: (text) {
              if (subscription != null) {
                subscription.cancel();
              }
              searchText = text;

              var future =
                  new Future.delayed(const Duration(milliseconds: 300));
              subscription = future.asStream().listen((v) {
                print("SEARCHING FOR ${searchText}");
                var t = DateTime.now().millisecondsSinceEpoch;
                loadData().then((value) {
                  print(
                      "SEARCHING time ${(DateTime.now().millisecondsSinceEpoch - t)}");
                  t = DateTime.now().millisecondsSinceEpoch;
                  setState(() {});
                  print(
                      "load time ${(DateTime.now().millisecondsSinceEpoch - t)}");
                });
              });
            },
            onSubmitted: (text) {},
            OnBarcode: (barcode) {
              print("xxxxxxxxxxxxxxxxxx ${barcode}");
            },
          ),
          centerTitle: true,
        ),
        body: getBody(),
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            color: Colors.green,
            child: IconTheme(
              data: IconThemeData(color: Colors.white),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currentFileList.length.toString(),
                      textScaleFactor: 1.1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Sorted by ${sorted_by}",
                    style: TextStyle(color: Colors.white),
                  ),
                  InkWell(
                    onTap: () {},
                    splashColor: Colors.red,
                    child: Ink(
                      child: IconButton(
                        icon: FaIcon(FontAwesomeIcons.sortAlphaDown),
                        onPressed: () {
                          _sortByBottomSheetMenu();
                        },
                      ),
                    ),
                  )
                ],
              ),
            )));
  }

  String listSortBy = "uptime";
  String sorted_by = "Date";
  String searchText = "";
  var subscription;
  bool _showAllTickets = false;
  List<Map> currentFileList = [];

  void _sortByBottomSheetMenu() {
    getListItem(String title, icon, key) {
      return ListTile(
        title: Text(title),
        selectedTileColor: Colors.black12,
        selected: listSortBy == key,
        leading: icon is IconData ? FaIcon(icon) : icon,
        onTap: () {
          listSortBy = key;
          sorted_by = title;
          Navigator.pop(context);
          loadData().then((value) {
            setState(() {});
          });
        },
      );
    }

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        context: context,
        builder: (builder) {
          return Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Sort By",
                    textScaleFactor: 1.2,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ListView(
                        children: [
                          getListItem(
                              "Date", FontAwesomeIcons.calendarDay, "uptime"),
                          getListItem("Name", FontAwesomeIcons.amazon, "name"),
                          getListItem("Red Flag", FontAwesomeIcons.flag, "red"),
                          getListItem(
                              "Hold", FontAwesomeIcons.handRock, "hold"),
                          getListItem("Rush", FontAwesomeIcons.bolt, "rush"),
                          getListItem(
                              "SK",
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Center(
                                  child: Text(
                                    "SK",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              "sk"),
                          getListItem(
                              "GR",
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Center(
                                  child: Text(
                                    "GR",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              "gr"),
                          getListItem(
                              "Short", FontAwesomeIcons.shoppingBasket, "sort"),
                          getListItem("Error Route",
                              FontAwesomeIcons.exclamationTriangle, "errOut"),
                          getListItem(
                              "Print", FontAwesomeIcons.print, "inprint"),
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }

  final tabs = ["All", "Upwind", "OD", "Nylon", "OEM", "No Pool"];
  TabController? _TabBarcontroller;

  getBody() {
    return _TabBarcontroller == null
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
                  controller: _TabBarcontroller,
                  indicatorWeight: 4.0,
                  indicatorColor: Colors.white,
                  // onTap: (d) {
                  //   setState(() {
                  //     print("refresh ${_selectedTabIndex}");
                  //     currentFileList = listsArray[_selectedTabIndex];
                  //   });
                  // },
                  isScrollable: true,
                  tabs: [
                    for (final tab in tabs) Tab(text: tab),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _TabBarcontroller,
                children: [
                  GetTicketListByCategoty(AllFilesList),
                  GetTicketListByCategoty(UpwindFilesList),
                  GetTicketListByCategoty(ODFilesList),
                  GetTicketListByCategoty(NylonFilesList),
                  GetTicketListByCategoty(OEMFilesList),
                  GetTicketListByCategoty(NoPoolFilesList),
                ],
              ),
            ),
          );
  }

  final int CAT_ALL = 0;
  final int CAT_UPWIND = 1;
  final int CAT_OD = 2;
  final int CAT_NYLON = 3;
  final int CAT_OEM = 4;

  // var indicator = new GlobalKey<RefreshIndicatorState>();

  GetTicketListByCategoty(List<Map<String, dynamic>> FilesList) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              return DB.updateDatabase().then((value) {
                return loadData().then((value) {
                  setState(() {});
                });
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: FilesList.length,
                itemBuilder: (BuildContext context, int index) {
                  // print(FilesList[index]);
                  Ticket ticket = Ticket.fromJson(FilesList[index]);
                  // print(ticket.toJson());
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: () async {
                      await showTicketOptions(ticket, context);
                      setState(() {});
                    },
                    onTap: () {
                      var ticketInfo = TicketInfo(ticket);
                      ticketInfo.show(context);
                    },
                    onDoubleTap: () async {
                      print(await ticket.getLocalFileVersion());
                      ticket.open(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                          color: ticket.isHold == 1
                              ? Colors.black12
                              : Colors.white,
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: ListTile(
                        leading: Text("${index + 1}"),
                        title: Text(ticket.mo ?? ""),
                        subtitle: Text(ticket.getUpdateDateTime()),
                        // subtitle: Text(ticket.fileVersion.toString()),
                        trailing: Wrap(
                          children: [
                            if (ticket.inPrint == 1)
                              IconButton(
                                icon: Icon(Icons.print_outlined,
                                    color: Colors.deepOrangeAccent),
                                onPressed: () {},
                              ),
                            if (ticket.isHold == 1)
                              IconButton(
                                icon: Icon(FontAwesomeIcons.handRock,
                                    color: Colors.black),
                                onPressed: () {},
                              ),
                            if (ticket.isGr == 1)
                              IconButton(
                                icon: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Center(
                                    child: Text(
                                      "GR",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                onPressed: () {},
                              ),
                            if (ticket.isSk == 1)
                              IconButton(
                                icon: CircleAvatar(
                                  backgroundColor: Colors.pink,
                                  child: Center(
                                    child: Text(
                                      "SK",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                onPressed: () {},
                              ),
                            if (ticket.isError == 1)
                              IconButton(
                                icon: Icon(FontAwesomeIcons.exclamationTriangle,
                                    color: Colors.red),
                                onPressed: () {},
                              ),
                            if (ticket.isSort == 1)
                              IconButton(
                                icon: Icon(FontAwesomeIcons.shoppingBasket,
                                    color: Colors.green),
                                onPressed: () {},
                              ),
                            if (ticket.isRush == 1)
                              IconButton(
                                icon: Icon(FontAwesomeIcons.bolt,
                                    color: Colors.orangeAccent),
                                onPressed: () {},
                              ),
                            if (ticket.isRed == 1)
                              IconButton(
                                icon: Icon(FontAwesomeIcons.fontAwesomeFlag,
                                    color: Colors.red),
                                onPressed: () {},
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 1,
                    endIndent: 0.5,
                    color: Colors.black12,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> AllFilesList = [];
  List<Map<String, dynamic>> UpwindFilesList = [];
  List<Map<String, dynamic>> ODFilesList = [];
  List<Map<String, dynamic>> NylonFilesList = [];
  List<Map<String, dynamic>> OEMFilesList = [];
  List<Map<String, dynamic>> NoPoolFilesList = [];

  Future<void> loadData() async {
    _selectedTabIndex = _TabBarcontroller!.index;
    print('loadData');

    // String canOpen = _showAllTickets ? " " : " and canOpen=1  and openSections like '%#1#%' ";
    String canOpen = _showAllTickets ? " " : " and canOpen=1    ";
    String searchQ = "";
    searchQ = "   mo like '%$searchText%'";

    // switch (_selectedTabIndex) {
    //   case 0:
    AllFilesList = await database.rawQuery(
        'SELECT * FROM tickets where $searchQ   ' +
            canOpen +
            '  order by ${listSortBy} DESC');
    // AllFilesList = await database.rawQuery('delete from tickets ');

    //   break;
    // case 1:
    UpwindFilesList = await database.rawQuery(
        'SELECT * FROM tickets where $searchQ   ' +
            canOpen +
            ' and production=\'Upwind\' order by ${listSortBy} DESC');
    //   break;
    // case 2:
    ODFilesList = await database.rawQuery(
        'SELECT * FROM tickets where $searchQ   ' +
            canOpen +
            ' and production=\'OD\' order by ${listSortBy} DESC');
    //   break;
    // case 3:
    NylonFilesList = await database.rawQuery(
        'SELECT * FROM tickets where $searchQ   ' +
            canOpen +
            ' and production=\'Nylon\' order by ${listSortBy} DESC');
    //   break;
    // case 4:
    OEMFilesList = await database.rawQuery(
        'SELECT * FROM tickets where $searchQ   ' +
            canOpen +
            ' and production=\'OEM\' order by ${listSortBy} DESC');
    //   break;
    // case 5:
    NoPoolFilesList = await database.rawQuery(
        'SELECT * FROM tickets where $searchQ   ' +
            canOpen +
            ' and production is null order by ${listSortBy} DESC');
    // break;
    // }

    listsArray = [
      AllFilesList,
      UpwindFilesList,
      ODFilesList,
      NylonFilesList,
      OEMFilesList,
      NoPoolFilesList
    ];
    currentFileList = listsArray[_selectedTabIndex];
    print(currentFileList.length);
  }

  Future<void> showTicketOptions(Ticket ticket, BuildContext context1) async {
    print(ticket.toJson());
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Colors.white),
          height: 550,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(ticket.mo ?? ticket.oe!),
                  subtitle: Text(ticket.oe!),
                ),
                Divider(),
                ListTile(
                  title: Text(
                      ticket.isRed == 1 ? "Remove Red Flag" : "Set Red Flag"),
                  leading: Icon(Icons.flag),
                  onTap: () async {
                    Navigator.of(context).pop();
                    bool resul =
                        await FlagDialog.showRedFlagDialog(context1, ticket);
                    ticket.isRed = resul ? 1 : 0;
                  },
                ),
                ListTile(
                    onTap: () async {
                      Navigator.of(context).pop();
                      await FlagDialog.showGRDialog(context1, ticket);
                    },
                    title: Text(ticket.isGr == 1 ? "Remove GR" : "Set GR"),
                    leading: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Center(
                                child: Text("GR",
                                    style: TextStyle(color: Colors.white)))))),
                ListTile(
                    onTap: () async {
                      Navigator.of(context).pop();
                      await FlagDialog.showSKDialog(context1, ticket);
                    },
                    title: Text(ticket.isSk == 1 ? "Remove SK" : "Set SK"),
                    leading: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircleAvatar(
                            backgroundColor: Colors.pink,
                            child: Center(
                                child: Text("SK",
                                    style: TextStyle(color: Colors.white)))))),
                ListTile(
                    title:
                        Text(ticket.isRush == 1 ? "Remove Rush" : "Set Rush"),
                    leading: Icon(Icons.offline_bolt_outlined,
                        color: Colors.orangeAccent),
                    onTap: () async {
                      Navigator.of(context).pop();
                      // await FlagDialog.showRushDialog(context1, ticket);
                      var u = ticket.isRush == 1 ? "removeFlag" : "setFlag";
                      OnlineDB.apiPost("tickets/flags/" + u, {
                        "ticket": ticket.id.toString(),
                        "comment": "",
                        "type": "rush"
                      }).then((http.Response response) async {
                        Map res = (json.decode(response.body) as Map);
                      });
                    }),
                ListTile(
                    title: Text(ticket.inPrint == 1
                        ? "Done Printing"
                        : "Send To Print"),
                    leading: Icon(
                        ticket.inPrint == 1
                            ? Icons.print_disabled_outlined
                            : Icons.print_outlined,
                        color: Colors.deepOrangeAccent),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await sendToPrint(ticket);
                    }),
                ListTile(
                    title: Text("Finish"),
                    leading: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.green),
                    onTap: () async {
                      await Navigator.push(
                          context1,
                          MaterialPageRoute(
                              builder: (context) => FinishCheckList(ticket)));
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    title: Text("Delete"),
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    onTap: () async {
                      Navigator.of(context).pop();
                    }),
                Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  void reloadData() {
    DB.getDB().then((value) async {
      database = value;
      await loadData();
      try {
        this.setState(() {});
      } catch (e) {}
    });
  }

  Future sendToPrint(Ticket ticket) async {
    if (ticket.inPrint == 0) {
      await OnlineDB.apiPost(
          "tickets/print/sendToPrint", {"ticket": ticket.id.toString()});
      ticket.inPrint = 1;
      return 1;
    } else {
      await OnlineDB.apiPost(
          "tickets/print/removePrint", {"ticket": ticket.id.toString()});
      ticket.inPrint = 0;
      return 0;
    }
  }
}
