part of 'webUserManager.dart';

class WebUserManagerTable extends StatefulWidget {
  final Null Function(UserManagerDataSource dataSource) onInit;
  final Null Function(NsUser nsUser) onTap;

  const WebUserManagerTable({Key? key, required this.onInit, required this.onTap}) : super(key: key);

  @override
  _WebUserManagerTableState createState() => _WebUserManagerTableState();
}

class _WebUserManagerTableState extends State<WebUserManagerTable> {
  int _rowsPerPage = 20;
  bool _sortAscending = false;
  int? _sortColumnIndex;
  late UserManagerDataSource _dessertsDataSource;
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
      _dessertsDataSource = UserManagerDataSource(context, (NsUser nsUser) {
        return true;
      }, onTap: (NsUser nsUser) {
        widget.onTap(nsUser);
      });

      _controller = PaginatorController();

      _sortColumnIndex = 1;

      _initialized = true;
      widget.onInit(_dessertsDataSource);
    }
  }

  void sort<T>(Comparable<T> Function(NsUser d) getField, int columnIndex, bool ascending) {
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
          size: ColumnSize.S,
          label: const Tooltip(message: "Photo", child: Text('Photo', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold))),
          onSort: (columnIndex, ascending) => sort<String>((d) => (d.name), columnIndex, ascending)),
      DataColumn2(size: ColumnSize.L, label: const Text('Name'), onSort: (columnIndex, ascending) => sort<String>((d) => (d.name), columnIndex, ascending)),
      DataColumn2(size: ColumnSize.M, label: const Text('NIC'), onSort: (columnIndex, ascending) => sort<String>((d) => d.nic ?? '', columnIndex, ascending)),
      DataColumn2(size: ColumnSize.M, label: const Text('EPF'), onSort: (columnIndex, ascending) => sort((d) => d.getEpf() ?? 0, columnIndex, ascending)),
      const DataColumn2(numeric: true, size: ColumnSize.S, tooltip: "Options", label: Text('Options'))
    ];
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      PaginatedDataTable2(
        scrollController: _scrollController,
        smRatio: 0.4,
        lmRatio: 2,
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
        availableRowsPerPage: const [20, 50, 100, 200],
        empty: Center(child: Container(padding: const EdgeInsets.all(20), child: const NoResultFoundMsg())),
        source: _dessertsDataSource,
      ),
      // Positioned(bottom: 16, child: CustomPager(_controller!))
    ]);
  }
}

class UserManagerDataSource extends DataTableSource {
  bool Function(NsUser nsUser) filter;
  Function(NsUser nsUser) onTap;

  UserManagerDataSource(this.context, this.filter, {required this.onTap}) {
    nsUsers = HiveBox.usersBox.values.where((element) => element.isNotDeactivated).toList();
    sort(sortField, _ascending);
  }

  final BuildContext context;
  late List<NsUser> nsUsers;

  late bool hasRowTaps = true;
  late bool hasRowHeightOverrides;

  Comparable Function(NsUser d) sortField = ((d) => (d.name));
  final _ascending = true;

  void sort<T>(Comparable<T> Function(NsUser d) getField, bool ascending) {
    nsUsers.sort((a, b) {
      var aValue = getField(a);
      var bValue = getField(b);

      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  isNumeric(string) => num.tryParse(string) != null;

  final int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= nsUsers.length) throw 'index > _nsUsers.length';
    final nsUser = nsUsers[index];
    return DataRow2.byIndex(
      index: index,
      selected: false,
      onTap: () {
        onTap(nsUser);
      },
      onDoubleTap: hasRowTaps
          ? () => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(duration: const Duration(seconds: 1), backgroundColor: Theme.of(context).focusColor, content: Text('Double Tapped on ${nsUser.name}')))
          : null,
      onSecondaryTap: hasRowTaps
          ? () => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(duration: const Duration(seconds: 1), backgroundColor: Theme.of(context).errorColor, content: Text('Right clicked on ${nsUser.name}')))
          : null,
      // specificRowHeight: this.hasRowHeightOverrides && nsUser.fat >= 25 ? 100 : null,
      cells: [
        DataCell(UserImage(nsUser: nsUser, radius: 22, padding: 2)),
        DataCell(Wrap(direction: Axis.vertical, children: [Text((nsUser.name)), Text((nsUser.uname), style: const TextStyle(color: Colors.red, fontSize: 12))])),
        DataCell(Text('${nsUser.nic ?? '-'} ')),
        DataCell(Wrap(direction: Axis.vertical, children: [Text('${nsUser.epf ?? ''} ')])),
        DataCell(nsUser.id == 0
            ? const Text("")
            : IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () {
                  showUserOptions(nsUser, context, context, false, onRemoveNfcCard: () {
                    nsUser.removeNfcCard(context, onDone: () {
                      notifyListeners();
                    });
                  });
                },
              ))
      ],
    );
  }

  @override
  int get rowCount => nsUsers.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void setData(List<NsUser> _nsUsers) {
    nsUsers = _nsUsers;
    sort(sortField, _ascending);
    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
  }
}
