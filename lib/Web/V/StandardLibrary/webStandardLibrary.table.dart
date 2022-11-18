import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/StandardTicket.dart';

import '../../../Mobile/V/Home/Tickets/StandardFiles/StandardFiles.dart';
import '../../../Mobile/V/Home/Tickets/StandardFiles/StandardTicketInfo.dart';
import '../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../ProductionPool/copy.dart';

class WebStandardLibraryTable extends StatefulWidget {
  final Null Function(DessertDataSourceAsync dataSource) onInit;
  final Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;

  const WebStandardLibraryTable({super.key, required this.onInit, required this.onRequestData});

  @override
  _WebStandardLibraryTableState createState() => _WebStandardLibraryTableState();
}

class _WebStandardLibraryTableState extends State<WebStandardLibraryTable> {
  int _rowsPerPage = 20;
  bool _sortAscending = true;
  int? _sortColumnIndex;
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

  void sort(
    int columnIndex,
    bool ascending,
  ) {
    var columnName = "oe";
    switch (columnIndex) {
      case 1:
        columnName = "production";
        break;
      case 2:
        columnName = "usedCount";
        break;
      case 3:
        columnName = "uptime";
        break;
    }
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
      DataColumn2(
        size: ColumnSize.M,
        label: const Text('Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: const Text('Production', style: TextStyle(fontWeight: FontWeight.bold)),
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: const Text('Usage', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: const Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      const DataColumn2(numeric: true, size: ColumnSize.S, tooltip: "Options", label: Text('Options', style: TextStyle(fontWeight: FontWeight.bold)))
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
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.refresh, color: Colors.white), Text('Retry', style: TextStyle(color: Colors.white))]))
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
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                        Text('Loading..')
                      ]),
                    ));
            }));
  }
}

class DessertDataSourceAsync extends AsyncDataTableSource {
  Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;

  DessertDataSourceAsync(this.context, {required this.onRequestData}) {
    print('DessertDataSourceAsync created');
  }

  // DessertDataSourceAsync.empty() {
  //   _empty = true;
  //   print('DessertDataSourceAsync.empty created');
  // }
  //
  // DessertDataSourceAsync.error() {
  //   _errorCounter = 0;
  //   print('DessertDataSourceAsync.error created');
  // }
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

  String _sortColumn = "name";
  bool _sortAscending = true;

  void sort(String columnName, bool ascending) {
    _sortColumn = columnName;
    _sortAscending = ascending;
    refreshDatasource();
  }

  // Future<int> getTotalRecords() {
  //   return Future<int>.delayed(Duration(milliseconds: 0), () => _empty ? 0 : _dessertsX3.length);
  // }

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
              StandardTicketInfo(ticket).show(context);

              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //   duration: const Duration(seconds: 1),
              //   content: Text('Tapped on ${ticket.oe}'),
              // ));
            },

            // onSecondaryTap: () => ScaffoldMessenger.of(context)
            //     .showSnackBar(SnackBar(duration: const Duration(seconds: 1), backgroundColor: Theme.of(context).errorColor, content: Text('Right clicked on ${ticket.oe}'))),
            // specificRowHeight: this.hasRowHeightOverrides && ticket.fat >= 25 ? 100 : null,
            cells: [
              DataCell(TextMenu(child: Text((ticket.oe) ?? ""))),
              DataCell(Text('${ticket.production}')),
              DataCell(Text("${ticket.usedCount}")),
              DataCell(Text(ticket.getUpdateDateTime().toString())),
              DataCell(IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () {
                  showStandardTicketOptions(ticket, context);
                },
              ))
            ],
          );
        }).toList());

    return r;
  }
}

class DataResponse {
  DataResponse(this.totalRecords, this.data);

  final int totalRecords;
  final List<StandardTicket> data;
}
