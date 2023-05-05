import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/C/DB/DB.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';
import 'package:smartwind_future_fibers/Mobile/V/Widgets/SearchBar.dart';
import 'package:smartwind_future_fibers/Web/V/AddTicket/add_ticket.dart';
import 'package:smartwind_future_fibers/Web/V/ProductionPool/webProductionPool.table.dart';
import 'package:smartwind_future_fibers/Web/V/SheetData/add_sheet.dart';

import '../../../C/DB/hive.dart';
import '../../../M/AppUser.dart';
import '../../../M/Enums.dart';
import '../../../M/PermissionsEnum.dart';
import '../../../Mobile/V/Home/Tickets/ProductionPool/TicketListOptions.dart';
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

  bool filterByFiles = false;
  bool filterByNoFiles = false;
  bool filterByStart = false;

  int? get ticketCount => _dataSource == null ? 0 : _dataSource?.rowCount;

  @override
  void initState() {
    super.initState();

    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update tickets');
      if (mounted) {
        loadData();
      }
    }, context, collection: DataTables.tickets);
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
                  // flagIcon(Filters.isCrossPro, Icons.merge_type_rounded, "Filter by cross production"),
                  flagIcon(Filters.isError, Icons.sim_card_rounded, "Files", checked: filterByFiles, onPressed: () {
                    filterByFiles = !filterByFiles;
                    filterByNoFiles = false;
                    loadData();
                    setState(() {});
                  }),
                  flagIcon(Filters.isError, Icons.no_sim_rounded, "No Files", checked: filterByNoFiles, onPressed: () {
                    filterByNoFiles = !filterByNoFiles;
                    filterByFiles = false;
                    loadData();
                    setState(() {});
                  }),
                  flagIcon(Filters.isError, Icons.play_arrow, "Filter By Start", checked: filterByStart, onPressed: () {
                    filterByStart = !filterByStart;
                    loadData();
                    setState(() {});
                  }),
                  Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 1, color: Colors.red, height: 24)),
                  flagIcon(Filters.isError, Icons.warning_rounded, "Filter by Error Route"),
                  // flagIcon(Filters.inPrint, Icons.print_rounded, "Filter by in print"),
                  flagIcon(Filters.isRush, Icons.offline_bolt_rounded, "Filter by rush"),
                  flagIcon(Filters.isRed, Icons.flag_rounded, "Filter by red flag"),
                  flagIcon(Filters.isHold, NsIcons.stop, "Filter by stop"),
                  flagIcon(Filters.isSk, NsIcons.sk, "Filter by SK"),
                  flagIcon(Filters.isGr, NsIcons.gr, "Filter by GR"),
                  flagIcon(Filters.haveKit, Icons.view_in_ar_rounded, "Filter by Kit"),
                  flagIcon(Filters.haveCpr, NsIcons.short, "Filter by CPR"),
                  flagIcon(Filters.isQc, NsIcons.short, "Filter by QC", text: "QC"),
                  flagIcon(Filters.isQa, NsIcons.short, "Filter by QA", text: "QA"),
                  Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 1, color: Colors.red, height: 24)),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PopupMenuButton<Production>(
                          offset: const Offset(0, 30),
                          padding: const EdgeInsets.all(16.0),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          child: Chip(
                              avatar: const Icon(Icons.factory, color: Colors.black),
                              label: Row(children: [Text(selectedProduction.getValue()), const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)])),
                          onSelected: (result) {},
                          itemBuilder: (BuildContext context) {
                            return Production.values.map((Production value) {
                              return PopupMenuItem<Production>(
                                  value: value,
                                  onTap: () {
                                    selectedProduction = value;
                                    setState(() {});
                                    loadData();
                                  },
                                  child: Text(value.getValue()));
                            }).toList();
                          })),

                  const SizedBox(width: 20),
                  Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                          height: 40,
                          width: 250,
                          child: SearchBar(onSearchTextChanged: (String text) => {searchText = text, loadData()}, delay: 300, searchController: _controller))),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.small(
              onPressed: () async {
                addItemsBottomSheetMenu(context);
              },
              // backgroundColor: Colors.green,
              child: const Icon(Icons.add)),
        ));
  }

  Filters dataFilter = Filters.none;

  IconButton flagIcon(Filters filter, IconData? icon, tooltip, {String? text, Function? onPressed, bool? checked, IconData? icon2}) {
    checked = checked ?? dataFilter == filter;

    return IconButton(
      icon: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 16,
          child: (text != null)
              ? Text(text, style: TextStyle(color: checked ? Colors.red : Colors.black, fontWeight: FontWeight.bold))
              : Stack(
                  children: [
                    Icon(icon, color: checked ? Colors.red : Colors.black, size: 20),
                    Icon(icon2, color: checked ? Colors.red : Colors.black, size: 20),
                  ],
                )),
      tooltip: tooltip,
      onPressed: () async {
        if (onPressed != null) {
          onPressed();
          return;
        }

        dataFilter = dataFilter == filter ? Filters.none : filter;
        loadData();
        setState(() {});
      },
    );
  }

  void loadData() {
    print(dataFilter);
    var tickets = HiveBox.ticketBox.values.where((ticket) {
      return (filterByStart ? ticket.isStarted : true) &&
          (filterByFiles ? ticket.hasFile : true) &&
          (filterByNoFiles ? ticket.hasNoFile : true) &&
          searchText.containsInArrayIgnoreCase([ticket.mo, ticket.oe]) &&
          searchByFilters(ticket, dataFilter) &&
          searchByProduction(ticket, selectedProduction);
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
              child: Column(children: [
                const Padding(padding: EdgeInsets.all(16.0), child: Text("Add", textScaleFactor: 1.2)),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: ListView(children: [
                          if (AppUser.havePermissionFor(NsPermissions.TICKET_UPLOAD_TICKET))
                            ListTile(
                              title: const Text("Add Tickets"),
                              selectedTileColor: Colors.black12,
                              leading: const Icon(Icons.picture_as_pdf),
                              onTap: () {
                                Navigator.pop(context);
                                const AddTickets().show(context);
                              },
                            ),
                          if (AppUser.havePermissionFor(NsPermissions.SHEET_ADD_DATA_SHEET))
                            ListTile(
                              title: const Text("Add Data Sheet"),
                              selectedTileColor: Colors.black12,
                              leading: const Icon(Icons.list_alt_rounded),
                              onTap: () {
                                Navigator.pop(context);
                                const AddSheet().show(context);
                              },
                            ),
                          if (AppUser.havePermissionFor(NsPermissions.SHEET_ADD_UPDATED_DATA_SHEET))
                            ListTile(
                                title: const Text("Add Updated Data Sheet", style: TextStyle(color: Colors.red)),
                                selectedTileColor: Colors.black12,
                                leading: const Icon(Icons.list_alt_rounded),
                                onTap: () {
                                  Navigator.pop(context);
                                  const AddSheet(isUpdate: true).show(context);
                                })
                        ])))
              ]));
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
