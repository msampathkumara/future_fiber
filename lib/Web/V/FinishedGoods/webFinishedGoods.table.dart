import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/Ticket.dart';

import '../../../V/Home/Tickets/ProductionPool/TicketListOptions.dart';
import '../../../V/Home/Tickets/TicketInfo/TicketInfo.dart';
import '../../../V/Widgets/FlagDialog.dart';
import '../../../ns_icons_icons.dart';

class AsyncPaginatedDataTable2Demo extends StatefulWidget {
  final Null Function(DessertDataSourceAsync dataSource) onInit;
  final Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;

  const AsyncPaginatedDataTable2Demo({required this.onInit, required this.onRequestData});

  @override
  _AsyncPaginatedDataTable2DemoState createState() => _AsyncPaginatedDataTable2DemoState();
}

class _AsyncPaginatedDataTable2DemoState extends State<AsyncPaginatedDataTable2Demo> {
  int _rowsPerPage = 20;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  DessertDataSourceAsync? _dessertsDataSource;
  PaginatorController _controller = PaginatorController();

  bool _dataSourceLoading = false;
  int _initialRow = 0;

  @override
  void didChangeDependencies() {
    // initState is to early to access route options, context is invalid at that stage
    if (_dessertsDataSource == null) {
      _dessertsDataSource = DessertDataSourceAsync(context, onRequestData: widget.onRequestData);
    }

    widget.onInit(_dessertsDataSource!);

    super.didChangeDependencies();
  }

  void sort(
    int columnIndex,
    bool ascending,
  ) {
    var columnName = "mo";
    switch (columnIndex) {
      case 1:
        columnName = "production";
        break;
      case 2:
        columnName = "progress";
        break;
      case 3:
        columnName = "shipDate";
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
        label: Text('Ticket'),
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: Text('Production'),
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: Text('Progress'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: Text('Shipping Date'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(size: ColumnSize.L, label: Text('Status'), numeric: true),
      DataColumn2(numeric: true, size: ColumnSize.S, tooltip: "Options", label: Text('Options'))
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Last ppage example uses extra API call to get the number of items in datasource
    if (_dataSourceLoading) return SizedBox();

    return Stack(alignment: Alignment.bottomCenter, children: [
      AsyncPaginatedDataTable2(
          showFirstLastButtons: true,
          smRatio: 0.5,
          lmRatio: 3,
          horizontalMargin: 20,
          checkboxHorizontalMargin: 12,
          columnSpacing: 16,
          rowsPerPage: _rowsPerPage,
          autoRowsToHeight: false,
          availableRowsPerPage: [20, 50, 100, 200],
          wrapInCard: false,
          pageSyncApproach: PageSyncApproach.goToFirst,
          minWidth: 800,
          fit: FlexFit.tight,
          border: TableBorder(
              top: BorderSide(color: Colors.transparent),
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
            print("${rowIndex}${_rowsPerPage}xxxxxxxx =${rowIndex / _rowsPerPage}");
          },
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          controller: _controller,
          hidePaginator: false,
          columns: _columns,
          empty: Center(child: Container(padding: EdgeInsets.all(20), color: Colors.grey[200], child: Text('No data'))),
          loading: _Loading(),
          errorBuilder: (e) => _ErrorAndRetry(e.toString(), () => _dessertsDataSource!.refreshDatasource()),
          source: _dessertsDataSource!),
    ]);
  }
}

class _ErrorAndRetry extends StatelessWidget {
  _ErrorAndRetry(this.errorMessage, this.retry);

  final String errorMessage;
  final void Function() retry;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
            padding: EdgeInsets.all(10),
            height: 170,
            color: Colors.red,
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Oops! $errorMessage', style: TextStyle(color: Colors.white)),
              TextButton(
                  onPressed: retry,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                    Text('Retry', style: TextStyle(color: Colors.white))
                  ]))
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
            future: Future.delayed(Duration(milliseconds: 500), () => true),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SizedBox()
                  : Center(
                      child: Container(
                      color: Colors.yellow,
                      padding: EdgeInsets.all(7),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                        Text('Loading..')
                      ]),
                      width: 150,
                      height: 50,
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
  bool _empty = false;
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
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    print('getRows($startIndex, $count)');
    if (_errorCounter != null) {
      _errorCounter = _errorCounter! + 1;

      if (_errorCounter! % 2 == 1) {
        await Future.delayed(Duration(milliseconds: 1000));
        throw 'Error #${((_errorCounter! - 1) / 2).round() + 1} has occured';
      }
    }

    var index = startIndex;

    assert(index >= 0);

    // List returned will be empty is there're fewer items than startingAt
    var x = _empty
        ? await Future.delayed(Duration(milliseconds: 2000), () => DataResponse(0, []))
        : await onRequestData(int.parse("${startIndex / count}"), startIndex, count, _sortColumn, _sortAscending);

    var r = AsyncRowsResponse(
        x.totalRecords,
        x.data.map((ticket) {
          return DataRow2(
            selected: false,
            onTap: () {
              var ticketInfo = TicketInfo(ticket);
              ticketInfo.show(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 1),
                content: Text('Tapped on ${ticket.mo}'),
              ));
            },

            onSecondaryTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              backgroundColor: Theme.of(context).errorColor,
              content: Text('Right clicked on ${ticket.mo}'),
            )),
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
                  if (ticket.inPrint == 1)
                    IconButton(
                      icon: CircleAvatar(child: Icon(Icons.print_rounded, color: Colors.deepOrangeAccent), backgroundColor: Colors.white),
                      onPressed: () {},
                    ),
                  if (ticket.isHold == 1)
                    IconButton(
                      icon: CircleAvatar(child: Icon(NsIcons.stop, color: Colors.black), backgroundColor: Colors.white),
                      onPressed: () {
                        FlagDialog.showFlagView(context, ticket, TicketFlagTypes.HOLD);
                      },
                    ),
                  if (ticket.isGr == 1)
                    IconButton(
                      icon: CircleAvatar(child: Icon(NsIcons.gr, color: Colors.blue), backgroundColor: Colors.white),
                      onPressed: () {
                        FlagDialog.showFlagView(context, ticket, TicketFlagTypes.GR);
                      },
                    ),
                  if (ticket.isSk == 1)
                    IconButton(
                      icon: CircleAvatar(child: Icon(NsIcons.sk, color: Colors.pink), backgroundColor: Colors.white),
                      onPressed: () {},
                    ),
                  if (ticket.isError == 1)
                    IconButton(icon: CircleAvatar(child: Icon(Icons.report_problem_rounded, color: Colors.red), backgroundColor: Colors.white), onPressed: () {}),
                  if (ticket.isSort == 1)
                    IconButton(icon: CircleAvatar(child: Icon(Icons.local_mall_rounded, color: Colors.green), backgroundColor: Colors.white), onPressed: () {}),
                  if (ticket.isRush == 1)
                    IconButton(
                        icon: CircleAvatar(child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent), backgroundColor: Colors.white),
                        onPressed: () {
                          FlagDialog.showFlagView(context, ticket, TicketFlagTypes.RUSH);
                        }),
                  if (ticket.isRed == 1)
                    IconButton(
                      icon: CircleAvatar(child: Icon(Icons.tour_rounded, color: Colors.red), backgroundColor: Colors.white),
                      onPressed: () {
                        FlagDialog.showFlagView(context, ticket, TicketFlagTypes.RED);
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
        }).toList());

    return r;
  }
}

class DataResponse {
  DataResponse(this.totalRecords, this.data);

  final int totalRecords;
  final List<Ticket> data;
}
