import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/Tickets/TicketInfo/TicketInfo.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';
import 'package:smartwind/ns_icons_icons.dart';

import '../../../../M/AppUser.dart';
import '../../../../Web/V/QC/webTicketQView.dart';

class FinishedGoods extends StatefulWidget {
  const FinishedGoods({Key? key}) : super(key: key);

  @override
  _FinishedGoodsState createState() {
    return _FinishedGoodsState();
  }
}

class _FinishedGoodsState extends State<FinishedGoods> with TickerProviderStateMixin {
  var database;
  var themeColor = Colors.deepOrange;

  List<Widget> factoryChipsList = [];

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  late List listsArray;

  @override
  void dispose() {
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
  bool _isBarcodeScan = false;

  @override
  Widget build(BuildContext context) {
    factoryChipsList = Production.values.map<Widget>((e) => e == Production.None ? Container() : _productionChip(e)).toList();
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);
              if (barcode == '-1') {
                print('nothing return.');
              } else {
                searchController.value = TextEditingValue(text: barcode, selection: TextSelection.fromPosition(TextPosition(offset: barcode.length)));
                _isBarcodeScan = true;
              }
            },
            backgroundColor: themeColor,
            child: const Icon(Icons.qr_code_rounded)),
        appBar: AppBar(
          actions: const <Widget>[],
          elevation: 0.0,
          toolbarHeight: 82,
          backgroundColor: themeColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Finished Goods",
            textScaleFactor: 1.2,
          ),
          bottom: SearchBar(
              delay: 300,
              searchController: searchController,
              onSearchTextChanged: (text) {
                if (subscription != null) {
                  subscription.cancel();
                }
                searchText = text;
                _ticketList = [];

                print("SEARCHING FOR $searchText");

                loadData(0);
              }),
          centerTitle: true,
        ),
        body: Container(
          color: themeColor,
          child: Column(
            children: [
              Wrap(children: [
                flagIcon(Filters.isCrossPro, Icons.merge_type_rounded),
                flagIcon(Filters.isError, Icons.warning_rounded),
                flagIcon(Filters.inPrint, Icons.print_rounded),
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
            color: themeColor,
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
                          _sortByBottomSheetMenu();
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(padding: const EdgeInsets.all(8.0), child: Text("$dataCount", textScaleFactor: 1.1, style: const TextStyle(color: Colors.white))),
                  const Spacer(),
                  // Text("Sorted by $sortedBy", style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 36)
                ],
              ),
            )));
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
        await loadData(0);
        setState(() {
          print('xxxxxxxxxxxxx');
        });
      },
    );
  }

  String listSortBy = "uptime";
  String sortedBy = "Date";
  String searchText = "";
  var subscription;
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
          _ticketList = [];
          loadData(0);
          setState(() {});
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
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
                          getListItem("Shipping Date", Icons.date_range_rounded, "shipDate"),
                          getListItem("Modification Date", Icons.date_range_rounded, "uptime"),
                          getListItem("Name", Icons.sort_by_alpha_rounded, "mo"),
                          getListItem("Shipping Date", Icons.date_range_rounded, "deliveryDate"),
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }

  getBody() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          backgroundColor: themeColor,
          // elevation: (!_showFilters && _showFiltersEnd) ? 4 : 0,
          elevation: 4,
          actions: const [],
          title: Wrap(
            spacing: 5,
            children: factoryChipsList,
          ),
        ),
        body: _getTicketsList());
  }

  var _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  _getTicketsList() {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              return _loadData(0);
            },
            child: (_ticketList.isEmpty && (!requested))
                ? Center(child: Text(searchText.isEmpty ? "No Tickets Found" : "⛔ Work Ticket not found.\n Please contact  Ticket Checking department", textScaleFactor: 1.5))
                : Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _ticketList.length < dataCount ? _ticketList.length + 1 : _ticketList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_ticketList.length == index) {
                          if (!requested && (!_dataLoadingError)) {
                            var x = ((_ticketList.length) / 20);

                            _loadData(x.toInt());
                          }
                          return SizedBox(
                              height: 100,
                              child: Center(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: SizedBox(
                                          height: 48,
                                          width: 48,
                                          child: InkWell(
                                            onTap: () {
                                              if (_dataLoadingError) {
                                                setState(() {
                                                  _dataLoadingError = false;
                                                });
                                                var x = ((_ticketList.length) / 20);
                                                _loadData(x.toInt());
                                              }
                                            },
                                            child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(100.0),
                                                ),
                                                child: Padding(
                                                    padding: const EdgeInsets.all(12.0),
                                                    child: !_dataLoadingError
                                                        ? const CircularProgressIndicator(color: Colors.red, strokeWidth: 2)
                                                        : const Icon(
                                                            Icons.refresh_rounded,
                                                            size: 18,
                                                          ))),
                                          )))));
                        }

                        Ticket ticket = (_ticketList[index]);
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
                                color: ticket.isHold == 1 ? Colors.black12 : Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(20))),
                            child: ListTile(
                              leading: Text("${index + 1}"),
                              title: Text(
                                (ticket.mo ?? "").trim().isEmpty ? (ticket.oe ?? "") : ticket.mo ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Wrap(
                                direction: Axis.vertical,
                                children: [
                                  if ((ticket.mo ?? "").trim().isNotEmpty) Text((ticket.oe ?? "")),
                                  if (ticket.isCrossPro)
                                    Material(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.deepOrange,
                                        child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(('${ticket.crossPro?.fromSection?.factory} > ${ticket.crossPro?.toSection?.factory}'),
                                                style: const TextStyle(fontSize: 12, color: Colors.white)))),

                                  // Chip(
                                  //     avatar: const CircleAvatar(
                                  //       child: Icon(
                                  //         Icons.merge_type_outlined,
                                  //       ),
                                  //     ),
                                  //     label: Text(('${ticket.crossPro?.fromSection?.factory} > ${ticket.crossPro?.toSection?.factory}'))),
                                  Text(ticket.getUpdateDateTime()),
                                ],
                              ),
                              // subtitle: Text(ticket.fileVersion.toString()),
                              trailing: Wrap(
                                children: [
                                  if (ticket.inPrint == 1)
                                    IconButton(
                                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.print_rounded, color: Colors.deepOrangeAccent)),
                                      onPressed: () {},
                                    ),
                                  if (ticket.isHold == 1)
                                    IconButton(
                                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.pan_tool_rounded, color: Colors.black)),
                                      onPressed: () {},
                                    ),
                                  if (ticket.isGr == 1)
                                    IconButton(
                                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.gr, color: Colors.blue)),
                                      onPressed: () {},
                                    ),
                                  if (ticket.isSk == 1)
                                    IconButton(
                                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.sk, color: Colors.pink)),
                                      onPressed: () {},
                                    ),
                                  if (ticket.isError == 1)
                                    IconButton(
                                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.report_problem_rounded, color: Colors.red)),
                                      onPressed: () {},
                                    ),
                                  if (ticket.isSort == 1)
                                    IconButton(
                                      icon: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.local_mall_rounded, color: themeColor)),
                                      onPressed: () {},
                                    ),
                                  if (ticket.isRush == 1)
                                    IconButton(
                                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent)),
                                      onPressed: () {},
                                    ),
                                  if (ticket.isRed == 1)
                                    IconButton(
                                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.tour_rounded, color: Colors.red)),
                                      onPressed: () {},
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: CircularPercentIndicator(
                                      radius: 18.0,
                                      lineWidth: 5.0,
                                      percent: ticket.progress / 100,
                                      center: Text(
                                        ticket.progress.toString() + "%",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      progressColor: themeColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(
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

  Future<void> showTicketOptions(Ticket ticket, BuildContext context1) async {
    print(ticket.toJson());
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          height: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(
                title: Text(ticket.mo ?? ticket.oe!),
                subtitle: Text(ticket.oe!),
              ),
              const Divider(),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                ListTile(
                    title: const Text("Send Ticket"),
                    leading: const Icon(Icons.send_rounded, color: Colors.lightBlue),
                    onTap: () async {
                      await ticket.sharePdf(context);
                      Navigator.of(context).pop();
                    }),
                if (AppUser.havePermissionFor(Permissions.DELETE_COMPLETED_TICKETS))
                  ListTile(
                      title: const Text("Delete"),
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      onTap: () async {
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Do you really want to delete ${ticket.mo}/${ticket.oe}'),
                            action: SnackBarAction(
                                onPressed: () {
                                  OnlineDB.apiPost("tickets/delete", {"id": ticket.id.toString()}).then((response) async {
                                    print('TICKET DELETED');
                                    print(response.data);
                                    print(response.statusCode);
                                  }).catchError((error) {
                                    ErrorMessageView(errorMessage: error.toString()).show(context);
                                  });
                                },
                                label: 'Yes')));
                      }),
              ])))
            ],
          ),
        );
      },
    );
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

  bool requested = false;
  int dataCount = 0;
  List<Ticket> _ticketList = [];
  bool _dataLoadingError = false;

  Future _loadData(int page) {
    // setState(() {
    requested = true;
    // });
    return OnlineDB.apiGet("tickets/completed/getList", {
      'production': _selectedProduction.getValue(),
      "flag": dataFilter.getValue(),
      'sortDirection': "desc",
      'sortBy': listSortBy,
      'pageIndex': page,
      'pageSize': 20,
      'searchText': searchText
    }).then((res) {
      print(res.data);
      List tickets = res.data["tickets"];
      dataCount = res.data["count"];

      if (page == 0) {
        _ticketList = [];
      }

      _ticketList.addAll(Ticket.fromJsonArray(tickets));

      final ids = _ticketList.map((e) => e.id).toSet();
      _ticketList.retainWhere((x) => ids.remove(x.id));
      _dataLoadingError = false;

      if (_isBarcodeScan && _ticketList.isNotEmpty) {
        var ticketInfo = TicketInfo(_ticketList.first);
        ticketInfo.show(context);
        searchController.value = TextEditingValue(text: '', selection: TextSelection.fromPosition(const TextPosition(offset: 0)));
      }
      _isBarcodeScan = false;

      setState(() {});
    }).whenComplete(() {
      setState(() {
        requested = false;
      });
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                loadData(page);
              })));
      setState(() {
        _dataLoadingError = true;
      });
    });
  }

  Production _selectedProduction = Production.All;

  _productionChip(Production p) {
    return FilterChip(
        selectedColor: Colors.white,
        checkmarkColor: themeColor,
        label: Text(
          p.getValue(),
          style: TextStyle(color: _selectedProduction == p ? themeColor : Colors.black),
        ),
        selected: _selectedProduction == p,
        onSelected: (bool value) {
          _selectedProduction = p;
          _ticketList = [];
          loadData(0);
          setState(() {});
        });
  }

  loadData(int i) {
    _refreshIndicatorKey.currentState?.show();
  }
}
