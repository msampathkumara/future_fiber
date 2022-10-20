import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../C/Api.dart';
import '../../../M/Enums.dart';
import '../../../M/SheetData.dart';
import '../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../../../Mobile/V/Widgets/SearchBar.dart';
import '../../Styles/styles.dart';

part 'webSheetData.table.dart';

class WebSheetData extends StatefulWidget {
  const WebSheetData({Key? key}) : super(key: key);

  @override
  State<WebSheetData> createState() => _WebSheetDataState();
}

class _WebSheetDataState extends State<WebSheetData> {
  final _controller = TextEditingController();
  bool loading = false;

  String searchText = "";

  bool requested = false;

  int dataCount = 0;

  late SheetDataSourceAsync _dataSource;

  @override
  void initState() {
    // getData(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          title: Row(
            children: [
              Text("Sheet Data", style: mainWidgetsTitleTextStyle),
              const Spacer(),
              Wrap(children: [
                const SizedBox(width: 20),
                SearchBar(
                    delay: 300,
                    onSearchTextChanged: (text) {
                      searchText = text;
                      loadData();
                    },
                    searchController: _controller)
              ])
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16),
        child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: WebSheetDataTable(onInit: (SheetDataSourceAsync dataSource) {
              _dataSource = dataSource;
            }, onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
              return getData(page, startingAt, count, sortedBy, sortedAsc);
            }, onTap: (SheetData sheetData) {
              // SheetDataList(sheetData).show(context);
            })),
      ),
    );
  }

  Filters dataFilter = Filters.none;

  void loadData() {
    _dataSource.refreshDatasource();
  }

  final Status _selectedStatus = Status.All;
  final Production _selectedProduction = Production.All;

  Future<DataResponse> getData(page, startingAt, count, sortedBy, sortedAsc) {
    setState(() {
      requested = true;
    });

    return Api.get("sheet/getSheetData", {
      'type': 'All',
      'status': _selectedStatus.getValue(),
      'sortDirection': sortedAsc ? "asc" : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'searchText': searchText,
      'production': _selectedProduction.getValue()
    }).then((res) {
      print(res.data);
      List sheetData = res.data["process"];
      dataCount = res.data["count"];

      setState(() {});
      return DataResponse(dataCount, SheetData.fromJsonArray(sheetData));
    }).whenComplete(() {
      setState(() {
        requested = false;
      });
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                getData(page, startingAt, count, sortedBy, sortedAsc);
              })));
      setState(() {});
    });
  }
}
