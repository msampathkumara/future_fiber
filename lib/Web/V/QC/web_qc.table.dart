part of 'web_qc.dart';

class WebQcTable extends StatefulWidget {
  final Null Function(QcDataSourceAsync dataSource) onInit;
  final Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;

  const WebQcTable({Key? key, required this.onInit, required this.onRequestData}) : super(key: key);

  @override
  _WebQcTableState createState() => _WebQcTableState();
}

class _WebQcTableState extends State<WebQcTable> {
  int _rowsPerPage = 20;
  bool _sortAscending = false;
  int? _sortColumnIndex = 2;
  QcDataSourceAsync? _dessertsDataSource;
  final PaginatorController _controller = PaginatorController();

  final bool _dataSourceLoading = false;
  final int _initialRow = 0;

  @override
  void didChangeDependencies() {
    // initState is to early to access route options, context is invalid at that stage
    _dessertsDataSource ??= QcDataSourceAsync(context, onRequestData: widget.onRequestData);

    widget.onInit(_dessertsDataSource!);

    super.didChangeDependencies();
  }

  void sort(int columnIndex, bool ascending) {
    var columnName = "dnt";
    switch (columnIndex) {
      case 0:
        columnName = "ticket.mo";
        break;
      case 1:
        columnName = "quality";
        break;
      case 2:
        columnName = "dnt";
        break;
      case 3:
        columnName = "qc.qc";
        break;
      case 4:
        columnName = "qc.sectionId";
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
        size: ColumnSize.L,
        label: const Text('Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.M,
        numeric: true,
        label: const Text('Quality', style: TextStyle(fontWeight: FontWeight.bold)),
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.M,
        numeric: true,
        label: const Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold)),
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: false,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: const Text('Section', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: false,
        onSort: (columnIndex, ascending) => sort(columnIndex, ascending),
      ),
      const DataColumn2(
        size: ColumnSize.M,
        label: Text('User', style: TextStyle(fontWeight: FontWeight.bold)),
        numeric: false,
        // onSort: (columnIndex, ascending) => sort(columnIndex, ascending)
      ),
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
            print('Row per page changed to $value');
            _rowsPerPage = value!;
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

class QcDataSourceAsync extends AsyncDataTableSource {
  Future<DataResponse> Function(int page, int startingAt, int count, String sortedBy, bool sortedAsc) onRequestData;

  QcDataSourceAsync(this.context, {required this.onRequestData}) {
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

  String _sortColumn = "dnt";
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

    print('**************************************************************** xxxx ');
    print('**************************************************************** xxxx${x.totalRecords}');

    var r = AsyncRowsResponse(
        x.totalRecords,
        x.data.map((qc) {
          Section? section = qc.getSection();

          print(qc);

          return DataRow2(
            selected: false,
            onTap: () {
              webQView(qc).show(context);

              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //   duration: const Duration(seconds: 1),
              //   content: Text('Tapped on ${qc.ticket?.id}'),
              // ));
            },

            onSecondaryTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              backgroundColor: Theme.of(context).errorColor,
              content: Text('Right clicked on ${qc.ticket?.id}'),
            )),
            // specificRowHeight: this.hasRowHeightOverrides && qc.fat >= 25 ? 100 : null,
            cells: [
              DataCell(InkWell(
                  onTap: () {
                    if (qc.ticket != null) {
                      TicketInfo(qc.ticket!).show(context);
                    }
                  },
                  child: Wrap(
                      direction: Axis.vertical, children: [Text((qc.ticket?.mo) ?? ""), Text((qc.ticket?.oe) ?? "", style: const TextStyle(color: Colors.red, fontSize: 12))]))),
              DataCell(Text(qc.quality ?? '')),
              DataCell(Text('${qc.getDateTime()}')),
              DataCell(Text(qc.qc == 1 ? 'QC' : 'QA')),
              DataCell(Wrap(
                  direction: Axis.vertical,
                  children: [Text((section?.factory) ?? ""), Text((section?.sectionTitle) ?? "", style: const TextStyle(color: Colors.red, fontSize: 12))])),
              DataCell(Row(
                children: [
                  UserImage(nsUser: qc.user, radius: 16, padding: 2),
                  const SizedBox(width: 4),
                  Wrap(
                    direction: Axis.vertical,
                    children: [Text("${qc.user?.name}"), Text("${qc.user?.uname}")],
                  ),
                ],
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
  final List<QC> data;
}
