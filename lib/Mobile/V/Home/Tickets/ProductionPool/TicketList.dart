import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/M/NsUser.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';
import 'package:deebugee_plugin/DeeBugeeSearchBar.dart';
import 'package:smartwind_future_fibers/ns_icons_icons.dart';

import '../../../../../C/DB/DB.dart';
import '../../../../../C/DB/hive.dart';
import '../../../../../M/AppUser.dart';
import '../../../../../M/Ticket/CprReport.dart';
import '../../../../../Web/V/QC/webTicketQView.dart';
import '../../../../../globals.dart';
import '../../../Widgets/NoResultFoundMsg.dart';
import '../TicketInfo/TicketChatView.dart';
import '../TicketInfo/TicketInfo.dart';
import 'FlagDialog.dart';
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

  // var subscription;
  bool _showAllTickets = false;
  bool _showAllMyProduction = false;
  bool _filterByPdf = false;
  bool _filterByNoPdf = false;

  NsUser? nsUser;

  // final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  late DbChangeCallBack _dbChangeCallBack;

  var startedCount = 0;
  bool filterByStart = false;

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
    }, context, collection: DataTables.tickets);
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
                  if (s == 'Show All Tickets') {
                    _showAllTickets = !_showAllTickets;
                    _showAllMyProduction = false;
                    if (_showAllTickets) {
                      tabs = Production.values.map<String>((e) => e.getValue()).toList();
                    } else {
                      tabs = ["All"];
                    }
                    _tabBarController = TabController(length: tabs.length, vsync: this);
                    updateTabControler();
                    loadData();
                  } else if (s == '_showAllMyProduction') {
                    _showAllMyProduction = !_showAllMyProduction;
                    _showAllTickets = false;
                    loadData();
                  } else if (s == 'Pdf') {
                    _filterByPdf = !_filterByPdf;
                    _filterByNoPdf = false;
                    loadData();
                  } else if (s == 'noPdf') {
                    _filterByNoPdf = !_filterByNoPdf;
                    _filterByPdf = false;
                    loadData();
                  }
                  print(s);
                },
                itemBuilder: (BuildContext context) {
                  return [
                    CheckedPopupMenuItem<String>(value: 'Show All Tickets', checked: _showAllTickets, child: const Text("Show All Tickets")),
                    CheckedPopupMenuItem<String>(value: '_showAllMyProduction', checked: _showAllMyProduction, child: const Text("Show All My Production")),
                    CheckedPopupMenuItem<String>(value: "Pdf", checked: _filterByPdf, child: const Text("Filter By Pdf")),
                    CheckedPopupMenuItem<String>(value: 'noPdf', checked: _filterByNoPdf, child: const Text('Tickets don\'t have Pdf'))
                  ];
                },
              ),
            ],
            elevation: 0.0,
            toolbarHeight: 100,
            backgroundColor: Colors.green,
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
            title: SizedBox(
                height: ((!_showAllTickets) && nsUser != null && nsUser!.section != null) ? 50 : 30,
                child: Column(children: [
                  const Text("Production Pool", textScaleFactor: 1.2),
                  if ((!_showAllTickets) && nsUser != null && nsUser!.section != null)
                    InkWell(onTap: () => {}, child: Text(_showAllMyProduction ? nsUser!.section!.factory : "${nsUser!.section!.sectionTitle} @ ${nsUser!.section!.factory}"))
                ])),
            bottom: DeeBugeeSearchBar(
                searchController: searchController,
                delay: 500,
                onSearchTextChanged: (text) {
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
                flagIcon(Filters.isRed, TicketFlagTypes.RED.getIcon()),
                flagIcon(Filters.isYellow, TicketFlagTypes.YELLOW.getIcon()),
                flagIcon(Filters.isHold, NsIcons.stop),
                flagIcon(Filters.isSk, NsIcons.sk),
                flagIcon(Filters.isGr, NsIcons.gr),
                flagIcon(Filters.haveCpr, NsIcons.short),
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

  Widget getBody() {
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

  Column getTicketListByCategory(List<Ticket> filesList) {
    GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    return Column(children: [
      Expanded(
          child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () {
                return HiveBox.getDataFromServer().then((value) {
                  _refreshIndicatorKey.currentState?.show();
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
                                _refreshIndicatorKey.currentState?.show();
                              });

                              setState(() {});
                            }, onReload: () {
                              print('************************************************************************************************************');
                              _refreshIndicatorKey.currentState?.show();
                            });
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(height: 1, endIndent: 0.5, color: Colors.black12);
                          },
                        )
                      : Center(child: NoResultFoundMsg(onRetry: () {
                          _refreshIndicatorKey.currentState?.show();
                        })))))
    ]);
  }

  List<Ticket> _load(selectedProduction, section, showAllTickets, String searchText, {bySection = false, byProduction = false}) {
    List<Ticket> l = HiveBox.ticketBox.values.where((t) {
      if ((_filterByPdf ? t.hasNoFile : false)) {
        return false;
      }
      if ((_filterByNoPdf ? t.hasFile : false)) {
        return false;
      }

      if (t.completed != 0) {
        return false;
      }

      if (bySection && t.nowAt != nsUser?.section?.id) {
        return false;
      }
      if (byProduction && t.production != nsUser?.section?.factory) {
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
    } else if (_showAllMyProduction) {
      wipCountMap[Production.All] = 0;
      listsMap[Production.All] = _load(Production.All, 0, false, searchText, byProduction: true);
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

  IconButton flagIcon(Filters filter, IconData icon, {String? text}) {
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
      TicketInfo(ticket, fromBarcode: true).show(context);
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

  bool searchByProduction(Ticket t, Production selectedProduction) {
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
  final Function onLongPress;
  final Function onReload;

  const TicketTile(this.index, this.ticket, {super.key, required this.onLongPress, required this.onReload});

  @override
  Widget build(BuildContext context) {
    CprReport? kitReport = ticket.getKitReport();

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () async {
          // await showTicketOptions(ticket, context);
          // setState(() {});
          onLongPress();
        },
        onTap: () async {
          TicketInfo(ticket).show(context);
        },
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
                  // if (ticket.shipDate.isNotEmpty) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.directions_boat_outlined, size: 12, color: Colors.grey)),
                  // if (ticket.shipDate.isNotEmpty) Text(ticket.shipDate),
                  // if (ticket.shipDate.isNotEmpty) const SizedBox(width: 16),
                  if (ticket.deliveryDate.isNotEmpty) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.local_shipping_rounded, size: 12, color: Colors.grey)),
                  if (ticket.deliveryDate.isNotEmpty) Text(ticket.deliveryDate)
                ])
              ]),
              // subtitle: Text(ticket.fileVersion.toString()),
              trailing: Wrap(
                children: [
                  //********************************************************************************************************************************************

                  ticket.haveKit == 1 && kitReport != null
                      ? IconButton(
                          icon: Icon(kitReport!.itemCount > 0 ? Icons.inventory : Icons.view_in_ar_rounded, color: kitReport.status!.getColor()),
                          onPressed: () {
                            snackBarKey.currentState?.hideCurrentSnackBar();
                            snackBarKey.currentState?.showSnackBar(SnackBar(
                                content: Row(children: [Text("${kitReport.status}"), const Spacer(), Text("${kitReport.count}")]),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                width: 200));
                          })
                      : IconButton(icon: Icon(kitReport!.itemCount > 0 ? Icons.inventory : Icons.view_in_ar_rounded, color: Colors.grey), onPressed: null),
                  if (ticket.haveCpr == 1)
                    IconButton(
                        icon: const Icon(Icons.local_mall_rounded, color: Colors.red),
                        onPressed: () {
                          snackBarKey.currentState?.hideCurrentSnackBar();
                          snackBarKey.currentState?.showSnackBar(SnackBar(
                              content: Wrap(children: ticket.getCprReport().map((e) => Row(children: [Text("${e.status}"), const Spacer(), Text("${e.count}")])).toList()),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              width: 200));
                        }),
                  // : const IconButton(icon: Icon(Icons.local_mall_rounded, color: Colors.grey), onPressed: null),

                  //********************************************************************************************************************************************
                  if (ticket.isHold == 1)
                    IconButton(
                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.stop, color: Colors.black)),
                      onPressed: () {
                        // FlagDialog().showFlagView(context, ticket, TicketFlagTypes.HOLD);
                        FlagDialogNew(ticket, TicketFlagTypes.HOLD, editable: false).show(context);
                      },
                    ),
                  // if (ticket.isGr == 1)
                  //   IconButton(
                  //     icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.gr, color: Colors.blue)),
                  //     onPressed: () {
                  //       // FlagDialog().showFlagView(context, ticket, TicketFlagTypes.GR);
                  //       FlagDialogNew(ticket, TicketFlagTypes.GR, editable: false).show(context);
                  //     },
                  //   ),
                  // if (ticket.isSk == 1)
                  //   IconButton(
                  //     icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.sk, color: Colors.pink)),
                  //     onPressed: () {},
                  //   ),
                  if (ticket.isError == 1)
                    IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.report_problem_rounded, color: Colors.red)), onPressed: () {}),
                  // if (ticket.isSort == 1)
                  //   IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.local_mall_rounded, color: Colors.green)), onPressed: () {}),
                  if (ticket.isRush == 1)
                    IconButton(
                        icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent)),
                        onPressed: () {
                          // FlagDialog().showFlagView(context, ticket, TicketFlagTypes.RUSH);
                          FlagDialogNew(ticket, TicketFlagTypes.RUSH, editable: false).show(context);
                        }),
                  if (ticket.isRed == 1)
                    IconButton(
                      icon: CircleAvatar(backgroundColor: Colors.white, child: Icon(TicketFlagTypes.RED.getIcon(), color: Colors.red)),
                      onPressed: () {
                        // FlagDialog().showFlagView(context, ticket, TicketFlagTypes.RED);
                        FlagDialogNew(ticket, TicketFlagTypes.RED, editable: false).show(context);
                      },
                    ),
                  if (ticket.isYellow == 1)
                    IconButton(
                        icon: CircleAvatar(backgroundColor: Colors.white, child: Icon(TicketFlagTypes.YELLOW.getIcon(), color: Colors.orangeAccent)),
                        onPressed: () => {FlagDialogNew(ticket, TicketFlagTypes.YELLOW, editable: false).show(context)}),
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
