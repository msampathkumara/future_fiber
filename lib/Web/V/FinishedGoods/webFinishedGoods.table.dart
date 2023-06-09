import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';

import '../../../Mobile/V/Home/Tickets/ProductionPool/FlagDialog.dart';
import '../../../Mobile/V/Home/Tickets/TicketInfo/TicketChatView.dart';
import '../../../Mobile/V/Home/Tickets/TicketInfo/TicketInfo.dart';
import '../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../../../ns_icons_icons.dart';
import '../ProductionPool/copy.dart';
import '../QC/webTicketQView.dart';

class AsyncPaginatedDataTable2Demo extends StatefulWidget {
  final Null Function(DessertDataSourceAsync dataSource) onInit;
  final Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;

  const AsyncPaginatedDataTable2Demo({super.key, required this.onInit, required this.onRequestData});

  @override
  _AsyncPaginatedDataTable2DemoState createState() => _AsyncPaginatedDataTable2DemoState();
}

class _AsyncPaginatedDataTable2DemoState extends State<AsyncPaginatedDataTable2Demo> {
  int _rowsPerPage = 20;
  bool _sortAscending = true;
  int _sortColumnIndex = 5;
  DessertDataSourceAsync? _dessertsDataSource;
  final PaginatorController _controller = PaginatorController();

  final bool _dataSourceLoading = false;
  final int _initialRow = 0;

  @override
  void didChangeDependencies() {
    // initState is to early to access route options, context is invalid at that stage
    _dessertsDataSource ??= DessertDataSourceAsync(context, onRequestData: widget.onRequestData);

    widget.onInit(_dessertsDataSource!);

    super.didChangeDependencies();
  }

  void sort(int columnIndex, bool ascending) {
    String columnName = ["mo", "jobId", "production", "progress", "shipDate", '', 'completedOn'].elementAt(columnIndex);

    _dessertsDataSource!.sort(columnName, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  void dispose() {
    _dessertsDataSource!.dispose();
    super.dispose();
  }

  List<DataColumn> get _columns {
    return [
      DataColumn2(size: ColumnSize.M, label: const Text('Ticket', style: TextStyle(fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Job ID', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M, label: const Text('Production', style: TextStyle(fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Shipping Date', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      const DataColumn2(size: ColumnSize.L, label: Text('Product Notifications', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
      DataColumn2(
          numeric: true,
          size: ColumnSize.M,
          tooltip: "Finished on",
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
          label: const Text('Finished On', style: TextStyle(fontWeight: FontWeight.bold)))
    ];
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Last ppage example uses extra API call to get the number of items in datasource
    if (_dataSourceLoading) return const SizedBox();

    return Stack(alignment: Alignment.bottomCenter, children: [
      AsyncPaginatedDataTable2(
          scrollController: _scrollController,
          showFirstLastButtons: true,
          smRatio: 0.4,
          lmRatio: 3,
          horizontalMargin: 20,
          checkboxHorizontalMargin: 12,
          columnSpacing: 16,
          rowsPerPage: _rowsPerPage,
          autoRowsToHeight: false,
          availableRowsPerPage: const [20, 50, 100, 200],
          wrapInCard: false,
          pageSyncApproach: PageSyncApproach.goToFirst,
          minWidth: 800,
          fit: FlexFit.tight,
          border: TableBorder(
              top: const BorderSide(color: Colors.transparent),
              bottom: BorderSide(color: Colors.grey[300]!),
              left: BorderSide(color: Colors.grey[300]!),
              right: BorderSide(color: Colors.grey[300]!),
              verticalInside: BorderSide(color: Colors.grey[200]!),
              horizontalInside: BorderSide(color: Colors.grey[300]!, width: 1)),
          onRowsPerPageChanged: (value) {
            // No need to wrap into setState, it will be called inside the widget
            // and trigger rebuild
            //setState(() {
            print('Row per page changed to $value');
            _rowsPerPage = value!;
            //});
          },
          initialFirstRowIndex: _initialRow,
          onPageChanged: (rowIndex) {
            print("$rowIndex${_rowsPerPage}xxxxxxxx =${rowIndex / _rowsPerPage}");
          },
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          controller: _controller,
          hidePaginator: false,
          columns: _columns,
          empty: Center(child: Container(padding: const EdgeInsets.all(20), child: const NoResultFoundMsg())),
          loading: _Loading(),
          errorBuilder: (e) => _ErrorAndRetry(e.toString(), () => _dessertsDataSource!.refreshDatasource()),
          source: _dessertsDataSource!),
    ]);
  }
}

class _ErrorAndRetry extends StatelessWidget {
  const _ErrorAndRetry(this.errorMessage, this.retry);

  final String errorMessage;
  final void Function() retry;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
            padding: const EdgeInsets.all(10),
            height: 170,
            color: Colors.red,
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Oops! $errorMessage', style: const TextStyle(color: Colors.white)),
              TextButton(
                  onPressed: retry,
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.refresh, color: Colors.white), Text('Retry', style: TextStyle(color: Colors.white))]))
            ])),
      );
}

class _Loading extends StatefulWidget {
  @override
  __LoadingState createState() => __LoadingState();
}

class __LoadingState extends State<_Loading> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: Colors.white.withAlpha(128),
        // at first show shade, if loading takes longer than 0,5s show spinner
        child: FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 500), () => true),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? const SizedBox()
                  : Center(
                      child: Container(
                        color: Colors.yellow,
                      padding: const EdgeInsets.all(7),
                      width: 150,
                      height: 50,
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround, children: [CircularProgressIndicator(strokeWidth: 2, color: Colors.black), Text('Loading..')]),
                    ));
            }));
  }
}

class DessertDataSourceAsync extends AsyncDataTableSource {
  Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;

  DessertDataSourceAsync(this.context, {required this.onRequestData}) {
    print('DessertDataSourceAsync created');
  }

  final BuildContext context;
  final bool _empty = false;
  int? _errorCounter;

  RangeValues? _caloriesFilter;

  RangeValues? get caloriesFilter => _caloriesFilter;

  set caloriesFilter(RangeValues? calories) {
    _caloriesFilter = calories;
    refreshDatasource();
  }

  // final DesertsFakeWebService _repo = DesertsFakeWebService();

  String _sortColumn = "completedOn";
  bool _sortAscending = false;

  void sort(String columnName, bool ascending) {
    _sortColumn = columnName;
    _sortAscending = ascending;
    refreshDatasource();
  }

  @override
  Future<AsyncRowsResponse> getRows(int start, int end) async {
    print('getRows($start, $end)');
    if (_errorCounter != null) {
      _errorCounter = _errorCounter! + 1;

      if (_errorCounter! % 2 == 1) {
        await Future.delayed(const Duration(milliseconds: 1000));
        throw 'Error #${((_errorCounter! - 1) / 2).round() + 1} has occured';
      }
    }

    var index = start;

    assert(index >= 0);

    // List returned will be empty is there're fewer items than startingAt
    var x = _empty
        ? await Future.delayed(const Duration(milliseconds: 2000), () => DataResponse(0, []))
        : await onRequestData(int.parse("${start / end}"), start, end, _sortColumn, _sortAscending);

    var r = AsyncRowsResponse(
        x.totalRecords,
        x.data.map((ticket) {
          return DataRow2(
            selected: false,
            onTap: () {
              var ticketInfo = TicketInfo(ticket);
              ticketInfo.show(context);
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //   duration: const Duration(seconds: 1),
              //   content: Text('Tapped on ${ticket.mo}'),
              // ));
            },

            // onSecondaryTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   duration: const Duration(seconds: 1),
            //   backgroundColor: Theme.of(context).errorColor,
            //   content: Text('Right clicked on ${ticket.mo}'),
            // )),
            // specificRowHeight: this.hasRowHeightOverrides && ticket.fat >= 25 ? 100 : null,
            cells: [
              DataCell(Wrap(
                direction: Axis.vertical,
                children: [
                  TextMenu(child: Text((ticket.mo ?? ticket.oe) ?? "")),
                  TextMenu(child: Text((ticket.oe) ?? "", style: const TextStyle(color: Colors.red, fontSize: 12))),
                ],
              )),
              DataCell(Text("${ticket.jobId}")),
              DataCell(Wrap(
                direction: Axis.vertical,
                children: [Text(ticket.production ?? '-'), if (ticket.atSection != null) Text(ticket.atSection ?? '', style: const TextStyle(color: Colors.red, fontSize: 12))],
              )),
              DataCell(Text("${ticket.progress}%")),
              DataCell(Text(ticket.shipDate.toString())),
              DataCell(Row(
                children: [
                  IconButton(
                      icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.chat, color: Colors.blue)),
                      onPressed: () => {TicketChatView(ticket).show(context)}),
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
                        onPressed: () => {FlagDialogNew(ticket, TicketFlagTypes.HOLD, editable: false).show(context)}),
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
                  if (ticket.haveCpr == 1)
                    IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.local_mall_rounded, color: Colors.green)), onPressed: () {}),
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
              DataCell(Text(ticket.completedOn ?? '-'))
            ],
          );
        }).toList());

    return r;
  }
}

class DataResponse {
  DataResponse(this.totalRecords, this.data);

  final int totalRecords;
  final List<Ticket> data;
}
