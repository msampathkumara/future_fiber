part of 'webKit.dart';

class WebKITTable extends StatefulWidget {
  final Null Function(DessertDataSourceAsync dataSource) onInit;
  final Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;
  final Function(Map<int, KIT> selectedList) onSelectChange;

  const WebKITTable({super.key, required this.onInit, required this.onRequestData, required this.onSelectChange});

  @override
  _WebKITTableState createState() => _WebKITTableState();
}

class _WebKITTableState extends State<WebKITTable> {
  int _rowsPerPage = 20;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  DessertDataSourceAsync? _dessertsDataSource;
  final PaginatorController _controller = PaginatorController();

  final bool _dataSourceLoading = false;
  final int _initialRow = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    // initState is to early to access route options, context is invalid at that stage
    _dessertsDataSource ??= DessertDataSourceAsync(context, onRequestData: widget.onRequestData, onSelectChange: widget.onSelectChange);

    widget.onInit(_dessertsDataSource!);

    super.didChangeDependencies();
  }

  void sort(int columnIndex, bool ascending) {
    var columnName = ['mo', 'client', 'shortageType', 'addedOn', 'shipDate', 'shipDate', 'status'][columnIndex];

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
      const DataColumn2(size: ColumnSize.S, label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn2(size: ColumnSize.M, label: const Text('Ticket', style: TextStyle(fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(size: ColumnSize.M, label: const Text('Client', style: TextStyle(fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
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
          label: const Text('Shipping Date', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
          label: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: (columnIndex, ascending) => sort(columnIndex, ascending)),
      DataColumn2(
          size: ColumnSize.M,
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

  @override
  Widget build(BuildContext context) {
    // Last ppage example uses extra API call to get the number of items in datasource
    if (_dataSourceLoading) return const SizedBox();

    return Stack(alignment: Alignment.bottomCenter, children: [
      AsyncPaginatedDataTable2(
          // onSelectAll: (x) {
          //   print('xxxxxxxxxxxxxxxxxxxxxxxxcccccccccccccc');
          // },
          // showCheckboxColumn: true,
          scrollController: _scrollController,
          showFirstLastButtons: true,
          smRatio: 0.2,
          lmRatio: 2,
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
            _dessertsDataSource?.refreshData();
            //});
          },
          showCheckboxColumn: true,
          initialFirstRowIndex: _initialRow,
          onPageChanged: (rowIndex) {
            print("$rowIndex${_rowsPerPage}xxxxxxxx =${rowIndex / _rowsPerPage}");
            _dessertsDataSource?.refreshData();
          },
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          controller: _controller,
          hidePaginator: false,
          columns: _columns,
          empty: Center(child: Container(padding: const EdgeInsets.all(20), child: const NoResultFoundMsg())),
          loading: _Loading(),
          errorBuilder: (e) => _ErrorAndRetry(e.toString(), () => _dessertsDataSource!.refreshData()),
          source: _dessertsDataSource!),
      if (DessertDataSourceAsync.selectedList.isNotEmpty)
        Positioned(
            left: 16,
            bottom: 16,
            child: Row(
              children: [
                Text("${DessertDataSourceAsync.selectedList.length} KITs Selected "),
                TextButton(
                    onPressed: () {
                      DessertDataSourceAsync.selectedList.clear();
                      _dessertsDataSource?.refreshDatasource();
                      setState(() {});
                    },
                    child: const Text("Clear Selection", style: TextStyle(color: Colors.red)))
              ],
            )),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround, children: [CircularProgressIndicator(strokeWidth: 2, color: Colors.black), Text('Loading..')])));
            }));
  }
}

class DessertDataSourceAsync extends AsyncDataTableSource {
  static Map<int, KIT> selectedList = {};
  Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;
  Function(Map<int, KIT> selectedList) onSelectChange;

  DessertDataSourceAsync(this.context, {required this.onRequestData, required this.onSelectChange}) {
    print('DessertDataSourceAsync created');
  }

  final BuildContext context;

  DataResponse? _dataResponse;

  int? _errorCounter;

  RangeValues? _caloriesFilter;

  RangeValues? get caloriesFilter => _caloriesFilter;

  set caloriesFilter(RangeValues? calories) {
    _caloriesFilter = calories;
    refreshData();
  }

  // final DesertsFakeWebService _repo = DesertsFakeWebService();

  String _sortColumn = "shipDate";
  bool _sortAscending = true;

  void sort(String columnName, bool ascending) {
    _sortColumn = columnName;
    _sortAscending = ascending;
    refreshData();
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

    print('xxxxxxxxxxxxxxxxxxxxxxx == ${int.parse("${start / end}")}');

    // _dataResponse = null;

    // List returned will be empty is there're fewer items than startingAt
    var x = _dataResponse ?? (_dataResponse = await onRequestData(int.parse("${start / end}"), start, end, _sortColumn, _sortAscending));
    print('****************************************************************************xxxxxxxxxxxxx${x.totalRecords}');
    var r = AsyncRowsResponse(
        x.totalRecords,
        x.data.mapIndexed((kit, index) {
          return DataRow2(
              color: (selectedList.containsKey(kit.id) ? MaterialStateProperty.all(Colors.grey.shade300) : MaterialStateProperty.all(Colors.white)),
              specificRowHeight: 55,
              onDoubleTap: () async {
                bool c = false;
                await KitView(kit, (p0) {
                  c = true;
                }).show(context);
                if (c == true) {
                  refreshData();
                }
              },
              cells: [
                DataCell(onTap: () {
                  if (!selectedList.containsKey(kit.id)) {
                    selectedList[kit.id] = kit;
                  } else {
                    selectedList.remove(kit.id);
                  }
                  onSelectChange(selectedList);
                  refreshDatasource();
                }, Center(child: Text("${index + 1}"))),
                DataCell(ListTile(
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    title: TextMenu(child: Text(kit.ticket?.mo ?? kit.ticket?.oe ?? '', style: TextStyle(color: kit.isTicketStarted ? Colors.green : null, fontSize: 15))),
                    subtitle: TextMenu(child: Text(kit.ticket?.oe ?? '', style: const TextStyle(color: Colors.deepOrange, fontSize: 12))))),
                DataCell(Text(((kit.client) ?? ""))),
                DataCell(Text((kit.shortageType) ?? "")),
                DataCell(Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    direction: Axis.vertical,
                    children: [Text((kit.date)), Text((kit.time), style: const TextStyle(color: Colors.grey, fontSize: 12))])),
                DataCell(Text((kit.shipDate))),
                DataCell(Text((kit.status.capitalize()), style: TextStyle(color: kit.status.getColor()))),
                DataCell(Text((kit.orderType ?? ''), style: TextStyle(color: (kit.orderType ?? '').getColor()))),
                DataCell(IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () => {
                          showCprOptions(kit, context, context, () {
                            print('------------------------------------------------refreshData');
                            refreshData();
                          })
                        }))
              ]);
        }).toList());

    return r;
  }

  void order(KIT kit) {
    Api.post(EndPoints.materialManagement_kit_order, {'kitId': kit.id})
        .then((res) {
      refreshData();
    })
        .whenComplete(() {})
        .catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
    });
  }

  void refreshData() {
    _dataResponse = null;
    refreshDatasource();
  }
}

class DataResponse {
  DataResponse(this.totalRecords, this.data);

  final int totalRecords;
  final List<KIT> data;
}
