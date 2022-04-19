import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/Web/V/AddSheet/add_sheet.dart';
import 'package:smartwind/Web/V/AddTicket/add_ticket.dart';
import 'package:smartwind/Web/V/ProductionPool/table.dart';

import '../../../M/Enums.dart';
import '../../../M/hive.dart';
import '../../../V/Home/Tickets/ProductionPool/TicketListOptions.dart';
import '../../../ns_icons_icons.dart';
import '../../Styles/styles.dart';

class WebProductionPool extends StatefulWidget {
  const WebProductionPool({Key? key}) : super(key: key);

  @override
  State<WebProductionPool> createState() => _WebProductionPoolState();
}

class _WebProductionPoolState extends State<WebProductionPool> {
  var _controller = TextEditingController();
  bool loading = false;
  DessertDataSource? _dataSource;
  String searchText = "";

  Production selectedProduction = Production.All;

  late DbChangeCallBack _dbChangeCallBack;

  get ticketCount => _dataSource == null ? 0 : _dataSource?.rowCount;

  @override
  void initState() {
    super.initState();

    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update tickets');
      if (mounted) {
        loadData();
      }
    }, context, collection: DataTables.Tickets);
  }

  @override
  void dispose() {
    _dbChangeCallBack.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Row(
              children: [
                Text("Production Pool", style: mainWidgetsTitleTextStyle),
                Spacer(),
                Wrap(children: [
                  flagIcon(Filters.crossPro, Icons.merge_type_rounded, "Filter by cross production"),
                  flagIcon(Filters.isError, Icons.warning_rounded, "Filter by Error Route"),
                  flagIcon(Filters.inPrint, Icons.print_rounded, "Filter by in print"),
                  flagIcon(Filters.isRush, Icons.offline_bolt_rounded, "Filter by rush"),
                  flagIcon(Filters.isRed, Icons.flag_rounded, "Filter by red flag"),
                  flagIcon(Filters.isHold, NsIcons.stop, "Filter by stop"),
                  flagIcon(Filters.isSk, NsIcons.sk, "Filter by SK"),
                  flagIcon(Filters.isGr, NsIcons.gr, "Filter by GR"),
                  flagIcon(Filters.isSort, NsIcons.short, "Filter by CPR"),
                  flagIcon(Filters.isQc, NsIcons.short, "Filter by QC", text: "QC"),
                  flagIcon(Filters.isQa, NsIcons.short, "Filter by QA", text: "QA"),
                  SizedBox(width: 50),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Production>(
                          value: selectedProduction,
                          selectedItemBuilder: (_) {
                            return Production.values.map<Widget>((Production item) {
                              return Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${item.getValue()}"),
                              ));
                            }).toList();
                          },
                          items: Production.values.map((Production value) {
                            return DropdownMenuItem<Production>(
                              value: value,
                              child: Text(value.getValue()),
                            );
                          }).toList(),
                          onChanged: (_) {
                            selectedProduction = _ ?? Production.All;
                            setState(() {});
                            loadData();
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                        height: 40,
                        width: 200,
                        child: TextFormField(
                          controller: _controller,
                          onChanged: (text) {
                            searchText = text;
                            loadData();
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search_rounded),
                              suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: _controller.clear),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 10, right: 15),
                              hintText: "Search Text"),
                        )),
                  ),
                ])
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: PaginatedDataTable2Demo(onInit: (DessertDataSource dataSource) {
                _dataSource = dataSource;
              })),
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
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          HiveBox.getDataFromServer(clean: true).then((value) => loadData());
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${ticketCount}",
                      textScaleFactor: 1.1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 36)
                ],
              ),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
        floatingActionButton: FloatingActionButton.small(
            onPressed: () async {
              addItemsBottomSheetMenu(context);
            },
            child: const Icon(Icons.add),
            backgroundColor: Colors.green));
  }

  Filters dataFilter = Filters.none;

  flagIcon(Filters filter, IconData? icon, tooltip, {String? text}) {
    return IconButton(
      icon: CircleAvatar(
          child: (text != null)
              ? Text(text, style: TextStyle(color: dataFilter == filter ? Colors.red : Colors.black, fontWeight: FontWeight.bold))
              : Icon(icon, color: dataFilter == filter ? Colors.red : Colors.black, size: 20),
          backgroundColor: Colors.white,
          radius: 16),
      tooltip: tooltip,
      onPressed: () async {
        dataFilter = dataFilter == filter ? Filters.none : filter;
        loadData();
        setState(() {});
      },
    );
  }

  void loadData() {
    print(dataFilter);
    var tickets = HiveBox.ticketBox.values.where((ticket) {
      return ((ticket.mo ?? "").toLowerCase().contains(searchText.toLowerCase())) && searchByFilters(ticket, dataFilter) && searchByProduction(ticket, selectedProduction);
    }).toList();
    _dataSource?.setData(tickets);
  }

  addItemsBottomSheetMenu(context) {
    showModalBottomSheet(
        constraints: kIsWeb ? BoxConstraints(maxWidth: 600) : null,
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
                Padding(padding: const EdgeInsets.all(16.0), child: Text("Add", textScaleFactor: 1.2)),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ListView(
                        children: [
                          ListTile(
                            title: Text("Add Tickets"),
                            selectedTileColor: Colors.black12,
                            leading: Icon(Icons.picture_as_pdf),
                            onTap: () {
                              Navigator.pop(context);
                              AddTicket().show(context);
                            },
                          ),
                          ListTile(
                            title: Text("Add Data Sheet"),
                            selectedTileColor: Colors.black12,
                            leading: Icon(Icons.list_alt_rounded),
                            onTap: () {
                              Navigator.pop(context);
                              AddSheet().show(context);
                            },
                          )
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }

  bool searchByProduction(Ticket ticket, Production selectedProduction) {
    // print('${ticket.production} === ${selectedProduction.getValue()}');
    if (selectedProduction == Production.None && (ticket.production == null || ticket.production == '')) {
      return true;
    }
    if (selectedProduction == Production.All) {
      return true;
    }
    if (selectedProduction.equalCaseInsensitive(ticket.production ?? "")) {
      return true;
    }

    return false;
  }
}
