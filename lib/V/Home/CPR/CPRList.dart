import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:measured_size/measured_size.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/CPR.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';

import 'CprDerails.dart';

class CPRList extends StatefulWidget {
  CPRList({Key? key}) : super(key: key);

  @override
  _CPRListState createState() {
    return _CPRListState();
  }
}

class _CPRListState extends State<CPRList> {
  var subscription;

  var searchText;

  var themeColor = Colors.amber;

  @override
  void initState() {
    super.initState();

    _reloadData(0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  var _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<CPR> _cprList = [];
  int page = 0;
  bool _showFilters = false;
  bool _showFiltersEnd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          toolbarHeight: 150,
          backgroundColor: Colors.amber,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "CPR",
            textScaleFactor: 1.2,
          ),
          bottom: SearchBar(
            onSearchTextChanged: (text) {
              if (subscription != null) {
                subscription.cancel();
              }
              searchText = text;
              setState(() {
                _cprList = [];
              });
              var future = new Future.delayed(const Duration(milliseconds: 500));
              subscription = future.asStream().listen((v) {
                reloadData(0).then((value) {
                  setState(() {});
                });
              });
            },
            onSubmitted: (text) {},
            OnBarcode: (barcode) {
              print("xxxxxxxxxxxxxxxxxx $barcode");
            },
          ),
          centerTitle: true,
        ),
        body: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            automaticallyImplyLeading: false,
            backgroundColor: themeColor,
            elevation: (!_showFilters && _showFiltersEnd) ? 4 : 0,
            actions: [
              IconButton(
                icon: Icon(Icons.filter_alt_rounded),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                    _showFiltersEnd = false;
                  });
                },
              )
            ],
            title: Wrap(
              spacing: 5,
              children: [
                if (_selectedStatus != "All")
                  _actionChip(_selectedStatus, () {
                    _selectedStatus = "All";
                  }),
                if (_selectedShortageType != "All")
                  _actionChip(_selectedShortageType, () {
                    _selectedShortageType = "All";
                  }),
                if (_selectedCprTypes != "All")
                  _actionChip(_selectedCprTypes, () {
                    _selectedCprTypes = "All";
                  })
              ],
            ),
          ),
          body: Column(
            children: [
              new AnimatedContainer(
                  onEnd: () {
                    setState(() {
                      _showFiltersEnd = true;
                    });
                  },
                  curve: Curves.easeInOut,
                  height: _showFilters ? __filterHeight : 0,
                  color: themeColor,
                  child: Material(
                    elevation: 4,
                    child: _getFilters(),
                  ),
                  duration: new Duration(milliseconds: 500)),
              Expanded(
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: () {
                    _cprList = [];
                    return _reloadData(0);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(4),
                    itemCount: _cprList.length < dataCount ? _cprList.length + 1 : _cprList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (_cprList.length == index) {
                        if (!requested) {
                          var x = ((_cprList.length) / 20);

                          reloadData(x.toInt());
                        }
                        return Container(
                            height: 100,
                            child: Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SizedBox(
                                        height: 48,
                                        width: 48,
                                        child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(100.0),
                                            ),
                                            child: Padding(padding: const EdgeInsets.all(12.0), child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2)))))));
                      }

                      CPR cpr = _cprList[index];
                      // print(cpr.toJson());
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () async {
                          await showCPROptions(cpr, context);
                          setState(() {});
                        },
                        onTap: () {
                          CprDetails.show(context, cpr);
                        },
                        onDoubleTap: () async {
                          // print(await ticket.getLocalFileVersion());
                          // ticket.open(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(border: Border(left: BorderSide(color: getColor(cpr.status), width: 3.0))),
                          child: ListTile(
                            leading: Text("${index + 1}"),
                            title: Text(cpr.mo ?? cpr.oe),
                            subtitle: Wrap(
                              direction: Axis.vertical,
                              children: [
                                Text(cpr.mo != null ? cpr.oe ?? "" : ""),
                                Text(cpr.dnt ?? ""),
                              ],
                            ),
                            trailing: Wrap(children: [
                              SizedBox(
                                width: 150,
                                child: Wrap(
                                  direction: Axis.vertical,
                                  children: [Text(cpr.client ?? ""), Text(cpr.supplier, style: TextStyle(color: Colors.red))],
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: Wrap(
                                  direction: Axis.vertical,
                                  children: [Text(cpr.shortageType ?? ""), Text(cpr.cprType ?? "", style: TextStyle(color: Colors.red))],
                                ),
                              )
                            ]),
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
                  Padding(padding: const EdgeInsets.all(8.0), child: Text("$dataCount", textScaleFactor: 1.1, style: TextStyle(color: Colors.white))),
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
                        },
                      ),
                    ),
                  )
                ],
              ),
            )));
  }

  var _selectedStatus = "All";
  var _selectedShortageType = "All";
  var _selectedCprTypes = "All";

  var __statusList = ["All", "Ready", "Pending", "Sent"];
  var __shortageTypes = ["All", "Short", "Damage", "Unreceived"];
  var __cprTypes = ["All", "Pocket", "Rope Luff", "Purchase Cover", "Overhead Tape", "Tape Cover", "Take Down", "Soft Hanks", "Windows", "Stow pouch", "VPC**", "Other"];

  var __filterHeight = 0.0;

  _getFilters() {
    return SingleChildScrollView(
      child: ClipRect(
        child: Container(
          color: themeColor,
          child: MeasuredSize(
            onChange: (Size size) {
              setState(() {
                __filterHeight = size.height;
                print(size);
              });
            },
            child: Wrap(
              children: [
                ListTile(
                    title: Text("Production", style: TextStyle(color: Colors.white)),
                    subtitle: Wrap(spacing: 5, children: [
                      for (final st in __statusList)
                        _filterChip(_selectedStatus, st, () {
                          _selectedStatus = st;
                        })
                    ])),
                ListTile(
                    title: Text("Shortage Type", style: TextStyle(color: Colors.white)),
                    subtitle: Wrap(spacing: 5, children: [
                      for (final st in __shortageTypes)
                        _filterChip(_selectedShortageType, st, () {
                          _selectedShortageType = st;
                        })
                    ])),
                ListTile(
                    title: Text("Cpr Types", style: TextStyle(color: Colors.white)),
                    subtitle: Wrap(spacing: 5, children: [
                      for (final st in __cprTypes)
                        _filterChip(_selectedCprTypes, st, () {
                          _selectedCprTypes = st;
                        })
                    ])),
                ListTile(
                  trailing: ElevatedButton(
                    onPressed: () {
                      reloadData(0, reset: true);
                      setState(() {
                        _showFilters = false;
                      });
                    },
                    child: Text("Done"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  var listSortBy = "";

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
          _cprList = [];
          reloadData(0);
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
                          getListItem("Shortage Type", Icons.format_align_center_rounded, "shortageType")
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }

  var sortedBy = "id";
  int dataCount = 0;
  bool requested = false;

  reloadData(int page, {bool reset = false}) {
    print('Reload Data');
    if (page == 0 || reset) {
      _refreshIndicatorKey.currentState?.show();
      _cprList = [];
      dataCount = 0;
      return;
    }
    _reloadData(page);
  }

  _reloadData(int page) {
    requested = true;
    return OnlineDB.apiGet("cpr/search", {
      'shortageType': _selectedShortageType,
      'cprType': _selectedCprTypes,
      'status': _selectedStatus,
      'sortDirection': "asc",
      'page': page,
      'npp': 20,
      'query': searchText
    }).then((res) {
      print(res.data);
      List mats = res.data["cprs"];
      dataCount = res.data["count"];

      mats.forEach((element) {
        _cprList.add(CPR.fromJson(element));
      });
      final ids = _cprList.map((e) => e.id).toSet();
      _cprList.retainWhere((x) => ids.remove(x.id));

      setState(() {});
    }).whenComplete(() {
      requested = false;
    });
  }

  getColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.redAccent;
      case 'ready':
        return Colors.amber;
      case 'sent':
        return Colors.green;
    }
  }

  Future<void> showCPROptions(CPR cpr, BuildContext context1) async {
    print(cpr.toJson());
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 100,
          decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Column(children: [
                SizedBox(
                  height: 20,
                ),
                ListTile(
                    title: Text("Delete"),
                    leading: Icon(Icons.delete_forever_rounded, color: Colors.red),
                    onTap: () async {
                      // _cpr.materials.removeWhere((item) => item == material);
                      Navigator.of(context).pop();
                    }),
              ])
            ],
          ),
        );
      },
    );
  }

  _filterChip(key, String p, callBack) {
    return FilterChip(
        selectedColor: Colors.blue,
        checkmarkColor: Colors.white,
        label: Text(
          p,
          style: TextStyle(color: key == p ? Colors.white : Colors.black),
        ),
        selected: key == p,
        onSelected: (bool value) {
          callBack();
          setState(() {});
        });
  }

  _actionChip(String f, onDelete) {
    return Chip(
      deleteIcon: Icon(Icons.close, color: Colors.white),
      label: Text(
        f,
        style: TextStyle(color: Colors.white),
      ),
      onDeleted: () {
        onDelete();
        reloadData(0, reset: true);
        setState(() {});
      },
      backgroundColor: Colors.blue,
    );
  }
}
