import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/V/Home/Tickets/ProductionPool/Finish/FinishCheckList.dart';
import 'package:smartwind/V/Widgets/FlagDialog.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';
import 'package:smartwind/ns_icons_icons.dart';

import '../../../../M/AppUser.dart';
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

  String listSortBy = "shipDate";
  bool listSortDirectionIsDESC = false;
  String sortedBy = "Date";
  String searchText = "";
  var subscription;
  bool _showAllTickets = false;
  late DbChangeCallBack dbChangeCallBack;

  NsUser? nsUser;

  @override
  initState() {
    nsUser = AppUser.getUser();
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      updateTabControler();
      reloadData();
      dbChangeCallBack = DB.setOnDBChangeListener(() {
        print('callChangesCallBacks TicketList');
        reloadData();
      }, context, collection: DataTables.Tickets);
    });
  }

  late List listsArray;

  @override
  void dispose() {
    dbChangeCallBack.dispose();
    super.dispose();
  }

  TextEditingController searchController = new TextEditingController();
  bool _barcodeResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);

              openTicketByBarcode(barcode);
            },
            child: const Icon(Icons.qr_code_rounded),
            backgroundColor: Colors.green),
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
                  updateTabControler();
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
            title: Column(
              children: [
                Text(
                  "Production Pool",
                  textScaleFactor: 1.2,
                ),
                (nsUser != null && nsUser!.section != null) ? Text("${nsUser!.section!.sectionTitle} @ ${nsUser!.section!.factory}") : Text("")
              ],
            ),
            bottom: SearchBar(
                searchController: searchController,
                delay: 300,
                onSearchTextChanged: (text) {
                  if (subscription != null) {
                    subscription.cancel();
                  }
                  searchText = text;

                  loadData().then((value) {
                    setState(() {});
                    if (_barcodeResult) {
                      if (currentFileList.length > 0) {
                        Ticket ticket = (currentFileList[0]);
                        var ticketInfo = TicketInfo(ticket);
                        ticketInfo.show(context);
                      }
                    }
                    _barcodeResult = false;
                  });
                },
                onSubmitted: (text) {}),
            centerTitle: true),
        body: Container(
          color: themeColor,
          child: Column(
            children: [
              Wrap(children: [
                flagIcon(Filters.crossPro, Icons.merge_type_rounded),
                flagIcon(Filters.isError, Icons.warning_rounded),
                flagIcon(Filters.inPrint, Icons.print_rounded),
                flagIcon(Filters.isRush, Icons.offline_bolt_rounded),
                flagIcon(Filters.isRed, Icons.flag_rounded),
                flagIcon(Filters.isHold, NsIcons.stop),
                flagIcon(Filters.isSk, NsIcons.sk),
                flagIcon(Filters.isGr, NsIcons.gr),
                flagIcon(Filters.isSort, NsIcons.short)
              ]),
              Expanded(child: getBody()),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            color: Colors.green,
            child: IconTheme(
              data: IconThemeData(color: Colors.white),
              child: Row(
                children: [
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
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${currentFileList.length}",
                      textScaleFactor: 1.1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 36)
                  // Text(
                  //   "Sorted by $sortedBy",
                  //   style: TextStyle(color: Colors.white),
                  // ),
                ],
              ),
            )));
  }

  void _sortByBottomSheetMenu() {
    getListItem(String title, icon, key) {
      return ListTile(
        trailing: (listSortBy == key ? (listSortDirectionIsDESC ? Icon(Icons.arrow_upward_rounded) : Icon(Icons.arrow_downward_rounded)) : null),
        title: Text(title),
        selectedTileColor: Colors.black12,
        selected: listSortBy == key,
        leading: icon is IconData ? Icon(icon) : icon,
        onTap: () {
          if (listSortBy == key) {
            listSortDirectionIsDESC = !listSortDirectionIsDESC;
          } else {
            listSortDirectionIsDESC = true;
          }
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
                Padding(padding: const EdgeInsets.all(16.0), child: Text("Sort By", textScaleFactor: 1.2)),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ListView(
                        children: [
                          getListItem("Shipping Date", Icons.date_range_rounded, "shipDate"),
                          getListItem("Modification Date", Icons.date_range_rounded, "uptime"),
                          getListItem("Name", Icons.sort_by_alpha_rounded, "mo")
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
  var themeColor = Colors.green;

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
                backgroundColor: themeColor,
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
                      getTicketListByCategory(_allFilesList),
                      getTicketListByCategory(_upwindFilesList),
                      getTicketListByCategory(_oDFilesList),
                      getTicketListByCategory(_nylonFilesList),
                      getTicketListByCategory(_oEMFilesList),
                      getTicketListByCategory(_noPoolFilesList),
                    ])
                  : TabBarView(controller: _tabBarController, children: [
                      getTicketListByCategory(_allFilesList),
                      getTicketListByCategory(_crossProductionFilesList),
                    ]),
            ),
          );
  }

  getTicketListByCategory(List<Ticket> filesList) {
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
                child: filesList.length > 0
                    ? ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: filesList.length,
                        itemBuilder: (BuildContext context, int index) {
                          // print(FilesList[index]);
                          Ticket ticket = (filesList[index]);
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
                      )
                    : Center(child: Text(searchText.isEmpty ? "No Tickets Found" : "⛔ Work Ticket not found.\n Please contact  Ticket Checking department", textScaleFactor: 1.5))),
          ),
        ),
      ],
    );
  }

  List<Ticket> currentFileList = [];
  List<Ticket> _allFilesList = [];
  List<Ticket> _crossProductionFilesList = [];
  List<Ticket> _upwindFilesList = [];
  List<Ticket> _oDFilesList = [];
  List<Ticket> _nylonFilesList = [];
  List<Ticket> _oEMFilesList = [];
  List<Ticket> _noPoolFilesList = [];

  Future<void> loadData() async {
    String searchText = this.searchText.toLowerCase();
    _selectedTabIndex = _tabBarController!.index;
    print('loadData listSortBy $listSortBy');

    var section = AppUser.getSelectedSection()?.id;
    print('section ==== $section');
    if (true) {
      if (_showAllTickets) {
        //   TODO check canopen=1

      } else {
        _allFilesList = HiveBox.ticketBox.values.where((t) {
          return filters([section()]);

          if (t.file != 1 || t.completed != 0 || (!t.openSections.contains(section.toString()))) {
            return false;
          }

          if (dataFilter != Filters.none) {
            Map _t = t.toJson();
            if (_t[dataFilter.getValue()] != 1) {
              return false;
            }
          }

          if (searchText.isNotEmpty) {
            if ((t.mo ?? "").toLowerCase().contains(searchText) || (t.mo ?? "").toLowerCase().contains(searchText)) {
            } else {
              return false;
            }
          }
          return true;
        }).toList();
        listsArray = [_allFilesList, _crossProductionFilesList];
        currentFileList = listsArray[_selectedTabIndex];
      }

      return;
    }

    String canOpen = _showAllTickets ? "  file=1 and completed=0" : " canOpen=1   and file=1   and completed=0 ";
    String searchQ = "";
    String _dataFilter = "";

    if (dataFilter != Filters.none) {
      _dataFilter = "   " + dataFilter.getValue() + "=1 and ";
    }
    if (searchText.isNotEmpty) {
      searchQ = "  ( mo like '%$searchText%' or oe like '%$searchText%') and ";
    }

    print('current user $section');

    searchQ += _dataFilter;

    if (_showAllTickets) {
      _allFilesList = await database.rawQuery('SELECT * FROM tickets where $searchQ ' + canOpen + '   order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');

      _upwindFilesList = await database
          .rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'Upwind\' order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');

      _oDFilesList =
          await database.rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'OD\' order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');

      _nylonFilesList = await database
          .rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'Nylon\' order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');

      _oEMFilesList =
          await database.rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'OEM\' order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');

      _noPoolFilesList = await database.rawQuery(
          'SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production is null or production=""  order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');
      listsArray = [_allFilesList, _upwindFilesList, _oDFilesList, _nylonFilesList, _oEMFilesList, _noPoolFilesList];
    } else {
      _allFilesList = await database.rawQuery("SELECT * FROM tickets where  $searchQ   " +
          canOpen +
          " and openSections like '%\"" +
          section.toString() +
          "\"%'  order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}");
      _crossProductionFilesList = await database.rawQuery('SELECT * FROM tickets where  $searchQ   ' +
          canOpen +
          " and openSections like '%\"|$section|\"%' and crossPro=1 order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}");

      listsArray = [_allFilesList, _crossProductionFilesList];
    }
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
                  if (AppUser.havePermissionFor(Permissions.SET_RED_FLAG))
                    ListTile(
                      title: Text(ticket.isRed == 1 ? "Remove Red Flag" : "Set Red Flag"),
                      leading: Icon(Icons.flag),
                      onTap: () async {
                        Navigator.of(context).pop();
                        bool resul = await FlagDialog.showRedFlagDialog(context1, ticket);
                        ticket.isRed = resul ? 1 : 0;
                      },
                    ),
                  if (AppUser.havePermissionFor(Permissions.STOP_PRODUCTION))
                    ListTile(
                      title: Text(ticket.isHold == 1 ? "Restart Production" : "Stop Production"),
                      leading: Icon(Icons.pan_tool_rounded, color: Colors.red),
                      onTap: () async {
                        Navigator.of(context).pop();
                        bool resul = await FlagDialog.showStopProductionFlagDialog(context1, ticket);
                        ticket.isHold = resul ? 1 : 0;
                      },
                    ),
                  if (AppUser.havePermissionFor(Permissions.SET_GR))
                    ListTile(
                      onTap: () async {
                        Navigator.of(context).pop();
                        await FlagDialog.showGRDialog(context1, ticket);
                      },
                      title: Text(ticket.isGr == 1 ? "Remove GR" : "Set GR"),
                      // leading: SizedBox(
                      //     width: 24, height: 24, child: CircleAvatar(backgroundColor: Colors.blue, child: Center(child: Text("GR", style: TextStyle(color: Colors.white)))))
                      leading: Icon(NsIcons.gr, color: Colors.blue),
                    ),
                  // ListTile(
                  //     onTap: () async {
                  //       Navigator.of(context).pop();
                  //       await FlagDialog.showSKDialog(context1, ticket);
                  //     },
                  //     title: Text(ticket.isSk == 1 ? "Remove SK" : "Set SK"),
                  //     leading: SizedBox(
                  //         width: 24, height: 24, child: CircleAvatar(backgroundColor: Colors.pink, child: Center(child: Text("SK", style: TextStyle(color: Colors.white)))))),
                  if (AppUser.havePermissionFor(Permissions.SET_RUSH))
                    ListTile(
                        title: Text(ticket.isRush == 1 ? "Remove Rush" : "Set Rush"),
                        leading: Icon(Icons.offline_bolt_outlined, color: Colors.orangeAccent),
                        onTap: () async {
                          Navigator.of(context).pop();
                          // await FlagDialog.showRushDialog(context1, ticket);
                          var u = ticket.isRush == 1 ? "removeFlag" : "setFlag";
                          OnlineDB.apiPost("tickets/flags/" + u, {"ticket": ticket.id.toString(), "comment": "", "type": "rush"}).then((response) async {});
                        }),
                  if (AppUser.havePermissionFor(Permissions.SEND_TO_PRINTING))
                    ListTile(
                        title: Text(ticket.inPrint == 1 ? "Cancel Printing" : "Send To Print"),
                        leading: Icon(ticket.inPrint == 1 ? Icons.print_disabled_outlined : Icons.print_outlined, color: Colors.deepOrangeAccent),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await sendToPrint(ticket);
                        }),
                  if (AppUser.havePermissionFor(Permissions.FINISH_TICKET))
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
                  if (ticket.crossPro == 0 && AppUser.havePermissionFor(Permissions.SET_CROSS_PRODUCTION))
                    ListTile(
                        title: Text("Set Cross Production"),
                        leading: Icon(NsIcons.crossProduction, color: Colors.green),
                        onTap: () async {
                          await Navigator.push(context1, MaterialPageRoute(builder: (context) => CrossProduction(ticket)));
                          Navigator.of(context).pop();
                        }),
                  if (ticket.crossPro == 1 && AppUser.havePermissionFor(Permissions.SET_CROSS_PRODUCTION))
                    ListTile(
                        title: Text("Remove Cross Production"),
                        leading: Icon(NsIcons.crossProduction, color: Colors.green),
                        onTap: () async {
                          Navigator.of(context).pop();
                          showAlertDialog(context, ticket);
                        }),
                  if (AppUser.havePermissionFor(Permissions.SHARE_TICKETS))
                    ListTile(
                        title: Text("Share Work Ticket"),
                        leading: Icon(NsIcons.share, color: Colors.lightBlue),
                        onTap: () async {
                          await ticket.sharePdf(context);
                          Navigator.of(context).pop();
                        }),
                  if (AppUser.havePermissionFor(Permissions.ADD_CPR))
                    ListTile(
                        title: Text("Add CPR"),
                        leading: Icon(NsIcons.cpr, color: Colors.amber),
                        onTap: () async {
                          await ticket.addCPR(context);
                          Navigator.of(context).pop();
                        }),
                  if (AppUser.havePermissionFor(Permissions.SHIPPING_SYSTEM))
                    ListTile(
                        title: Text("Shipping"),
                        leading: Icon(NsIcons.shipping, color: Colors.brown),
                        onTap: () async {
                          await ticket.openInShippingSystem(context);
                          Navigator.of(context).pop();
                        }),
                  if (AppUser.havePermissionFor(Permissions.CS))
                    ListTile(
                        title: Text("CS"),
                        leading: Icon(Icons.pivot_table_chart_rounded, color: Colors.green),
                        onTap: () async {
                          await ticket.openInCS(context);
                          Navigator.of(context).pop();
                        }),
                  if (AppUser.havePermissionFor(Permissions.DELETE_TICKETS))
                    ListTile(
                        title: Text("Delete"),
                        leading: Icon(NsIcons.delete, color: Colors.red),
                        onTap: () async {
                          //TODO set delete url
                          OnlineDB.apiPost("tickets/delete", {"id": ticket.id.toString()}).then((response) async {
                            print('TICKET DELETED');
                            print(response.data);
                            print(response.statusCode);
                          });
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

  tabListener() {
    print("Selected Index: " + _tabBarController!.index.toString());
    if (currentFileList == listsArray[_tabBarController!.index]) {
      return;
    }
    currentFileList = listsArray[_tabBarController!.index];
    setState(() {
      print('${currentFileList.length}');
    });
  }

  void updateTabControler() {
    _tabBarController!.addListener(tabListener);
  }

  Filters dataFilter = Filters.none;

  flagIcon(Filters filter, IconData icon) {
    return IconButton(
      icon: CircleAvatar(child: Icon(icon, color: dataFilter == filter ? Colors.red : Colors.black), backgroundColor: Colors.white),
      tooltip: 'Increase volume by 10',
      onPressed: () async {
        if (dataFilter == filter) {
          dataFilter = Filters.none;
        } else {
          dataFilter = filter;
        }
        await loadData();
        setState(() {
          print('xxxxxxxxxxxxx');
        });
      },
    );
  }

  Future<void> openTicketByBarcode(barcode) async {
    var _currentFileList = await database.rawQuery("SELECT * FROM tickets where mo like '%" + barcode + "%' or oe like '%" + barcode + "%' ");
    if (_currentFileList.length > 0) {
      Ticket ticket = Ticket.fromJson(_currentFileList[0]);
      var ticketInfo = TicketInfo(ticket);
      ticketInfo.show(context);
    }
  }

  showAlertDialog(BuildContext context, ticket) {
    showDialog(
      context: context,
      builder: (BuildContext context1) {
        return AlertDialog(
          title: Text("Remove Cross Production"),
          content: Text("Do you really want to remove cross production from this ticket ? "),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context1).pop();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context1).pop();
                OnlineDB.apiPost("tickets/crossProduction/removeCrossProduction", {'ticketId': ticket.id.toString()}).then((response) async {
                  print(response.data);
                });
              },
            ),
          ],
        );
      },
    );
  }

  bool filters(List<Function> list) {
    bool status = true;
    for (var f in list) {
      if (!f()) {
        status = false;
        break;
      }
    }
    return status;
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
          leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("${index + 1}", style: TextStyle(fontWeight: FontWeight.bold))]),
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
              if (ticket.crossPro == 1) Chip(avatar: CircleAvatar(child: Icon(Icons.merge_type_outlined)), label: Text(ticket.crossProList)),
              // Text(ticket.getUpdateDateTime())
              if (ticket.shipDate.isNotEmpty)
                Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(Icons.directions_boat_outlined, size: 12, color: Colors.grey),
                    ),
                    Text(ticket.shipDate)
                    // Icon(Icons.delivery_dining_rounded),    Text(ticket.deliveryDate),
                  ],
                ),
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
                  icon: CircleAvatar(child: Icon(NsIcons.stop, color: Colors.black), backgroundColor: Colors.white),
                  onPressed: () {
                    FlagDialog.showFlagView(context, ticket, TicketFlagTypes.HOLD);
                  },
                ),
              if (ticket.isGr == 1)
                IconButton(
                  icon: CircleAvatar(child: Icon(NsIcons.gr, color: Colors.blue), backgroundColor: Colors.white),
                  onPressed: () {
                    FlagDialog.showFlagView(context, ticket, TicketFlagTypes.GR);
                  },
                ),
              if (ticket.isSk == 1)
                IconButton(
                  icon: CircleAvatar(child: Icon(NsIcons.sk, color: Colors.pink), backgroundColor: Colors.white),
                  onPressed: () {},
                ),
              if (ticket.isError == 1)
                IconButton(icon: CircleAvatar(child: Icon(Icons.report_problem_rounded, color: Colors.red), backgroundColor: Colors.white), onPressed: () {}),
              if (ticket.isSort == 1) IconButton(icon: CircleAvatar(child: Icon(Icons.local_mall_rounded, color: Colors.green), backgroundColor: Colors.white), onPressed: () {}),
              if (ticket.isRush == 1)
                IconButton(
                    icon: CircleAvatar(child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent), backgroundColor: Colors.white),
                    onPressed: () {
                      FlagDialog.showFlagView(context, ticket, TicketFlagTypes.RUSH);
                    }),
              if (ticket.isRed == 1)
                IconButton(
                  icon: CircleAvatar(child: Icon(Icons.tour_rounded, color: Colors.red), backgroundColor: Colors.white),
                  onPressed: () {
                    FlagDialog.showFlagView(context, ticket, TicketFlagTypes.RED);
                  },
                ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: CircularPercentIndicator(
                  radius: 20.0,
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
