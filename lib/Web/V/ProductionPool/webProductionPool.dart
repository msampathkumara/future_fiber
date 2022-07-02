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
  final _controller = TextEditingController();
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
                const Spacer(),
                Wrap(children: [
                  flagIcon(Filters.isCrossPro, Icons.merge_type_rounded, "Filter by cross production"),
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
                  const SizedBox(width: 50),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 40,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Production>(
                          value: selectedProduction,
                          selectedItemBuilder: (_) {
                            return Production.values.map<Widget>((Production item) {
                              return Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(item.getValue())));
                            }).toList();
                          },
                          items: Production.values.map((Production value) {
                            return DropdownMenuItem<Production>(value: value, child: Text(value.getValue()));
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
                  const SizedBox(width: 20),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
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
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: _controller.clear),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 15, bottom: 11, top: 10, right: 15),
                              hintText: "Search Text"),
                        )),
                  ),
                ])
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0),
        body: Padding(
            padding: const EdgeInsets.only(bottom: 16.0, right: 16),
            child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: PaginatedDataTable2Demo(onInit: (DessertDataSource dataSource) {
                  _dataSource = dataSource;
                }))),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartDocked,
        floatingActionButton: FloatingActionButton.small(
            onPressed: () async {
              addItemsBottomSheetMenu(context);
            },
            // backgroundColor: Colors.green,
            child: const Icon(Icons.add)));
  }

  Filters dataFilter = Filters.none;

  flagIcon(Filters filter, IconData? icon, tooltip, {String? text}) {
    return IconButton(
      icon: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 16,
          child: (text != null)
              ? Text(text, style: TextStyle(color: dataFilter == filter ? Colors.red : Colors.black, fontWeight: FontWeight.bold))
              : Icon(icon, color: dataFilter == filter ? Colors.red : Colors.black, size: 20)),
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
      return searchText.containsInArrayIgnoreCase([ticket.mo, ticket.oe]) && searchByFilters(ticket, dataFilter) && searchByProduction(ticket, selectedProduction);
    }).toList();
    _dataSource?.setData(tickets);
  }

  addItemsBottomSheetMenu(context) {
    showModalBottomSheet(
        constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
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
                const Padding(padding: EdgeInsets.all(16.0), child: Text("Add", textScaleFactor: 1.2)),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ListView(
                        children: [
                          ListTile(
                            title: const Text("Add Tickets"),
                            selectedTileColor: Colors.black12,
                            leading: const Icon(Icons.picture_as_pdf),
                            onTap: () {
                              Navigator.pop(context);
                              const AddTicket().show(context);
                            },
                          ),
                          ListTile(
                            title: const Text("Add Data Sheet"),
                            selectedTileColor: Colors.black12,
                            leading: const Icon(Icons.list_alt_rounded),
                            onTap: () {
                              Navigator.pop(context);
                              const AddSheet().show(context);
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
