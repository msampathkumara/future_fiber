import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';

import '../../../C/DB/hive.dart';
import '../../../M/Enums.dart';
import '../../../Mobile/V/Home/Tickets/ProductionPool/FlagDialog.dart';
import '../../../Mobile/V/Home/Tickets/ProductionPool/TicketListOptions.dart';
import '../../../Mobile/V/Home/Tickets/TicketInfo/TicketChatView.dart';
import '../../../Mobile/V/Home/Tickets/TicketInfo/TicketInfo.dart';
import '../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../../../ns_icons_icons.dart';
import '../QC/webTicketQView.dart';
import 'copy.dart';

class PaginatedDataTable2Demo extends StatefulWidget {
  final Null Function(DessertDataSource dataSource) onInit;

  const PaginatedDataTable2Demo({Key? key, required this.onInit}) : super(key: key);

  @override
  _PaginatedDataTable2DemoState createState() => _PaginatedDataTable2DemoState();
}

class _PaginatedDataTable2DemoState extends State<PaginatedDataTable2Demo> {
  int _rowsPerPage = 20;
  bool _sortAscending = true;
  int _sortColumnIndex = 4;
  late DessertDataSource _dessertsDataSource;
  bool _initialized = false;
  PaginatorController? _controller;

  final ScrollController _scrollController = ScrollController();

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

      _initialized = true;
      widget.onInit(_dessertsDataSource);
    }
  }

  void sort<T>(Comparable<T> Function(Ticket d) getField, int columnIndex, bool ascending) {
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
          label: const Text('Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: (columnIndex, ascending) => sort<String>((d) => (d.mo ?? ""), columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Production', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: (columnIndex, ascending) => sort<String>((d) => d.production ?? "", columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Job ID', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: (columnIndex, ascending) => sort<String>((d) => d.jobId ?? "", columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.S,
          label: const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort<num>((d) => d.progress, columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Delivery Date', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort<String>((d) => d.deliveryDate, columnIndex, ascending)),
      const DataColumn2(size: ColumnSize.S, label: Text('Kit/CPR', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
      const DataColumn2(size: ColumnSize.L, label: Text('Product Notifications', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
      const DataColumn2(numeric: true, size: ColumnSize.S, tooltip: "Options", label: Text('Options', style: TextStyle(fontWeight: FontWeight.bold)))
    ];
  }

  GlobalKey menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(key: menuKey, alignment: Alignment.bottomCenter, children: [
      PaginatedDataTable2(
          scrollController: _scrollController,
          smRatio: 0.7,
          lmRatio: 2.4,
          horizontalMargin: 20,
          checkboxHorizontalMargin: 12,
          columnSpacing: 16,
          wrapInCard: false,
          showFirstLastButtons: true,
          rowsPerPage: _rowsPerPage,
          autoRowsToHeight: false,
          minWidth: 1220,
          fit: FlexFit.tight,
          showCheckboxColumn: false,
          border: TableBorder(
              top: const BorderSide(color: Colors.transparent),
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
          availableRowsPerPage: const [20, 50, 100],
          empty: Center(child: Container(padding: const EdgeInsets.all(20), child: const NoResultFoundMsg())),
          source: _dessertsDataSource)
      // Positioned(bottom: 16, child: CustomPager(_controller!))
      ,
    ]);
  }
}

class DessertDataSource extends DataTableSource {
  bool Function(Ticket ticket) filter;

  String? searchString;

  var sts = const TextStyle(color: Colors.redAccent, fontSize: 12);

  DessertDataSource(this.context, this.filter) {
    tickets = _tickets;
    sort((d) => d.deliveryDate, true);
  }

  final BuildContext context;
  late List<Ticket> tickets;
  late bool hasRowTaps = true;
  late bool hasRowHeightOverrides;

  Comparable Function(Ticket d) sortField = ((d) => (d.deliveryDate));
  var _ascending = false;

  void sort<T>(Comparable<T> Function(Ticket d) getField, bool ascending) {
    sortField = getField;
    _ascending = ascending;
    tickets.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  final int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= tickets.length) throw 'index > _tickets.length';
    final ticket = tickets[index];
    var e = ticket.getKitReport();
    return DataRow2.byIndex(
      index: index,
      selected: false,
      onTap: () => {TicketInfo(ticket).show(context)},
      onDoubleTap: hasRowTaps
          ? () {
              if (ticket.hasFile) {
                if (ticket.isHold == 0) {
                  Ticket.open(context, ticket);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Theme.of(context).colorScheme.error, content: const Text('No file')));
              }
            }
          : null,
      onSecondaryTap: null,
      // specificRowHeight: this.hasRowHeightOverrides && ticket.fat >= 25 ? 100 : null,
      cells: [
        DataCell(Wrap(
          direction: Axis.vertical,
          children: [TextMenu(child: Text((ticket.mo ?? ticket.oe) ?? "")), TextMenu(child: Text((ticket.oe) ?? "", style: const TextStyle(color: Colors.red, fontSize: 12)))],
        )),
        DataCell(Wrap(
            direction: Axis.vertical,
            children: [Text(ticket.production ?? '-'), if (ticket.atSection != null) Text(ticket.atSection ?? '', style: const TextStyle(color: Colors.red, fontSize: 12))])),
        DataCell(Text("${ticket.jobId}")),
        DataCell(Text("${ticket.progress}%")),
        DataCell(Text(ticket.deliveryDate.toString())),
        DataCell(Wrap(
          children: [
            ticket.haveKit == 1 && e != null
                ? JustTheTooltip(
                    content: SizedBox(
                        width: 150,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(children: [
                              Icon(Icons.circle, color: e.status?.getColor(), size: 8),
                              const SizedBox(width: 4),
                              Text("${e.status}"),
                              const Spacer(),
                              Text("${e.count}"),
                              const Spacer(),
                              Text("${e.itemCount}")
                            ]))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(e.itemCount > 0 ? Icons.inventory : Icons.view_in_ar_rounded, color: e.status?.getColor() ?? Colors.grey),
                    ))
                : const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.view_in_ar_outlined, color: Colors.grey)),
            ticket.haveCpr == 1
                ? JustTheTooltip(
                    content: SizedBox(
                      width: 150,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                              children: ticket
                                  .getCprReport()
                                  .map((e) => Row(children: [
                                        Icon(Icons.circle, color: e.status?.getColor(), size: 8),
                                        const SizedBox(width: 4),
                                        Text("${e.status}"),
                                        const Spacer(),
                                        Text("${e.count}")
                                      ]))
                                  .toList())),
                    ),
                    child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.local_mall_rounded, color: Colors.red)))
                : const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.local_mall_outlined, color: Colors.grey)),
          ],
        )),
        DataCell(Row(
          children: [
            IconButton(
                icon: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.chat, color: ticket.haveComments ? Colors.blue : Colors.grey)),
                onPressed: () {
                  TicketChatView(ticket).show(context);
                }),
            if (ticket.file == 1) IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.picture_as_pdf, color: Colors.red)), onPressed: () {}),
            if (ticket.isQa == 1)
              IconButton(
                  icon: const CircleAvatar(backgroundColor: Colors.deepOrangeAccent, radius: 8, child: Text('QA', style: TextStyle(fontSize: 8, color: Colors.white))),
                  onPressed: () => {WebTicketQView(ticket, false).show(context)}),
            if (ticket.isQc == 1)
              IconButton(
                  icon: const CircleAvatar(backgroundColor: Colors.red, radius: 8, child: Text('QC', style: TextStyle(fontSize: 8, color: Colors.white))),
                  onPressed: () => {WebTicketQView(ticket, true).show(context)}),
            const Spacer(),
            if (ticket.isHold == 1)
              IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.stop, color: Colors.black)),
                onPressed: () => {FlagDialogNew(ticket, TicketFlagTypes.HOLD, editable: false).show(context)},
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
            if (ticket.isRush == 1)
              IconButton(
                  icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent)),
                  onPressed: () => {FlagDialogNew(ticket, TicketFlagTypes.RUSH, editable: false).show(context)}),
            if (ticket.isRed == 1)
              IconButton(
                  icon: CircleAvatar(backgroundColor: Colors.white, child: Icon(TicketFlagTypes.RED.getIcon(), color: TicketFlagTypes.RED.getColor())),
                  onPressed: () => {FlagDialogNew(ticket, TicketFlagTypes.RED, editable: false).show(context)}),
            if (ticket.isYellow == 1)
              IconButton(
                  icon: CircleAvatar(backgroundColor: Colors.white, child: Icon(TicketFlagTypes.YELLOW.getIcon(), color: TicketFlagTypes.YELLOW.getColor())),
                  onPressed: () => {FlagDialogNew(ticket, TicketFlagTypes.YELLOW, editable: false).show(context)})
          ],
        )),
        DataCell(IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => {
                  showTicketOptions(ticket, context, context, loadData: () => {notifyListeners()})
                }))
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
    setData(HiveBox.ticketBox.values.where((element) => (element.mo ?? "").toLowerCase().contains(text.toLowerCase())).toList());
    print(tickets.length);
  }

  void setData(List<Ticket> _tickets) {
    tickets = _tickets;
    sort(sortField, _ascending);
    print("DATA SETED");
  }

  MaterialColor getColor(int i) {
    return [Colors.grey, Colors.green, Colors.red][i];
  }
}

List<Ticket> _tickets = HiveBox.ticketBox.values.toList();
