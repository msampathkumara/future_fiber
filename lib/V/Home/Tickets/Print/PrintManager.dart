import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/TicketPrint.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';

class PrintManager extends StatefulWidget {
  const PrintManager({Key? key}) : super(key: key);

  @override
  _PrintManagerState createState() => _PrintManagerState();
}

class _PrintManagerState extends State<PrintManager> with TickerProviderStateMixin {
  var database;
  var themeColor = Colors.blue;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[],
          elevation: 0,
          toolbarHeight: 80,
          backgroundColor: themeColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Print", textScaleFactor: 1.2),
          bottom: SearchBar(
              delay: 300,
              onSearchTextChanged: (text) {
                searchText = text;
                _ticketPrintList = [];
                loadData(0).then((value) {
                  setState(() {});
                });
              },
              onSubmitted: (text) {}),
          centerTitle: true,
        ),
        body: getBody(),
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            color: themeColor,
            child: IconTheme(
              data: IconThemeData(color: Colors.white),
              child: Row(
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: Text("${_ticketPrintList.length}/$dataCount", textScaleFactor: 1.1, style: TextStyle(color: Colors.white))),
                  const Spacer(),
                  Text("Sorted by $sortedBy", style: TextStyle(color: Colors.white)),
                  InkWell(
                      onTap: () {},
                      splashColor: Colors.red,
                      child: Ink(
                          child: IconButton(
                              icon: Icon(Icons.sort_by_alpha_rounded),
                              onPressed: () {
                                _sortByBottomSheetMenu();
                              })))
                ],
              ),
            )));
  }

  String listSortBy = "doneOn";
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
          _ticketPrintList = [];
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

  getBody() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          backgroundColor: themeColor,
          elevation: 10,
          actions: [],
          title: Wrap(spacing: 5, children: [_statusChip(Status.All), _statusChip(Status.Sent), _statusChip(Status.Done), _statusChip(Status.Cancel)]),
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
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _ticketPrintList.length < dataCount ? _ticketPrintList.length + 1 : _ticketPrintList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (_ticketPrintList.length == index) {
                    if (!requested && (!_dataLoadingError)) {
                      var x = ((_ticketPrintList.length) / 20);

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
                                          var x = ((_ticketPrintList.length) / 20);
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

                  TicketPrint ticketPrint = (_ticketPrintList[index]);
                  return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () async {
                        // await showTicketOptions(ticketPrint, context);
                        // setState(() {});
                      },
                      onTap: () {
                        // var ticketInfo = TicketInfo(ticket);
                        // ticketInfo.show(context);
                      },
                      onDoubleTap: () async {
                        // print(await ticket.getLocalFileVersion());
                        // ticket.open(context);
                      },
                      child: Ink(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                          child: ListTile(
                              leading: Text("${index + 1}"),
                              title: Text(
                                (ticketPrint.ticket!.mo ?? "").trim().isEmpty ? (ticketPrint.ticket!.oe ?? "") : ticketPrint.ticket!.mo ?? "",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Wrap(
                                direction: Axis.vertical,
                                children: [
                                  if ((ticketPrint.ticket!.mo ?? "").trim().isNotEmpty) Text((ticketPrint.ticket!.oe ?? "")),
                                  Text(ticketPrint.doneOn),
                                ],
                              ),
                              // subtitle: Text(ticket.fileVersion.toString()),
                              trailing: Wrap(children: [Text("${ticketPrint.action}", textScaleFactor: 1)]))));
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
  List<TicketPrint> _ticketPrintList = [];
  bool _dataLoadingError = false;

  Future loadData(int page) {
    requested = true;
    return OnlineDB.apiGet("tickets/print/getList",
        {'status': _selectedStatus.getValue(), 'sortDirection': "desc", 'sortBy': listSortBy, 'pageIndex': page, 'pageSize': 20, 'searchText': searchText}).then((res) {
      print(res.data);
      List prints = res.data["prints"];
      dataCount = res.data["count"];

      prints.forEach((element) {
        _ticketPrintList.add(TicketPrint.fromJson(element));
      });
      final ids = _ticketPrintList.map((e) => e.id).toSet();
      _ticketPrintList.retainWhere((x) => ids.remove(x.id));
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
      throw err;
    });
  }

  Status _selectedStatus = Status.All;

  _statusChip(Status p) {
    return FilterChip(
        selectedColor: Colors.white,
        checkmarkColor: themeColor,
        label: Text(
          p.getValue(),
          style: TextStyle(color: _selectedStatus == p ? themeColor : Colors.black),
        ),
        selected: _selectedStatus == p,
        onSelected: (bool value) {
          _selectedStatus = p;
          _ticketPrintList = [];
          loadData(0);
          setState(() {});
        });
  }
}
