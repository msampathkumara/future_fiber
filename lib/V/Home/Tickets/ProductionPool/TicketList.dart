import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/C/App.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/Tickets/ProductionPool/Finish/FinishCheckList.dart';
import 'package:smartwind/V/Widgets/FlagDialog.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';

import '../TicketInfo/TicketInfo.dart';
import 'CrossProduction.dart';

class TicketList extends StatefulWidget {
  TicketList();

  @override
  _TicketListState createState() {
    return _TicketListState();
  }
}

class _TicketListState extends State<TicketList> with TickerProviderStateMixin {
  var database;
  late int _selectedTabIndex;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: " + _tabBarController!.index.toString());
      });
      reloadData();
      DB.setOnDBChangeListener(() {
        reloadData();
      }, context, collection: DataTables.Tickets);
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

                if (_showAllTickets) {
                  tabs = ["All", "Upwind", "OD", "Nylon", "OEM", "No Pool"];
                } else {
                  tabs = ["All", "Cross Production"];
                }

                _tabBarController = TabController(length: tabs.length, vsync: this);
                loadData().then((value) => setState(() {}));
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
          toolbarHeight: 82,
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
            delay: 300,
            onSearchTextChanged: (text) {
              if (subscription != null) {
                subscription.cancel();
              }
              searchText = text;

              loadData().then((value) {
                setState(() {});
              });
            },
            onSubmitted: (text) {},
            OnBarcode: (barcode) {
              print("xxxxxxxxxxxxxxxxxx $barcode");
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
                      "${currentFileList.length}",
                      textScaleFactor: 1.1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Sorted by $sortedBy",
                    style: TextStyle(color: Colors.white),
                  ),
                  InkWell(
                    onTap: () {},
                    splashColor: Colors.red,
                    child: Ink(
                      child: IconButton(
                        icon: Icon(Icons.sort_by_alpha_rounded),
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
  String sortedBy = "Date";
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
        leading: icon is IconData ? Icon(icon) : icon,
        onTap: () {
          listSortBy = key;
          sortedBy = title;
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
                          getListItem("Date", Icons.date_range_rounded, "uptime"),
                          getListItem("Name", Icons.sort_by_alpha_rounded, "mo"),
                          getListItem("Red Flag", Icons.tour_rounded, "isred"),
                          getListItem("Hold", Icons.pan_tool_rounded, "ishold"),
                          getListItem("Rush", Icons.flash_on_rounded, "isrush"),
                          getListItem("SK",
                              CircleAvatar(radius: 12, backgroundColor: Colors.grey, child: Center(child: Text("SK", style: TextStyle(color: Colors.white, fontSize: 8)))), "issk"),
                          getListItem("GR",
                              CircleAvatar(radius: 12, backgroundColor: Colors.grey, child: Center(child: Text("GR", style: TextStyle(color: Colors.white, fontSize: 8)))), "isgr"),
                          getListItem("Short", Icons.local_mall_rounded, "sort"),
                          getListItem("Error Route", Icons.warning_rounded, "errOut"),
                          getListItem("Print", Icons.print_rounded, "inprint"),
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }

  // final tabs = ["All", "Upwind", "OD", "Nylon", "OEM", "No Pool"];
  var tabs = ["All", "Cross Production"];
  TabController? _tabBarController;

  getBody() {
    var l = tabs.length;
    print('tab length = $l');
    return _tabBarController == null
        ? Container()
        : DefaultTabController(
            length: tabs.length,
            child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  toolbarHeight: 10,
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
                body: _showAllTickets
                    ? TabBarView(controller: _tabBarController, children: [
                        getTicketListByCategoty(AllFilesList),
                        getTicketListByCategoty(UpwindFilesList),
                        getTicketListByCategoty(ODFilesList),
                        getTicketListByCategoty(NylonFilesList),
                        getTicketListByCategoty(OEMFilesList),
                        getTicketListByCategoty(NoPoolFilesList),
                      ])
                    : TabBarView(controller: _tabBarController, children: [
                        getTicketListByCategoty(AllFilesList),
                        // getTicketListByCategoty(FinishedFilesList),
                        getTicketListByCategoty(CrossProductionFilesList),

                        // getTicketListByCategoty(NylonFilesList),
                        // getTicketListByCategoty(OEMFilesList),
                        // getTicketListByCategoty(NoPoolFilesList),
                      ])),
          );
  }

  final int CAT_ALL = 0;
  final int CAT_UPWIND = 1;
  final int CAT_OD = 2;
  final int CAT_NYLON = 3;
  final int CAT_OEM = 4;

  // var indicator = new GlobalKey<RefreshIndicatorState>();

  getTicketListByCategoty(List<Map<String, dynamic>> FilesList) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              return DB.updateDatabase(context).then((value) {
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
                  return TicketTile(index, ticket, () async {
                    print('Long pres');
                    await showTicketOptions(ticket, context);
                    setState(() {});
                  }, () {
                    var ticketInfo = TicketInfo(ticket);
                    ticketInfo.show(context);
                  }, () {});
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

  // List<Map<String, dynamic>> FinishedFilesList = [];
  List<Map<String, dynamic>> CrossProductionFilesList = [];

  List<Map<String, dynamic>> UpwindFilesList = [];
  List<Map<String, dynamic>> ODFilesList = [];
  List<Map<String, dynamic>> NylonFilesList = [];
  List<Map<String, dynamic>> OEMFilesList = [];
  List<Map<String, dynamic>> NoPoolFilesList = [];

  Future<void> loadData() async {
    _selectedTabIndex = _tabBarController!.index;
    print('loadData listSortBy $listSortBy');

    // String canOpen = _showAllTickets ? " " : " and canOpen=1  and openSections like '%#1#%' ";

    NsUser? nsUser = await App.getCurrentUser();
    var section = nsUser!.section!.id;
    String canOpen = _showAllTickets ? "  file=1 and completed=0" : " canOpen=1   and file=1   and completed=0 ";
    String searchQ = "";
    if (searchText.isNotEmpty) {
      searchQ = "  ( mo like '%$searchText%' or oe like '%$searchText%') and ";
    }

    print('current user $section');

    AllFilesList =
        await database.rawQuery("SELECT * FROM tickets where  $searchQ   " + canOpen + " and openSections like '%|" + section.toString() + "|%'  order by $listSortBy DESC");

    // FinishedFilesList = await database.rawQuery('SELECT * FROM tickets where  $searchQ   ' + canOpen + "   and openSections like '%|$section|f%' order by $listSortBy DESC");

    CrossProductionFilesList =
        await database.rawQuery('SELECT * FROM tickets where  $searchQ   ' + canOpen + " and openSections like '%|$section|%' and crossPro=1 order by $listSortBy DESC");

    if (_showAllTickets) {
      AllFilesList = await database.rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + '   order by $listSortBy DESC');

      UpwindFilesList = await database.rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'Upwind\' order by $listSortBy DESC');

      ODFilesList = await database.rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'OD\' order by $listSortBy DESC');

      NylonFilesList = await database.rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'Nylon\' order by $listSortBy DESC');

      OEMFilesList = await database.rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'OEM\' order by $listSortBy DESC');

      NoPoolFilesList = await database.rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production is null or production=""  order by $listSortBy DESC');
    }

    listsArray = [AllFilesList, UpwindFilesList, ODFilesList, NylonFilesList, OEMFilesList, NoPoolFilesList];
    currentFileList = listsArray[_selectedTabIndex];
    print(currentFileList.length);
  }

  Future<void> showTicketOptions(Ticket ticket, BuildContext context1) async {
    print(ticket.toJson());
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          height: 650,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(
                title: Text(ticket.mo ?? ticket.oe!),
                subtitle: Text(ticket.oe!),
              ),
              Divider(),
              Expanded(
                  child: Container(
                child: SingleChildScrollView(
                    child: Column(children: [
                  ListTile(
                    title: Text(ticket.isRed == 1 ? "Remove Red Flag" : "Set Red Flag"),
                    leading: Icon(Icons.flag),
                    onTap: () async {
                      Navigator.of(context).pop();
                      bool resul = await FlagDialog.showRedFlagDialog(context1, ticket);
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
                          width: 24, height: 24, child: CircleAvatar(backgroundColor: Colors.blue, child: Center(child: Text("GR", style: TextStyle(color: Colors.white)))))),
                  ListTile(
                      onTap: () async {
                        Navigator.of(context).pop();
                        await FlagDialog.showSKDialog(context1, ticket);
                      },
                      title: Text(ticket.isSk == 1 ? "Remove SK" : "Set SK"),
                      leading: SizedBox(
                          width: 24, height: 24, child: CircleAvatar(backgroundColor: Colors.pink, child: Center(child: Text("SK", style: TextStyle(color: Colors.white)))))),
                  ListTile(
                      title: Text(ticket.isRush == 1 ? "Remove Rush" : "Set Rush"),
                      leading: Icon(Icons.offline_bolt_outlined, color: Colors.orangeAccent),
                      onTap: () async {
                        Navigator.of(context).pop();
                        // await FlagDialog.showRushDialog(context1, ticket);
                        var u = ticket.isRush == 1 ? "removeFlag" : "setFlag";
                        OnlineDB.apiPost("tickets/flags/" + u, {"ticket": ticket.id.toString(), "comment": "", "type": "rush"}).then((response) async {});
                      }),
                  ListTile(
                      title: Text(ticket.inPrint == 1 ? "Cancel Printing" : "Send To Print"),
                      leading: Icon(ticket.inPrint == 1 ? Icons.print_disabled_outlined : Icons.print_outlined, color: Colors.deepOrangeAccent),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await sendToPrint(ticket);
                      }),
                  ListTile(
                      title: Text("Finish"),
                      leading: Icon(Icons.check_circle_outline_outlined, color: Colors.green),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return FinishCheckList(ticket);
                            });
                        // await Navigator.push(context1, MaterialPageRoute(builder: (context) => FinishCheckList(ticket)));
                      }),
                  ListTile(
                      title: Text("Cross Production"),
                      leading: Icon(Icons.merge_type_outlined, color: Colors.green),
                      onTap: () async {
                        await Navigator.push(context1, MaterialPageRoute(builder: (context) => CrossProduction(ticket)));
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                      title: Text("Send Ticket"),
                      leading: Icon(Icons.send_rounded, color: Colors.lightBlue),
                      onTap: () async {
                        await ticket.sharePdf(context);
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                      title: Text("Add CPR"),
                      leading: Icon(Icons.local_mall_rounded, color: Colors.amber),
                      onTap: () async {
                        await ticket.addCPR(context);
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                      title: Text("Shipping"),
                      leading: Icon(Icons.directions_boat_rounded, color: Colors.brown),
                      onTap: () async {
                        await ticket.addCPR(context);
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                      title: Text("CS"),
                      leading: Icon(Icons.pivot_table_chart_rounded, color: Colors.green),
                      onTap: () async {
                        await ticket.addCPR(context);
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                      title: Text("Delete"),
                      leading: Icon(Icons.delete_forever, color: Colors.red),
                      onTap: () async {
                        Navigator.of(context).pop();
                      }),
                ])),
              ))
            ],
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
      OnlineDB.apiPost("tickets/print", {"ticket": ticket.id.toString(), "action": "sent"}).then((value) {
        print('Send to print  ${value.data}');
        ticket.inPrint = 1;
        setState(() {});
      }).onError((error, stackTrace) {
        print(error);
      });

      return 1;
    } else {
      await OnlineDB.apiPost("tickets/print", {"ticket": ticket.id.toString(), "action": "cancel"});
      ticket.inPrint = 0;
      return 0;
    }
  }
}

class TicketTile extends StatelessWidget {
  final Ticket ticket;
  final int index;
  final onLongPress;
  final onTap;
  final onDoubleTap;

  const TicketTile(this.index, this.ticket, this.onLongPress, this.onTap, this.onDoubleTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () async {
        // await showTicketOptions(ticket, context);
        // setState(() {});
        onLongPress();
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
            color: ticket.isHold == 1 ? Colors.black12 : Colors.white,
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: ListTile(
          leading: Text("${index + 1}"),
          title: Text(
            (ticket.mo ?? "").trim().isEmpty ? (ticket.oe ?? "") : ticket.mo ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Wrap(
            direction: Axis.vertical,
            children: [
              if ((ticket.mo ?? "").trim().isNotEmpty) Text((ticket.oe ?? "")),
              if (ticket.crossPro == 1)
                Chip(
                    avatar: CircleAvatar(
                      child: Icon(
                        Icons.merge_type_outlined,
                      ),
                    ),
                    label: Text(ticket.crossProList)),
              Text(ticket.getUpdateDateTime()),
            ],
          ),
          // subtitle: Text(ticket.fileVersion.toString()),
          trailing: Wrap(
            children: [
              if (ticket.inPrint == 1)
                IconButton(
                  icon: CircleAvatar(child: Icon(Icons.print_rounded, color: Colors.deepOrangeAccent), backgroundColor: Colors.white),
                  onPressed: () {},
                ),
              if (ticket.isHold == 1)
                IconButton(
                  icon: CircleAvatar(child: Icon(Icons.pan_tool_rounded, color: Colors.black), backgroundColor: Colors.white),
                  onPressed: () {},
                ),
              if (ticket.isGr == 1)
                IconButton(
                  icon: CircleAvatar(backgroundColor: Colors.blue, child: Center(child: Text("GR", style: TextStyle(color: Colors.white)))),
                  onPressed: () {},
                ),
              if (ticket.isSk == 1)
                IconButton(
                  icon: CircleAvatar(backgroundColor: Colors.pink, child: Center(child: Text("SK", style: TextStyle(color: Colors.white)))),
                  onPressed: () {},
                ),
              if (ticket.isError == 1)
                IconButton(
                  icon: CircleAvatar(child: Icon(Icons.report_problem_rounded, color: Colors.red), backgroundColor: Colors.white),
                  onPressed: () {},
                ),
              if (ticket.isSort == 1)
                IconButton(
                  icon: CircleAvatar(child: Icon(Icons.local_mall_rounded, color: Colors.green), backgroundColor: Colors.white),
                  onPressed: () {},
                ),
              if (ticket.isRush == 1)
                IconButton(
                  icon: CircleAvatar(child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent), backgroundColor: Colors.white),
                  onPressed: () {},
                ),
              if (ticket.isRed == 1)
                IconButton(
                  icon: CircleAvatar(child: Icon(Icons.tour_rounded, color: Colors.red), backgroundColor: Colors.white),
                  onPressed: () {},
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 5.0,
                  percent: ticket.progress / 100,
                  center: new Text(
                    ticket.progress.toString() + "%",
                    style: TextStyle(fontSize: 12),
                  ),
                  progressColor: Colors.green,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
