import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/Mobile/V/Home/Tickets/TicketInfo/TicketInfo.dart';
import 'package:smartwind/Mobile/V/Widgets/SearchBar.dart';

import '../../../../../M/AppUser.dart';
import '../../../../../M/EndPoints.dart';
import '../../../../../M/PermissionsEnum.dart';
import '../../../../../M/StandardTicket.dart';
import '../../../../../globals.dart';
import '../../../Widgets/NoResultFoundMsg.dart';
import 'StandardTicketInfo.dart';
import 'factory_selector.dart';

class StandardFiles extends StatefulWidget {
  const StandardFiles({Key? key}) : super(key: key);

  @override
  _StandardFilesState createState() {
    return _StandardFilesState();
  }
}

class _StandardFilesState extends State<StandardFiles> with TickerProviderStateMixin {
  var themeColor = Colors.green;

  List<Widget> factoryChipsList = [];

  bool loading = true;

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
    if (!cancelToken.isCancelled) {
      cancelToken.cancel();
    }
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
  bool _isBarcodeScan = false;

  @override
  Widget build(BuildContext context) {
    factoryChipsList = StandardProductions.values.map<Widget>((e) => _productionChip(e)).toList();
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
            title: const Text("Standard Library", textScaleFactor: 1.2),
            bottom: SearchBar(
                delay: 300,
                searchController: searchController,
                onSearchTextChanged: (text) {
                  searchText = text;
                  _ticketList = [];

                  print("SEARCHING FOR $searchText");

                  loadData(0);
                }),
            centerTitle: true),
        body: getBody(),
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

  String listSortBy = "completedOn";
  String sortedBy = "Date";
  String searchText = "";

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
        context: context,
        builder: (builder) {
          return Container(
              color: Colors.transparent,
              child: Column(children: [
                const Padding(padding: EdgeInsets.all(16.0), child: Text("Sort By", textScaleFactor: 1.2)),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: ListView(children: [
                          getListItem("Date", Icons.date_range_rounded, "uptime"),
                          getListItem("Name", Icons.sort_by_alpha_rounded, "oe"),
                          getListItem("Usage", Icons.data_usage_outlined, "usedCount")
                        ])))
              ]));
        });
  }

  getBody() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            toolbarHeight: 50,
            automaticallyImplyLeading: false,
            backgroundColor: themeColor,
            elevation: 4,
            actions: const [],
            title: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Wrap(spacing: 5, children: factoryChipsList))),
        body: _getTicketsList());
  }

  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  _getTicketsList() {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              setState(() {
                loading = true;
              });
              return _loadData(0);
            },
            child: (_ticketList.isEmpty && (!requested))
                ? Center(
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        child: loading
                            ? Container()
                            : NoResultFoundMsg(onRetry: () {
                                _refreshIndicatorKey.currentState?.show();
                              })))
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

                        StandardTicket ticket = (_ticketList[index]);
                        return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onLongPress: () async {
                              await showStandardTicketOptions(ticket, context);
                              setState(() {});
                            },
                            onTap: () {
                              StandardTicketInfo(ticket).show(context);
                            },
                            onDoubleTap: () async {
                              Ticket.open(context, ticket);
                      },
                      child: Ink(
                          decoration: BoxDecoration(
                              color: ticket.isHold == 1 ? Colors.black12 : Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: const BorderRadius.all(Radius.circular(20))),
                          child: ListTile(
                              leading: Text("${index + 1}"),
                              title: Text((ticket.oe ?? ""), style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(ticket.getUpdateDateTime()),
                              trailing: Text("${ticket.usedCount}"))));
                },
                separatorBuilder: (BuildContext context, int index) {
                        return const Divider(height: 1, endIndent: 0.5, color: Colors.black12);
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  bool requested = true;
  int dataCount = 0;
  List<StandardTicket> _ticketList = [];
  bool _dataLoadingError = false;
  CancelToken cancelToken = CancelToken();

  Future _loadData(int page) {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel();
    }
    cancelToken = CancelToken();
    requested = true;

    print('searchText== $searchText');

    return Api.get(
            EndPoints.tickets_standard_getList,
            {
              'production': _selectedProduction.getValue(),
              "flag": dataFilter.getValue(),
              'sortDirection': "desc",
              'sortBy': listSortBy,
              'pageIndex': page,
              'pageSize': 20,
              'searchText': searchText
            },
            cancelToken: cancelToken)
        .then((res) {
      print(res.data);
      List tickets = res.data["tickets"];
      dataCount = res.data["count"];

      if (page == 0) {
        _ticketList = [];
      }

      try {
        _ticketList.addAll(StandardTicket.fromJsonArray(tickets));
      } catch (e) {
        print(e);
      }

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
        loading = false;
      });
    }).catchError((err) {
      print("--------------------------------------------err");
      print(err);
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

  StandardProductions _selectedProduction = StandardProductions.All;

  _productionChip(StandardProductions p) {
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
          loading = true;
          loadData(0);
          setState(() {});
        });
  }

  loadData(int i) {
    _refreshIndicatorKey.currentState?.show();
  }
}

Future<void> showStandardTicketOptions(StandardTicket ticket, BuildContext context1) async {
  print(ticket.toJson());
  await showModalBottomSheet<void>(
    constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
    context: context1,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 650,
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
                      if (AppUser.havePermissionFor(NsPermissions.STANDARD_FILES_CHANGE_FACTORY))
                        ListTile(
                            title: const Text("Change Factory"),
                            leading: const Icon(Icons.send_outlined, color: Colors.lightBlue),
                            onTap: () async {
                              Navigator.of(context).pop();
                              showFactories(ticket, context1);
                              // await Navigator.push(context1, MaterialPageRoute(builder: (context) => changeFactory(ticket)));
                              // Navigator.of(context).pop();
                            }),
                      if (AppUser.havePermissionFor(NsPermissions.STANDARD_FILES_DELETE_STANDARD_FILES))
                        ListTile(
                            title: const Text("Delete"),
                            leading: const Icon(Icons.delete_forever, color: Colors.red),
                            onTap: () async {
                              snackBarKey.currentState?.showSnackBar(SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  width: 500,
                                  backgroundColor: Colors.red,
                                  content: Row(
                                    children: [
                                      const Text("Do You really want to delete this standard ticket ?"),
                                      const Spacer(),
                                      TextButton(
                                          onPressed: () {
                                            snackBarKey.currentState?.showSnackBar(const SnackBar(behavior: SnackBarBehavior.floating, width: 200, content: Text('Deleting')));
                                            Api.post(EndPoints.tickets_standard_delete, {'id': ticket.id.toString()}).then((response) async {
                                              print(response.data);
                                              snackBarKey.currentState?.showSnackBar(
                                                  const SnackBar(behavior: SnackBarBehavior.floating, width: 200, backgroundColor: Colors.green, content: Text('Delete Successfully')));
                                            });
                                          },
                                          child: const Text("Yes"))
                                    ],
                                  ),
                                  action: SnackBarAction(
                                      label: 'No',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        snackBarKey.currentState?.removeCurrentSnackBar();
                                      })));

                              Navigator.of(context).pop();
                            }),
                    ])))
          ],
        ),
      );
    },
  );
}

Future<void> showFactories(StandardTicket ticket, BuildContext context1) async {
  print(ticket.toJson());
  await showModalBottomSheet<void>(
    constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
    context: context1,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 650,
        child: FactorySelector(ticket.production ?? "", onSelect: (factory) async {
          await Api.post(EndPoints.tickets_standard_changeFactory, {'production': factory, 'ticketId': ticket.id});
          // await HiveBox.getDataFromServer();

          print(factory);
        }),
      );
    },
  );
}
