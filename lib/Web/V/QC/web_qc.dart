import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/QC.dart';
import 'package:smartwind_future_fibers/M/Section.dart';
import 'package:deebugee_plugin/DeeBugeeSearchBar.dart';
import 'package:smartwind_future_fibers/Web/V/QC/webQView.dart';

import '../../../C/Api.dart';
import '../../../M/Enums.dart';
import '../../../Mobile/V/Home/Tickets/TicketInfo/TicketInfo.dart';
import '../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../../../Mobile/V/Widgets/UserImage.dart';
import '../../Styles/styles.dart';

part 'web_qc.table.dart';

class WebQc extends StatefulWidget {
  const WebQc({Key? key}) : super(key: key);

  @override
  State<WebQc> createState() => _WebQcState();
}

class _WebQcState extends State<WebQc> {
  final _controller = TextEditingController();
  bool loading = false;

  String searchText = "";

  bool requested = false;

  int dataCount = 0;

  late QcDataSourceAsync _dataSource;

  Type _selectedType = Type.All;

  Production selectedProduction = Production.All;

  String selectedQuality = 'All';

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
                Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 1, color: Colors.red, height: 24)),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PopupMenuButton<Production>(
                        offset: const Offset(0, 30),
                        padding: const EdgeInsets.all(16.0),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        child: Chip(
                            avatar: const Icon(Icons.factory, color: Colors.black),
                            label: Row(children: [Text(selectedProduction.getValue()), const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)])),
                        onSelected: (result) {},
                        itemBuilder: (BuildContext context) {
                          return Production.values.map((Production value) {
                            return PopupMenuItem<Production>(
                                value: value,
                                onTap: () {
                                  selectedProduction = value;
                                  setState(() {});
                                  loadData();
                                },
                                child: Text(value.getValue()));
                          }).toList();
                        })),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PopupMenuButton<String>(
                        offset: const Offset(0, 30),
                        padding: const EdgeInsets.all(16.0),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        child: Chip(
                            avatar: const Icon(Icons.star_rate_rounded, color: Colors.black),
                            label: Row(children: [Text(selectedQuality), const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)])),
                        onSelected: (result) {},
                        itemBuilder: (BuildContext context) {
                          return ["All", "QC Pass", "Under Concision", "Rework", "Reject"].map((String value) {
                            return PopupMenuItem<String>(
                                value: value,
                                onTap: () {
                                  selectedQuality = value;
                                  setState(() {});
                                  loadData();
                                },
                                child: Text(value));
                          }).toList();
                        })),
                const SizedBox(width: 16),
                DeeBugeeSearchBar(
                    onSearchTextChanged: (text) {
                      searchText = text;
                      loadData();
                    },
                    searchController: _controller)
              ]),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16),
        child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: WebQcTable(onInit: (QcDataSourceAsync dataSource) {
              _dataSource = dataSource;
            }, onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
              return getData(page, startingAt, count, sortedBy, sortedAsc);
            })),
      ),
    );
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

    return Api.get(EndPoints.tickets_qc_getList, {
      'production': selectedProduction.getValue(),
      "type": _selectedType.getValue(),
      'sortDirection': sortedAsc ? "asc" : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'searchText': searchText,
      'quality': selectedQuality
    }).then((res) {
      print(res.data);
      List qcs = res.data["qcs"];
      dataCount = res.data["count"] ?? 0;
      print('--------------------dddd----------- ');
      print('--------------------dddd-----------${QC.fromJsonArray(qcs)}');

      setState(() {});
      return DataResponse(dataCount, QC.fromJsonArray(qcs));
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
