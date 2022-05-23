import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/Web/V/Tabs/TabLog/TabLog.dart';
import 'package:smartwind/Web/V/Tabs/deviceRenameDialog.dart';

import '../../../C/Api.dart';
import '../../../M/Device.dart';
import '../../../M/Enums.dart';
import '../../../V/Widgets/SearchBar.dart';
import '../../../V/Widgets/UserImage.dart';
import '../../Styles/styles.dart';

part 'web_tabs.table.dart';

class WebTabs extends StatefulWidget {
  const WebTabs({Key? key}) : super(key: key);

  @override
  State<WebTabs> createState() => _WebTabsState();
}

class _WebTabsState extends State<WebTabs> {
  final _controller = TextEditingController();
  bool loading = false;

  String searchText = "";

  bool requested = false;

  int dataCount = 0;

  late DeviceSourceAsync _dataSource;

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
                Text("Devices", style: mainWidgetsTitleTextStyle),
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
          padding: const EdgeInsets.all(16.0),
          child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: DeviceDataTable(onInit: (DeviceSourceAsync dataSource) {
                _dataSource = dataSource;
              }, onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
                return getData(page, startingAt, count, sortedBy, sortedAsc);
              }, onTap: (Device tab) {
                TabLog(tab).show(context);
              })),
        ),
        bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            color: Colors.green,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {},
                    splashColor: Colors.red,
                    child: Ink(
                      child: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          _dataSource.refreshDatasource();
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "${0}",
                      textScaleFactor: 1.1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36)
                ],
              ),
            )));
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

    return Api.get("tabs/tabList", {
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
      List tab = res.data["tabs"];
      dataCount = res.data["count"];

      setState(() {});
      return DataResponse(dataCount, Device.fromJsonArray(tab));
    }).whenComplete(() {
      setState(() {
        requested = false;
      });
    }).catchError((err) {
      print(err);
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
