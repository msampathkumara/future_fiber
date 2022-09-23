part of 'webCpr.dart';

class WebCPRTable extends StatefulWidget {
  final Null Function(DessertDataSourceAsync dataSource) onInit;
  final Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;

  const WebCPRTable({required this.onInit, required this.onRequestData});

  @override
  _WebCPRTableState createState() => _WebCPRTableState();
}

class _WebCPRTableState extends State<WebCPRTable> {
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

  void sort(int columnIndex, bool ascending) {
    var columnName = "oe";

    columnName = ['mo', 'client', 'suppliers', 'shortageType', 'addedOn', 'cprType', 'shipDate', 'status', 'order'][columnIndex];

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
      DataColumn2(size: ColumnSize.S, label: const Text('Client', style: TextStyle(fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Shortage Type', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('CPR Type', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Shipping Date', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.S,
          label: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.S,
          label: const Text('Order', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.S,
          label: const Text('Options', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
    ];
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Last page example uses extra API call to get the number of items in datasource
    if (_dataSourceLoading) return const SizedBox();

    return Stack(alignment: Alignment.bottomCenter, children: [
      AsyncPaginatedDataTable2(
          scrollController: _scrollController,
          showFirstLastButtons: true,
          smRatio: 0.4,
          lmRatio: 2.7,
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
            print("${rowIndex}${_rowsPerPage}xxxxxxxx =${rowIndex / _rowsPerPage}");
          },
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          controller: _controller,
          hidePaginator: false,
          columns: _columns,
          empty: Center(child: Container(padding: const EdgeInsets.all(20), child: const NoResultFoundMsg())),
          loading: _Loading(),
          errorBuilder: (e) {
            print(e);
            return _ErrorAndRetry(e.toString(), () => _dessertsDataSource!.refreshDatasource());
          },
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
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [CircularProgressIndicator(strokeWidth: 2, color: Colors.black), Text('Loading..')]),
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

  String _sortColumn = "name";
  bool _sortAscending = true;

  void sort(String columnName, bool ascending) {
    _sortColumn = columnName;
    _sortAscending = ascending;
    refreshDatasource();
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    print('getRows($startIndex, $count)');
    if (_errorCounter != null) {
      _errorCounter = _errorCounter! + 1;

      if (_errorCounter! % 2 == 1) {
        await Future.delayed(const Duration(milliseconds: 1000));
        throw 'Error #${((_errorCounter! - 1) / 2).round() + 1} has occured';
      }
    }

    var index = startIndex;

    assert(index >= 0);

    print('xxxxxxxxxxxxxxxxxxxxxxx == ${int.parse("${startIndex / count}")}');

    // List returned will be empty is there're fewer items than startingAt
    var x = _empty
        ? await Future.delayed(const Duration(milliseconds: 2000), () => DataResponse(0, []))
        : await onRequestData(int.parse("${startIndex / count}"), startIndex, count, _sortColumn, _sortAscending);
    print('****************************************************************************xxxxxxxxxxxxx${x.totalRecords}');
    var r = AsyncRowsResponse(
        x.totalRecords,
        x.data.map((cpr) {
          return DataRow2(
            specificRowHeight: 55,
            selected: false,
            onTap: () async {
              bool c = false;
              await CprView(cpr, (p0) => c = true).show(context);
              if (c == true) {
                refreshDatasource();
              }
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(seconds: 1), content: Text('Tapped on ${cpr.ticket?.mo}')));
            },
            onSecondaryTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(duration: const Duration(seconds: 1), backgroundColor: Theme.of(context).errorColor, content: Text('Right clicked on ${cpr.ticket?.oe}'))),
            cells: [
              DataCell(ListTile(
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  title: TextMenu(child: Text(cpr.ticket?.mo ?? '', style: TextStyle(color: cpr.isTicketStarted ? Colors.green : null))),
                  subtitle: TextMenu(child: Text(cpr.ticket?.oe ?? '', style: const TextStyle(color: Colors.deepOrange, fontSize: 12))))),
              DataCell(Text((cpr.client) ?? "")),
              DataCell(Text((cpr.suppliers.join(',')))),
              DataCell(Text((cpr.shortageType) ?? "")),
              DataCell(Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  direction: Axis.vertical,
                  children: [Text((cpr.date) ?? ""), Text((cpr.time) ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12))])),
              DataCell(Text((cpr.cprType) ?? "")),
              DataCell(Text((cpr.shipDate))),
              DataCell(Text((cpr.status), style: TextStyle(color: cpr.status.getColor()))),
              DataCell(Text((cpr.orderType ?? ''), style: TextStyle(color: (cpr.orderType ?? '').getColor()))),
              DataCell(IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () {
                  showCprOptions(cpr, context, context, () {
                    print('------------------------------------------------refreshDatasource');
                    refreshDatasource();
                  });
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
  final List<CPR> data;
}
