import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/QC.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';
import 'package:smartwind/Web/V/QC/webQView.dart';

import '../../../C/Api.dart';
import '../../../M/Enums.dart';
import '../../../M/Ticket.dart';
import '../../Styles/styles.dart';

part 'web_qc.table.dart';

class WebQc extends StatefulWidget {
  const WebQc({Key? key}) : super(key: key);

  @override
  State<WebQc> createState() => _WebQcState();
}

class _WebQcState extends State<WebQc> {
  var _controller = TextEditingController();
  bool loading = false;

  String searchText = "";

  bool requested = false;

  int dataCount = 0;

  List<Ticket> _ticketList = [];

  bool _dataLoadingError = false;

  late QcDataSourceAsync _dataSource;

  Type _selectedType = Type.All;

  // get ticketCount => _dataSource == null ? 0 : _dataSource?.rowCount;

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
                Text("QA & QC", style: mainWidgetsTitleTextStyle),
                const Spacer(),
                Wrap(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8,
                      children: [_typeChip(Type.All), _typeChip(Type.QC), _typeChip(Type.QA)],
                    ),
                  ),
                  SearchBar(
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
              child: WebQcTable(onInit: (QcDataSourceAsync dataSource) {
                _dataSource = dataSource;
              }, onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
                return getData(page, startingAt, count, sortedBy, sortedAsc);
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

  Future<DataResponse> getData(page, startingAt, count, sortedBy, sortedAsc) {
    setState(() {
      requested = true;
    });

    // type=All&pageSize=100&sortBy=mo&pageIndex=0&searchText=&sortDirection=asc&production=all

    return Api.get("tickets/qc/getList", {
      "type": _selectedType.getValue(),
      'sortDirection': sortedAsc ? "asc" : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'searchText': searchText,
    }).then((res) {
      print(res.data);
      List tickets = res.data["qcs"];
      dataCount = res.data["count"];

      _dataLoadingError = false;

      setState(() {});
      return DataResponse(dataCount, QC.fromJsonArray(tickets));
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
      setState(() {
        _dataLoadingError = true;
      });
    });
  }

  _typeChip(Type p) {
    return FilterChip(
        selectedColor: Colors.white,
        checkmarkColor: Colors.orange,
        label: Text(
          p.getValue(),
          style: TextStyle(color: _selectedType == p ? Colors.orange : Colors.black),
        ),
        selected: _selectedType == p,
        onSelected: (bool value) {
          _selectedType = p;

          loadData();
        });
  }
}
