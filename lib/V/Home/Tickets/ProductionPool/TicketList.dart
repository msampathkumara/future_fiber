import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/V/Widgets/FlagDialog.dart';
import 'package:smartwind/V/Widgets/NoResultFoundMsg.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';
import 'package:smartwind/ns_icons_icons.dart';

import '../../../../C/DB/DB.dart';
import '../../../../M/AppUser.dart';
import '../../../../Web/V/QC/webTicketQView.dart';
import '../../../../globals.dart';
import '../TicketInfo/TicketChatView.dart';
import '../TicketInfo/TicketInfo.dart';
import 'TicketListOptions.dart';

class TicketList extends StatefulWidget {
  const TicketList({Key? key}) : super(key: key);

  @override
  _TicketListState createState() {
    return _TicketListState();
  }
}

class _TicketListState extends State<TicketList> with TickerProviderStateMixin {
  String searchText = "";
  var subscription;
  bool _showAllTickets = false;

  NsUser? nsUser;

  var _refreshIndicatorKey;

  late DbChangeCallBack _dbChangeCallBack;

  var startedCount = 0;

  @override
  initState() {
    nsUser = AppUser.getUser();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      updateTabControler();
      loadData();
    });

    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update tickets');
      if (mounted) {
        loadData();
      }
    }, context, collection: DataTables.Tickets);
  }

  // late List listsArray;

  @override
  void dispose() {
    _dbChangeCallBack.dispose();
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
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
            backgroundColor: Colors.green,
            child: const Icon(Icons.qr_code_rounded)),
        appBar: AppBar(
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (s) {
                  print(s);
                  _showAllTickets = !_showAllTickets;

                  if (_showAllTickets) {
                    tabs = Production.values.map<String>((e) => e.getValue()).toList();
                  } else {
                    tabs = ["All"];
                  }

                  _tabBarController = TabController(length: tabs.length, vsync: this);
                  updateTabControler();
                  loadData();
                },
                itemBuilder: (BuildContext context) {
                  return {"Show All Tickets"}.map((String choice) {
                    return CheckedPopupMenuItem<String>(
                      value: choice,
                      checked: _showAllTickets,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
            elevation: 0.0,
            toolbarHeight: 100,
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: SizedBox(
                height: ((!_showAllTickets) && nsUser != null && nsUser!.section != null) ? 50 : 30,
                child: Column(children: [
                  const Text("Production Pool", textScaleFactor: 1.2),
                  if ((!_showAllTickets) && nsUser != null && nsUser!.section != null) Text("${nsUser!.section!.sectionTitle} @ ${nsUser!.section!.factory}")
                ])),
            bottom: SearchBar(
                searchController: searchController,
                delay: 500,
                onSearchTextChanged: (text) {
                  if (subscription != null) {
                    subscription.cancel();
                  }
                  searchText = text;

                  loadData();
                  if (_barcodeResult) {
                    if (currentFileList.isNotEmpty) {
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
                // flagIcon(Filters.isCrossPro, Icons.merge_type_rounded),
                flagIcon(Filters.isError, Icons.warning_rounded),
                // flagIcon(Filters.inPrint, Icons.print_rounded),
                flagIcon(Filters.isRush, Icons.offline_bolt_rounded),
                flagIcon(Filters.isRed, Icons.flag_rounded),
                flagIcon(Filters.isHold, NsIcons.stop),
                flagIcon(Filters.isSk, NsIcons.sk),
                flagIcon(Filters.isGr, NsIcons.gr),
                flagIcon(Filters.isSort, NsIcons.short),
                flagIcon(Filters.isQc, NsIcons.short, text: "QC"),
                flagIcon(Filters.isQa, NsIcons.short, text: "QA"),
              ]),
              Expanded(child: getBody()),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            color: Colors.green,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {},
                    splashColor: Colors.red,
                    child: Ink(
                      child: IconButton(
                        icon: const Icon(Icons.sort_by_alpha_rounded),
                        onPressed: () {
                          sortByBottomSheetMenu(context, loadData);
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "$startedCount/${currentFileList.length}",
                      textScaleFactor: 1.1,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36)
                ],
              ),
            )));
  }

  var tabs = ["All"];
  TabController? _tabBarController;
  var themeColor = Colors.green;

  getBody() {
    var l = tabs.length;
    print('tab length = $l');
    return _tabBarController == null
        ? Container()
        : _showAllTickets
            ? DefaultTabController(
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
                    body: TabBarView(controller: _tabBarController, children: listsMap.values.map<Widget>((e) => getTicketListByCategory(e)).toList())),
              )
            : Scaffold(appBar: AppBar(toolbarHeight: 10, automaticallyImplyLeading: false), body: getTicketListByCategory(listsMap[Production.All]));
  }

  getTicketListByCategory(List<Ticket> filesList) {
    return Column(children: [
      Expanded(
          child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () {
                return HiveBox.getDataFromServer().then((value) {
                  loadData();
                });
              },
              child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: filesList.isNotEmpty
                      ? ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: filesList.length,
                          itemBuilder: (BuildContext context1, int index) {
                            // print(FilesList[index]);
                            Ticket ticket = (filesList[index]);
                            // print(ticket.toJson());
                            return TicketTile(index, ticket, onLongPress: () async {
                              print('Long pres');
                              await showTicketOptions(ticket, context1, context, loadData: () {
                                loadData();
                              });

                              setState(() {});
                            }, onReload: () {
                              print('************************************************************************************************************');
                              loadData();
                            });
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(height: 1, endIndent: 0.5, color: Colors.black12);
                          },
                        )
                      : const Center(child: NoResultFoundMsg()))))
    ]);
  }

  List<Ticket> _load(selectedProduction, section, showAllTickets, searchText, {bySection = false}) {
    List<Ticket> l = HiveBox.ticketBox.values.where((t) {
      if (bySection && t.nowAt != nsUser?.section?.id) {
        return false;
      }

      if (t.completed != 0) {
        return false;
      }

      if (selectedProduction == Production.None && (t.production != null || (t.production ?? '').isNotEmpty)) {
        return false;
      }
      if (showAllTickets ? (!searchByProduction(t, selectedProduction)) : (!searchBySection(t, section))) {
        return false;
      }

      if (!searchByFilters(t, dataFilter)) {
        return false;
      }

      if (!searchByText(t)) {
        return false;
      }

      if (t.isStarted) {
        wipCountMap[selectedProduction]++;
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
  Map listsMap = {};
  Map wipCountMap = {};

  loadData() {
    listsMap = {};
    wipCountMap = {};
    print('---------------------------------------------- Start loading');

    String searchText = this.searchText.toLowerCase();

    if (_showAllTickets) {
      for (var element in Production.values) {
        wipCountMap[element] = 0;
        listsMap[element] = _load(element, 0, true, searchText);
      }
    } else {
      wipCountMap[Production.All] = 0;
      listsMap[Production.All] = _load(Production.All, 0, false, searchText, bySection: true);
    }
    tabListener();
    print('---------------------------------------------- end loading');
  }

  tabListener() {
    print("Selected Index: ${_tabBarController!.index}");

    currentFileList = listsMap.values.toList()[_tabBarController!.index];
    startedCount = wipCountMap.values.toList()[_tabBarController!.index];
    setState(() {
      print('${currentFileList.length}');
    });
  }

  void updateTabControler() {
    _tabBarController!.addListener(tabListener);
  }

  Filters dataFilter = Filters.none;

  flagIcon(Filters filter, IconData icon, {String? text}) {
    return IconButton(
      icon: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 16,
          child: (text != null)
              ? Text(text, style: TextStyle(color: dataFilter == filter ? Colors.red : Colors.black, fontWeight: FontWeight.bold))
              : Icon(icon, color: dataFilter == filter ? Colors.red : Colors.black, size: 20)),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket not found", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }
  }

  bool searchByText(Ticket t) {
    if (searchText.isNotEmpty) {
      if ((t.mo ?? "").toLowerCase().contains(searchText) || (t.oe ?? "").toLowerCase().contains(searchText)) {
        return true;
      } else {
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

  final onReload;

  const TicketTile(this.index, this.ticket, {required this.onLongPress, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () async {
          // await showTicketOptions(ticket, context);
          // setState(() {});
          onLongPress();
        },
        onTap: () async {
          var ticketInfo = TicketInfo(ticket);
          ticketInfo.show(context);
        },
        // onDoubleTap: () async {
        //   // ticket.open(context);
        // },
        child: Ink(
            decoration: BoxDecoration(
                color: ticket.isHold == 1 ? Colors.black12 : Colors.white,
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(4))),
            child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              minLeadingWidth: 1,
              minVerticalPadding: 0,
              leading: Container(
                  decoration: BoxDecoration(border: Border(left: BorderSide(width: 4, color: ticket.hasFile ? Colors.green : Colors.redAccent))),
                  width: 36,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Text("${index + 1}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))])),
              title: Text((ticket.mo ?? "").trim().isEmpty ? (ticket.oe ?? "") : ticket.mo ?? "",
                  textScaleFactor: 1, style: TextStyle(fontWeight: FontWeight.bold, color: ticket.hasFile ? Colors.green : Colors.grey)),
              subtitle: Wrap(direction: Axis.vertical, children: [
                if ((ticket.mo ?? "").trim().isNotEmpty) Text((ticket.oe ?? "")),
                const SizedBox(height: 4),
                Wrap(children: [
                  if (ticket.shipDate.isNotEmpty) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.directions_boat_outlined, size: 12, color: Colors.grey)),
                  if (ticket.shipDate.isNotEmpty) Text(ticket.shipDate),
                  if (ticket.shipDate.isNotEmpty) const SizedBox(width: 16),
                  if (ticket.deliveryDate.isNotEmpty) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.local_shipping_rounded, size: 12, color: Colors.grey)),
                  if (ticket.deliveryDate.isNotEmpty) Text(ticket.deliveryDate)
                ])
              ]),
              // subtitle: Text(ticket.fileVersion.toString()),
              trailing: Wrap(
                children: [
                  //********************************************************************************************************************************************

                  ticket.haveKit == 1
                      ? IconButton(
                          icon: const Icon(Icons.view_in_ar_rounded, color: Colors.red),
                          onPressed: () {
                            snackBarKey.currentState?.hideCurrentSnackBar();
                            snackBarKey.currentState?.showSnackBar(SnackBar(
                                content: Wrap(children: ticket.getKitReport().map((e) => Row(children: [Text("${e.status}"), const Spacer(), Text("${e.count}")])).toList()),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                width: 200));
                          })
                      : const IconButton(icon: Icon(Icons.view_in_ar_rounded, color: Colors.grey), onPressed: null),
                  ticket.haveCpr == 1
                      ? IconButton(
                          icon: const Icon(Icons.local_mall_rounded, color: Colors.red),
                          onPressed: () {
                            snackBarKey.currentState?.hideCurrentSnackBar();
                            snackBarKey.currentState?.showSnackBar(SnackBar(
                                content: Wrap(children: ticket.getCprReport().map((e) => Row(children: [Text("${e.status}"), const Spacer(), Text("${e.count}")])).toList()),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                width: 200));
                          })
                      : const IconButton(icon: Icon(Icons.local_mall_rounded, color: Colors.grey), onPressed: null),

                  //********************************************************************************************************************************************
                  if (ticket.isHold == 1)
                    IconButton(
                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.stop, color: Colors.black)),
                      onPressed: () {
                        FlagDialog().showFlagView(context, ticket, TicketFlagTypes.HOLD);
                      },
                    ),
                  if (ticket.isGr == 1)
                    IconButton(
                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.gr, color: Colors.blue)),
                      onPressed: () {
                        FlagDialog().showFlagView(context, ticket, TicketFlagTypes.GR);
                      },
                    ),
                  if (ticket.isSk == 1)
                    IconButton(
                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.sk, color: Colors.pink)),
                      onPressed: () {},
                    ),
                  if (ticket.isError == 1)
                    IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.report_problem_rounded, color: Colors.red)), onPressed: () {}),
                  // if (ticket.isSort == 1)
                  //   IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.local_mall_rounded, color: Colors.green)), onPressed: () {}),
                  if (ticket.isRush == 1)
                    IconButton(
                        icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent)),
                        onPressed: () {
                          FlagDialog().showFlagView(context, ticket, TicketFlagTypes.RUSH);
                        }),
                  if (ticket.isRed == 1)
                    IconButton(
                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.tour_rounded, color: Colors.red)),
                      onPressed: () {
                        FlagDialog().showFlagView(context, ticket, TicketFlagTypes.RED);
                      },
                    ),
                  if (ticket.isQa == 1)
                    IconButton(
                        icon: const CircleAvatar(backgroundColor: Colors.deepOrangeAccent, child: Text('QA', style: TextStyle(color: Colors.white))),
                        onPressed: () {
                          WebTicketQView(ticket, false).show(context);
                        }),
                  if (ticket.isQc == 1)
                    IconButton(
                        icon: const CircleAvatar(backgroundColor: Colors.red, child: Text('QC', style: TextStyle(color: Colors.white))),
                        onPressed: () {
                          WebTicketQView(ticket, true).show(context);
                        }),
                  IconButton(
                      icon: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.chat, color: ticket.haveComments ? Colors.blue : Colors.grey)),
                      onPressed: () {
                        TicketChatView(ticket).show(context);
                      }),
                  if (ticket.isStarted)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: CircularPercentIndicator(
                        radius: 20.0,
                        lineWidth: 5.0,
                        percent: ticket.progress / 100,
                        center: Text(
                          "${ticket.progress}%",
                          style: const TextStyle(fontSize: 12),
                        ),
                        progressColor: Colors.green,
                      ),
                    )
                ],
              ),
            )));
  }
}
