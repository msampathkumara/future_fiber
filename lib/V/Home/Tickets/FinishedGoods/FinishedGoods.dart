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

class FinishedGoods extends StatefulWidget {
  FinishedGoods({Key? key}) : super(key: key);

  @override
  _FinishedGoodsState createState() {
    return _FinishedGoodsState();
  }
}

class _FinishedGoodsState extends State<FinishedGoods> with TickerProviderStateMixin {
  var database;
  var themeColor = Colors.deepOrange;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
      loadData(0);
    });
  }

  late List listsArray;

  @override
  void dispose() {
    super.dispose();
  }

  TextEditingController searchController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);
              if (barcode == '-1') {
                print('nothing return.');
              } else {
                searchController.value = TextEditingValue(text: barcode, selection: TextSelection.fromPosition(TextPosition(offset: barcode.length)));
              }
            },
            child: const Icon(Icons.qr_code_rounded),
            backgroundColor: themeColor),
        appBar: AppBar(
          actions: <Widget>[],
          elevation: 0.0,
          toolbarHeight: 82,
          backgroundColor: themeColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Finished Goods",
            textScaleFactor: 1.2,
          ),
          bottom: SearchBar(
              searchController: searchController,
              onSearchTextChanged: (text) {
                if (subscription != null) {
                  subscription.cancel();
                }
                searchText = text;
                _ticketList = [];
                var future = new Future.delayed(const Duration(milliseconds: 300));
                subscription = future.asStream().listen((v) {
                  print("SEARCHING FOR $searchText");
                  var t = DateTime.now().millisecondsSinceEpoch;

                  loadData(0).then((value) {
                    print("SEARCHING time ${(DateTime.now().millisecondsSinceEpoch - t)}");
                    t = DateTime.now().millisecondsSinceEpoch;
                    setState(() {});
                    print("load time ${(DateTime.now().millisecondsSinceEpoch - t)}");
                  });
                });
              }),
          centerTitle: true,
        ),
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
            color: themeColor,
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
                  Padding(padding: const EdgeInsets.all(8.0), child: Text("$dataCount", textScaleFactor: 1.1, style: TextStyle(color: Colors.white))),
                  const Spacer(),
                  // Text("Sorted by $sortedBy", style: TextStyle(color: Colors.white)),
                  SizedBox(width: 36)
                ],
              ),
            )));
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

  getBody() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          backgroundColor: themeColor,
          // elevation: (!_showFilters && _showFiltersEnd) ? 4 : 0,
          elevation: 4,
          actions: [],
          title: Wrap(
            spacing: 5,
            children: [
              _productionChip(Production.All),
              _productionChip(Production.Upwind),
              _productionChip(Production.OD),
              _productionChip(Production.Nylon),
              _productionChip(Production.OEM),
            ],
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
              return loadData(0).then((value) {
                setState(() {});
              });
            },
            child: (_ticketList.length == 0 && (!requested))
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

                            loadData(x.toInt());
                          }
                          return Container(
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
                                                loadData(x.toInt());
                                              }
                                            },
                                            child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(100.0),
                                                ),
                                                child: Padding(
                                                    padding: const EdgeInsets.all(12.0),
                                                    child: !_dataLoadingError
                                                        ? CircularProgressIndicator(color: Colors.red, strokeWidth: 2)
                                                        : Icon(
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
                                      icon: CircleAvatar(child: Icon(NsIcons.gr, color: Colors.blue), backgroundColor: Colors.white),
                                      onPressed: () {},
                                    ),
                                  if (ticket.isSk == 1)
                                    IconButton(
                                      icon: CircleAvatar(child: Icon(NsIcons.sk, color: Colors.pink), backgroundColor: Colors.white),
                                      onPressed: () {},
                                    ),
                                  if (ticket.isError == 1)
                                    IconButton(
                                      icon: CircleAvatar(child: Icon(Icons.report_problem_rounded, color: Colors.red), backgroundColor: Colors.white),
                                      onPressed: () {},
                                    ),
                                  if (ticket.isSort == 1)
                                    IconButton(
                                      icon: CircleAvatar(child: Icon(Icons.local_mall_rounded, color: themeColor), backgroundColor: Colors.white),
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
                                      radius: 18.0,
                                      lineWidth: 5.0,
                                      percent: ticket.progress / 100,
                                      center: new Text(
                                        ticket.progress.toString() + "%",
                                        style: TextStyle(fontSize: 12),
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

  Future<void> showTicketOptions(Ticket ticket, BuildContext context1) async {
    print(ticket.toJson());
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          height: 350,
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
                      title: Text("Send Ticket"),
                      leading: Icon(Icons.send_rounded, color: Colors.lightBlue),
                      onTap: () async {
                        await ticket.sharePdf(context);
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                      title: Text("Delete"),
                      leading: Icon(Icons.delete_forever, color: Colors.red),
                      onTap: () async {
                        OnlineDB.apiPost("tickets/delete", {"id": ticket.id.toString()}).then((response) async {
                          print('TICKET DELETED');
                          print(response.data);
                          print(response.statusCode);
                        }).catchError((error) {
                          ErrorMessageView(errorMessage: error.toString()).show(context);
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

  Future loadData(int page) {
    setState(() {
      requested = true;
    });
    return OnlineDB.apiGet("tickets/completed/getList", {
      'production': _selectedProduction.toShortString(),
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

      tickets.forEach((element) {
        _ticketList.add(Ticket.fromJson(element));
      });
      final ids = _ticketList.map((e) => e.id).toSet();
      _ticketList.retainWhere((x) => ids.remove(x.id));
      _dataLoadingError = false;
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
          p.toShortString(),
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
}
