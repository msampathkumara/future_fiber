import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/Web/V/Print/ticket_print_list.dart';

import '../../../M/Enums.dart';
import '../../../M/hive.dart';
import '../../../V/Home/Tickets/ProductionPool/TicketListOptions.dart';
import '../../../V/Home/Tickets/TicketInfo/TicketInfo.dart';
import '../../../V/Widgets/FlagDialog.dart';
import '../../../ns_icons_icons.dart';

class PaginatedDataTable2Demo extends StatefulWidget {
  final Null Function(DessertDataSource dataSource) onInit;

  const PaginatedDataTable2Demo({required this.onInit});

  @override
  _PaginatedDataTable2DemoState createState() => _PaginatedDataTable2DemoState();
}

class _PaginatedDataTable2DemoState extends State<PaginatedDataTable2Demo> {
  int _rowsPerPage = 20;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late DessertDataSource _dessertsDataSource;
  bool _initialized = false;
  PaginatorController? _controller;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _dessertsDataSource = DessertDataSource(context, (Ticket ticket) {
        return true;
      });

      _controller = PaginatorController();

      _sortColumnIndex = 1;

      _initialized = true;
      widget.onInit(_dessertsDataSource);
    }
  }

  void sort<T>(
    Comparable<T> Function(Ticket d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dessertsDataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  void dispose() {
    _dessertsDataSource.dispose();
    super.dispose();
  }

  List<DataColumn> get _columns {
    return [
      DataColumn2(
        size: ColumnSize.M,
        label: Text('Ticket'),
        onSort: (columnIndex, ascending) => sort<String>((d) => (d.mo ?? ""), columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: Text('Production'),
        onSort: (columnIndex, ascending) => sort<String>((d) => d.production ?? "", columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: Text('Progress'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort<num>((d) => d.progress, columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: Text('Shipping Date'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort<String>((d) => d.shipDate, columnIndex, ascending),
      ),
      DataColumn2(size: ColumnSize.L, label: Text('Status'), numeric: true),
      DataColumn2(numeric: true, size: ColumnSize.S, tooltip: "Options", label: Text('Options'))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      PaginatedDataTable2(
        smRatio: 0.5,
        lmRatio: 3,
        horizontalMargin: 20,
        checkboxHorizontalMargin: 12,
        columnSpacing: 16,
        wrapInCard: false,
        showFirstLastButtons: true,
        rowsPerPage: _rowsPerPage,
        autoRowsToHeight: false,
        minWidth: 800,
        fit: FlexFit.tight,
        showCheckboxColumn: false,
        border: TableBorder(
            top: BorderSide(color: Colors.transparent),
            bottom: BorderSide(color: Colors.grey[300]!),
            left: BorderSide(color: Colors.grey[300]!),
            right: BorderSide(color: Colors.grey[300]!),
            verticalInside: BorderSide(color: Colors.grey[200]!),
            horizontalInside: BorderSide(color: Colors.grey[300]!, width: 1)),
        onRowsPerPageChanged: (value) {
          _rowsPerPage = value!;
          print(_rowsPerPage);
        },
        initialFirstRowIndex: 0,
        onPageChanged: (rowIndex) {
          print(rowIndex / _rowsPerPage);
        },
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        controller: _controller,
        hidePaginator: false,
        columns: _columns,
        availableRowsPerPage: [20, 50, 100],
        empty: Center(child: Container(padding: EdgeInsets.all(20), color: Colors.grey[200], child: Text('No data'))),
        source: _dessertsDataSource,
      ),
      // Positioned(bottom: 16, child: CustomPager(_controller!))
    ]);
  }
}

class DessertDataSource extends DataTableSource {
  bool Function(Ticket ticket) filter;

  var searchString;

  DessertDataSource(this.context, this.filter) {
    tickets = _tickets;
    print("ddddddddd ${tickets.length}");
    // if (sortedByCalories) {
    //   sort((d) => d.mo, true);
    // }
  }

  final BuildContext context;
  late List<Ticket> tickets;
  late bool hasRowTaps = true;
  late bool hasRowHeightOverrides;

  void sort<T>(Comparable<T> Function(Ticket d) getField, bool ascending) {
    tickets.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    final format = NumberFormat.decimalPercentPattern(
      locale: 'en',
      decimalDigits: 0,
    );
    assert(index >= 0);
    if (index >= tickets.length) throw 'index > _tickets.length';
    final ticket = tickets[index];
    return DataRow2.byIndex(
      index: index,
      selected: false,
      onTap: () {
        var ticketInfo = TicketInfo(ticket);
        ticketInfo.show(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Tapped on ${ticket.mo}'),
        ));
      },
      onDoubleTap: hasRowTaps ? () => {ticket.open(context)} : null,
      onSecondaryTap: hasRowTaps
          ? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 1),
                backgroundColor: Theme.of(context).errorColor,
                content: Text('Right clicked on ${ticket.mo}'),
              ))
          : null,
      // specificRowHeight: this.hasRowHeightOverrides && ticket.fat >= 25 ? 100 : null,
      cells: [
        DataCell(Wrap(
          direction: Axis.vertical,
          children: [
            Text((ticket.mo ?? ticket.oe) ?? ""),
            Text((ticket.oe) ?? "", style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        )),
        DataCell(Wrap(
          direction: Axis.vertical,
          children: [
            Text('${ticket.production}'),
            Text('${ticket.atSection}', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        )),
        DataCell(Text("${ticket.progress}%")),
        DataCell(Text(ticket.shipDate.toString())),
        DataCell(Wrap(
          children: [
            if (ticket.isQc == 1)
              IconButton(
                icon: CircleAvatar(backgroundColor: Colors.red, radius: 8, child: const Text('QC', style: TextStyle(fontSize: 8, color: Colors.white))),
                onPressed: () {
                  // TicketPrintList(ticket).show(context);
                },
              ),
            if (ticket.isQa == 1)
              IconButton(
                icon: CircleAvatar(backgroundColor: Colors.deepOrangeAccent, radius: 8, child: const Text('QA', style: TextStyle(fontSize: 8, color: Colors.white))),
                onPressed: () {
                  // TicketPrintList(ticket).show(context);
                },
              ),
            if (ticket.inPrint == 1)
              IconButton(
                icon: CircleAvatar(child: Icon(Icons.print_rounded, color: Colors.deepOrangeAccent), backgroundColor: Colors.white),
                onPressed: () {
                  TicketPrintList(ticket).show(context);
                },
              ),
            if (ticket.isHold == 1)
              IconButton(
                icon: CircleAvatar(child: Icon(NsIcons.stop, color: Colors.black), backgroundColor: Colors.white),
                onPressed: () {
                  FlagDialog().showFlagView(context, ticket, TicketFlagTypes.HOLD);
                },
              ),
            if (ticket.isGr == 1)
              IconButton(
                icon: CircleAvatar(child: Icon(NsIcons.gr, color: Colors.blue), backgroundColor: Colors.white),
                onPressed: () {
                  FlagDialog().showFlagView(context, ticket, TicketFlagTypes.GR);
                },
              ),
            if (ticket.isSk == 1)
              IconButton(
                icon: CircleAvatar(child: Icon(NsIcons.sk, color: Colors.pink), backgroundColor: Colors.white),
                onPressed: () {},
              ),
            if (ticket.isError == 1) IconButton(icon: CircleAvatar(child: Icon(Icons.report_problem_rounded, color: Colors.red), backgroundColor: Colors.white), onPressed: () {}),
            if (ticket.isSort == 1) IconButton(icon: CircleAvatar(child: Icon(Icons.local_mall_rounded, color: Colors.green), backgroundColor: Colors.white), onPressed: () {}),
            if (ticket.isRush == 1)
              IconButton(
                  icon: CircleAvatar(child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent), backgroundColor: Colors.white),
                  onPressed: () {
                    FlagDialog().showFlagView(context, ticket, TicketFlagTypes.RUSH);
                  }),
            if (ticket.isRed == 1)
              IconButton(
                icon: CircleAvatar(child: Icon(Icons.tour_rounded, color: Colors.red), backgroundColor: Colors.white),
                onPressed: () {
                  FlagDialog().showFlagView(context, ticket, TicketFlagTypes.RED);
                },
              )
          ],
        )),
        DataCell(IconButton(
          icon: Icon(Icons.more_vert_rounded),
          onPressed: () {
            showTicketOptions(ticket, context, context);
          },
        ))
      ],
    );
  }

  @override
  int get rowCount => tickets.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  search(String text) {
    tickets = HiveBox.ticketBox.values.where((element) => (element.mo ?? "").toLowerCase().contains(text.toLowerCase())).toList();
    print(tickets.length);
    notifyListeners();
  }

  void setData(List<Ticket> _tickets) {
    tickets = _tickets;
    notifyListeners();
  }
}

List<Ticket> _tickets = HiveBox.ticketBox.values.toList();
