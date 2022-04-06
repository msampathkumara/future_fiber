import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../C/Api.dart';
import '../../../M/Enums.dart';
import '../../../M/SheetData.dart';
import '../../../V/Widgets/SearchBar.dart';
import '../../Styles/styles.dart';

part 'webSheetData.table.dart';

class WebSheetData extends StatefulWidget {
  const WebSheetData({Key? key}) : super(key: key);

  @override
  State<WebSheetData> createState() => _WebSheetDataState();
}

class _WebSheetDataState extends State<WebSheetData> {
  var _controller = TextEditingController();
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
                Text("Pending To Finish", style: mainWidgetsTitleTextStyle),
                Spacer(),
                Wrap(children: [
                  SizedBox(width: 20),
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
          padding: const EdgeInsets.all(16.0),
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
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            color: Colors.green,
            child: IconTheme(
              data: IconThemeData(color: Colors.white),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {},
                    splashColor: Colors.red,
                    child: Ink(
                      child: IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          _dataSource.refreshDatasource();
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${0}",
                      textScaleFactor: 1.1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 36)
                ],
              ),
            )));
  }

  Filters dataFilter = Filters.none;

  void loadData() {
    _dataSource.refreshDatasource();
  }

  Status _selectedStatus = Status.All;
  Production _selectedProduction = Production.All;

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
