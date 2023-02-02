import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class WebSheetDataTable<T extends Object> extends StatefulWidget {
  final Null Function(SheetDataSourceAsync dataSource) onInit;
  final Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;
  final Null Function(T _element) onTap;

  final List<DataColumn3> columns;

  const WebSheetDataTable({super.key, required this.onInit, required this.onRequestData, required this.onTap, required this.columns});

  @override
  _WebPrintTableState createState() => _WebPrintTableState();
}

class DataColumn3 extends DataColumn {
  /// Creates the configuration for a column of a [DataTable2].
  ///
  /// The [label] argument must not be null.
  const DataColumn3({required Widget label, String? tooltip, bool numeric = false, Function(int, bool)? onSort, this.size = ColumnSize.M})
      : super(label: label, tooltip: tooltip, numeric: numeric, onSort: onSort);

  /// Column sizes are determined based on available width by distributing it
  /// to individual columns accounting for their relative sizes (see [ColumnSize])
  final ColumnSize size;
}

class _WebPrintTableState<T extends Object> extends State<WebSheetDataTable> {
  int _rowsPerPage = 20;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  SheetDataSourceAsync? _dessertsDataSource;
  final PaginatorController _controller = PaginatorController();

  final bool _dataSourceLoading = false;
  final int _initialRow = 0;

  @override
  void didChangeDependencies() {
    // initState is to early to access route options, context is invalid at that stage
    _dessertsDataSource ??= SheetDataSourceAsync(context, onRequestData: widget.onRequestData, onTap: (element) {
      widget.onTap(element);
    });

    widget.onInit(_dessertsDataSource!);

    super.didChangeDependencies();
  }

  void sort(int columnIndex, bool ascending) {
    var columnName = "mo";
    switch (columnIndex) {
      case 1:
        columnName = "production";
        break;
      case 2:
        columnName = "doneOn";
        break;
      case 3:
        columnName = "action";
        break;
      case 4:
        columnName = "doneBy";
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
      DataColumn2(size: ColumnSize.L, label: const Text('MO'), onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(size: ColumnSize.M, label: const Text('OE'), onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(size: ColumnSize.M, label: const Text('Operation NO'), numeric: true, onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(size: ColumnSize.M, label: const Text('Next'), numeric: true, onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(size: ColumnSize.M, label: const Text('Operation'), numeric: false, onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(size: ColumnSize.M, label: const Text('pool'), numeric: false, onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(size: ColumnSize.M, label: const Text('Delivery Date'), numeric: false, onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(size: ColumnSize.M, label: const Text('Ship Date'), numeric: false, onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
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
          empty: Center(child: Container(padding: const EdgeInsets.all(20), color: Colors.grey[200], child: const Text('No data'))),
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
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
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

class SheetDataSourceAsync<T extends Object> extends AsyncDataTableSource {
  Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;
  Null Function(Object) onTap;

  SheetDataSourceAsync(this.context, {required this.onRequestData, required this.onTap}) {
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

  String _sortColumn = "mo";
  bool _sortAscending = true;

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
        ? await Future.delayed(const Duration(milliseconds: 2000), () => DataResponse(0, <T>[]))
        : await onRequestData(int.parse("${start / end}"), start, end, _sortColumn, _sortAscending);

    var r = AsyncRowsResponse(
        x.totalRecords,
        x.data.map((sheetData) {
          return DataRow2(
              selected: false,
              onTap: () {
                onTap(sheetData);
              },
              onSecondaryTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    content: Text('Right clicked on $sheetData'),
                  )),
              // specificRowHeight: this.hasRowHeightOverrides && sheetData.fat >= 25 ? 100 : null,
              cells: const [
                // DataCell(Text((sheetData.mo) ?? "")),
                // DataCell(Text((sheetData.oe) ?? "")),
                // DataCell(Text(("${sheetData.operationNo}"))),
                // DataCell(Text(("${sheetData.next}"))),
                // DataCell(Text(("${sheetData.operation}"))),
                // DataCell(Text(("${sheetData.pool}"))),
                // DataCell(Text(("${sheetData.deliveryDate}"))),
                // DataCell(Text(("${sheetData.shipDate}"))),
              ]);
        }).toList());

    return r;
  }
}

class DataResponse<T extends Object> {
  DataResponse(this.totalRecords, this.data);

  final int totalRecords;
  final List<T> data;
}
