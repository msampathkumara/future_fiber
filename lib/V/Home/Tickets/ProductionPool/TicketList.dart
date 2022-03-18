import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/V/Home/Tickets/ProductionPool/Finish/FinishCheckList.dart';
import 'package:smartwind/V/Widgets/FlagDialog.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';
import 'package:smartwind/ns_icons_icons.dart';

import '../../../../C/DB/DB.dart';
import '../../../../M/AppUser.dart';
import '../TicketInfo/TicketInfo.dart';
import 'CrossProduction.dart';

part 'TicketListOptions.dart';

class TicketList extends StatefulWidget {
  TicketList();

  @override
  _TicketListState createState() {
    return _TicketListState();
  }
}

class _TicketListState extends State<TicketList> with TickerProviderStateMixin {
  var database;
  late int _selectedTabIndex = 0;

  String searchText = "";
  var subscription;
  bool _showAllTickets = false;

  NsUser? nsUser;

  var _refreshIndicatorKey;

  late DbChangeCallBack _dbChangeCallBack;

  @override
  initState() {
    nsUser = AppUser.getUser();
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      updateTabControler();
      loadData();
    });

    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update tickets');
      if (mounted) {
        loadData();
      }
    }, context, collection: DataTables.Users);
  }

  late List listsArray;

  @override
  void dispose() {
    _dbChangeCallBack.dispose();
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
                  loadData();
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
            toolbarHeight: 100,
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: SizedBox(
                height: 50,
                child: Column(children: [
                  Text(
                    "Production Pool",
                    textScaleFactor: 1.2,
                  ),
                  (nsUser != null && nsUser!.section != null) ? Text("${nsUser!.section!.sectionTitle} @ ${nsUser!.section!.factory}" ) : Text("")
                ])),
            bottom: SearchBar(
                searchController: searchController,
                delay: 300,
                onSearchTextChanged: (text) {
                  if (subscription != null) {
                    subscription.cancel();
                  }
                  searchText = text;

                  loadData();
                  if (_barcodeResult) {
                    if (currentFileList.length > 0) {
                      Ticket ticket = (currentFileList[0]);
                      var ticketInfo = TicketInfo(ticket);
                      ticketInfo.show(context);
                    }
                  }
                  _barcodeResult = false;
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
                          _sortByBottomSheetMenu(context, loadData);
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

              // body: _showAllTickets
              //     ? TabBarView(controller: _tabBarController, children: [
              //         getTicketListByCategory(_allFilesList),
              //         getTicketListByCategory(_upwindFilesList),
              //         getTicketListByCategory(_oDFilesList),
              //         getTicketListByCategory(_nylonFilesList),
              //         getTicketListByCategory(_oEMFilesList),
              //         getTicketListByCategory(_noPoolFilesList),
              //       ])
              //     : TabBarView(controller: _tabBarController, children: [
              //         getTicketListByCategory(_allFilesList),
              //         getTicketListByCategory(_crossProductionFilesList),
              //       ]),
            ),
          );
  }

  getTicketListByCategory(List<Ticket> filesList) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              return HiveBox.getDataFromServer(clean: true).then((value) {
                loadData();
              });
            },
            child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: filesList.length > 0
                    ? ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: filesList.length,
                        itemBuilder: (BuildContext context1, int index) {
                          // print(FilesList[index]);
                          Ticket ticket = (filesList[index]);
                          // print(ticket.toJson());
                          return TicketTile(index, ticket, () async {
                            print('Long pres');
                            await showTicketOptions(ticket, context1, context);
                            setState(() {});
                          }, () {
                            var ticketInfo = TicketInfo(ticket);
                            ticketInfo.show(context1);
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

  bool _loading = true;

  setLoading(l) {
    setState(() {
      _loading = l;
    });
  }

  List<Ticket> _load(selectedProduction, section, _showAllTickets, searchText, {crossProduction = false}) {
    List<Ticket> l = HiveBox.ticketBox.values.where((t) {
      if (t.file != 1 || t.completed != 0) {
        return false;
      }
      if (crossProduction && t.crossPro != 1) {
        return false;
      }
      if (_showAllTickets ? (!searchByProduction(t, selectedProduction)) : (!searchBySection(t, section))) {
        return false;
      }

      if (!searchByFilters(t)) {
        return false;
      }

      if (!searchByText(t)) {
        return false;
      }

      return true;
    }).toList();
    l.sort((a, b) => (a.toJson()[listSortBy] ?? "").compareTo((b.toJson()[listSortBy] ?? "")));
    if (listSortDirectionIsDESC) {
      l = l.reversed.toList();
    }
    return l;
  }

  List<Ticket> currentFileList = [];
  List<Ticket> _allFilesList = [];
  List<Ticket> _crossProductionFilesList = [];
  List<Ticket> _upwindFilesList = [];
  List<Ticket> _oDFilesList = [];
  List<Ticket> _nylonFilesList = [];
  List<Ticket> _oEMFilesList = [];
  List<Ticket> _noPoolFilesList = [];

  loadData() {
    print('---------------------------------------------- Start loading');
    _selectedTabIndex = _tabBarController!.index;
    setLoading(true);
    String searchText = this.searchText.toLowerCase();

    if (_showAllTickets) {
      _allFilesList = _load(Production.All, 0, true, searchText);
      _upwindFilesList = _load(Production.Upwind, 0, true, searchText);
      _oDFilesList = _load(Production.OD, 0, true, searchText);
      _nylonFilesList = _load(Production.Nylon, 0, true, searchText);
      _oEMFilesList = _load(Production.OEM, 0, true, searchText);
      _noPoolFilesList = _load(Production.None, 0, true, searchText);
      listsArray = [_allFilesList, _upwindFilesList, _oDFilesList, _nylonFilesList, _oEMFilesList, _noPoolFilesList];
    } else {
      _allFilesList = _load(Production.All, 0, false, searchText);
      _crossProductionFilesList = _load(Production.Upwind, 0, false, searchText, crossProduction: true);
      listsArray = [_allFilesList, _crossProductionFilesList];
    }
    currentFileList = listsArray[_selectedTabIndex];
    print('---------------------------------------------- end loading');
    // _selectedTabIndex = _tabBarController!.index;
    // print('loadData listSortBy $listSortBy');
    //
    // var section = AppUser.getSelectedSection()?.id;
    // print('section ==== $section');
    //
    // Production selectedProduction =
    //     (_showAllTickets ? [Production.All, Production.Upwind, Production.OD, Production.Nylon, Production.OEM, Production.None] : []).elementAt(_selectedTabIndex);
    //
    // print('Production ==== $selectedProduction');
    // if (true) {
    //   currentFileList = HiveBox.ticketBox.values.where((t) {
    //     if (t.file != 1 || t.completed != 0) {
    //       return false;
    //     }
    //     if (_showAllTickets ? (!searchByProduction(t, selectedProduction)) : searchBySection(t, section)) {
    //       return false;
    //     }
    //
    //     if (!searchByFilters(t)) {
    //       return false;
    //     }
    //
    //     if (!searchByText(t)) {
    //       return false;
    //     }
    //
    //     return true;
    //   }).toList();
    //   setLoading(false);
    // }

    // String canOpen = _showAllTickets ? "  file=1 and completed=0" : " canOpen=1   and file=1   and completed=0 ";
    // String searchQ = "";
    // String _dataFilter = "";
    //
    // if (dataFilter != Filters.none) {
    //   _dataFilter = "   " + dataFilter.getValue() + "=1 and ";
    // }
    // if (searchText.isNotEmpty) {
    //   searchQ = "  ( mo like '%$searchText%' or oe like '%$searchText%') and ";
    // }
    //
    // print('current user $section');
    //
    // searchQ += _dataFilter;
    //
    // if (_showAllTickets) {
    //   _allFilesList = await database.rawQuery('SELECT * FROM tickets where $searchQ ' + canOpen + '   order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');
    //
    //   _upwindFilesList = await database
    //       .rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'Upwind\' order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');
    //
    //   _oDFilesList =
    //       await database.rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'OD\' order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');
    //
    //   _nylonFilesList = await database
    //       .rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'Nylon\' order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');
    //
    //   _oEMFilesList =
    //       await database.rawQuery('SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production=\'OEM\' order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');
    //
    //   _noPoolFilesList = await database.rawQuery(
    //       'SELECT * FROM tickets where $searchQ   ' + canOpen + ' and production is null or production=""  order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}');
    //   listsArray = [_allFilesList, _upwindFilesList, _oDFilesList, _nylonFilesList, _oEMFilesList, _noPoolFilesList];
    // } else {
    //   _allFilesList = await database.rawQuery("SELECT * FROM tickets where  $searchQ   " +
    //       canOpen +
    //       " and openSections like '%\"" +
    //       section.toString() +
    //       "\"%'  order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}");
    //   _crossProductionFilesList = await database.rawQuery('SELECT * FROM tickets where  $searchQ   ' +
    //       canOpen +
    //       " and openSections like '%\"|$section|\"%' and crossPro=1 order by $listSortBy ${listSortDirectionIsDESC ? "DESC" : "ASC"}");
    //
    //   listsArray = [_allFilesList, _crossProductionFilesList];
    // }
    // currentFileList = listsArray[_selectedTabIndex];
    // print(currentFileList.length);
  }

  // void reloadData() {
  //   loadData();
  //   // DB.getDB().then((value) async {
  //   //   database = value;
  //   //   await loadData();
  //   //   try {
  //   //     this.setState(() {});
  //   //   } catch (e) {}
  //   // });
  // }

  tabListener() {
    print("Selected Index: " + _tabBarController!.index.toString());

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
    try {
      Ticket ticket = HiveBox.ticketBox.values.singleWhere((t) => [(t.mo ?? "").toLowerCase(), (t.oe ?? "").toLowerCase()].contains(barcode.toString().toLowerCase()));
      var ticketInfo = TicketInfo(ticket);
      ticketInfo.show(context);
    } catch (e) {
      print('Ticket not found');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ticket not found", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }

    // var _currentFileList = await database.rawQuery("SELECT * FROM tickets where mo like '%" + barcode + "%' or oe like '%" + barcode + "%' ");
    // if (_currentFileList.length > 0) {
    //   Ticket ticket = Ticket.fromJson(_currentFileList[0]);
    //   var ticketInfo = TicketInfo(ticket);
    //   ticketInfo.show(context);
    // }
  }

  bool searchByText(t) {
    if (searchText.isNotEmpty) {
      if ((t.mo ?? "").toLowerCase().contains(searchText) || (t.mo ?? "").toLowerCase().contains(searchText)) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  bool searchByFilters(t) {
    if (dataFilter != Filters.none) {
      Map _t = t.toJson();
      if (_t[dataFilter.getValue()] != 1) {
        return false;
      }
    }
    return true;
  }

  bool searchBySection(t, section) {
    return (!t.openSections.contains(section.toString()));
  }

  searchByProduction(Ticket t, Production selectedProduction) {
    if (selectedProduction == Production.All) {
      return true;
    }
    if (selectedProduction == Production.None && ((t.production ?? '').trim().isEmpty)) {
      return true;
    }
    return (t.production ?? '').toLowerCase() == selectedProduction.getValue().toLowerCase();
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
