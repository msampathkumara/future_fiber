import 'dart:async';

import 'package:deebugee_plugin/DeeBugeeSearchBar.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/C/Api.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/Web/V/FinishedGoods/webFinishedGoods.table.dart';

import '../../../M/Enums.dart';
import '../../../M/Ticket.dart';
import '../../../Mobile/V/Widgets/SearchBar.dart';
import '../../../ns_icons_icons.dart';
import '../../Styles/styles.dart';

class WebFinishedGoods extends StatefulWidget {
  const WebFinishedGoods({super.key});

  @override
  State<WebFinishedGoods> createState() => _WebFinishedGoodsState();
}

class _WebFinishedGoodsState extends State<WebFinishedGoods> {
  final _controller = TextEditingController();
  bool loading = false;

  // DessertDataSource? _dataSource;
  String searchText = "";

  Production selectedProduction = Production.All;

  bool requested = false;

  int dataCount = 0;

  late DessertDataSourceAsync _dataSource;

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
                Text("Finished Goods", style: mainWidgetsTitleTextStyle),
                const Spacer(),
                Wrap(children: [
                  // flagIcon(Filters.isCrossPro, Icons.merge_type_rounded, "Filter by cross production"),
                  flagIcon(Filters.isError, Icons.warning_rounded, "Filter by Error Route"),
                  // flagIcon(Filters.inPrint, Icons.print_rounded, "Filter by in print"),
                  flagIcon(Filters.isRush, Icons.offline_bolt_rounded, "Filter by rush"),
                  flagIcon(Filters.isRed, Icons.flag_rounded, "Filter by red flag"),
                  flagIcon(Filters.isHold, NsIcons.stop, "Filter by stop"),
                  flagIcon(Filters.isSk, NsIcons.sk, "Filter by SK"),
                  flagIcon(Filters.isGr, NsIcons.gr, "Filter by GR"),
                  flagIcon(Filters.haveCpr, NsIcons.short, "Filter by CPR"),
                  flagIcon(Filters.isQc, NsIcons.short, "Filter by QC", text: "QC"),
                  flagIcon(Filters.isQa, NsIcons.short, "Filter by QA", text: "QA"),
                  const SizedBox(width: 50),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 40,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Production>(
                          value: selectedProduction,
                          selectedItemBuilder: (_) {
                            return Production.values.where((element) => element.getValue().toLowerCase() != 'none').toList().map<Widget>((Production item) {
                              return Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(item.getValue()),
                              ));
                            }).toList();
                          },
                          items: Production.values.where((element) => element.getValue().toLowerCase() != 'none').map((Production value) {
                            return DropdownMenuItem<Production>(
                              value: value,
                              child: Text(value.getValue()),
                            );
                          }).toList(),
                          onChanged: (_) {
                            selectedProduction = _ ?? Production.All;
                            setState(() {});
                            loadData();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 40,
                      width: 200,
                      child: DeeBugeeSearchBar(
                          onSearchTextChanged: (String text) {
                            searchText = text;
                            loadData();
                          },
                          delay: 500,
                          searchController: _controller),
                      // child: TextFormField(
                      //   controller: _controller,
                      //   onChanged: (text) {
                      //     searchText = text;
                      //     loadData();
                      //   },
                      //   cursorColor: Colors.black,
                      //   decoration: InputDecoration(
                      //       prefixIcon: const Icon(Icons.search_rounded),
                      //       suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: _controller.clear),
                      //       border: InputBorder.none,
                      //       focusedBorder: InputBorder.none,
                      //       enabledBorder: InputBorder.none,
                      //       errorBorder: InputBorder.none,
                      //       disabledBorder: InputBorder.none,
                      //       contentPadding: const EdgeInsets.only(left: 15, bottom: 11, top: 10, right: 15),
                      //       hintText: "Search Text"),
                      // )
                    ),
                  ),
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
              child: AsyncPaginatedDataTable2Demo(onInit: (DessertDataSourceAsync dataSource) {
                _dataSource = dataSource;
              }, onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
                return getData(page, startingAt, count, sortedBy, sortedAsc);
              })),
        ));
  }

  Filters dataFilter = Filters.none;

  flagIcon(Filters filter, IconData icon, tooltip, {String? text}) {
    return IconButton(
      icon: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 16,
          child: (text != null)
              ? Text(text, style: TextStyle(color: dataFilter == filter ? Colors.red : Colors.black, fontWeight: FontWeight.bold))
              : Icon(icon, color: dataFilter == filter ? Colors.red : Colors.black, size: 20)),
      tooltip: tooltip,
      onPressed: () async {
        dataFilter = dataFilter == filter ? Filters.none : filter;
        loadData();
        setState(() {});
      },
    );
  }

  void loadData() {
    _dataSource.refreshDatasource();
  }

  Future<DataResponse> getData(page, startingAt, count, sortedBy, sortedAsc) {
    setState(() {
      requested = true;
    });
    return Api.get(EndPoints.tickets_completed_getList, {
      'production': selectedProduction.getValue(),
      "flag": dataFilter.getValue(),
      'sortDirection': sortedAsc ? 'asc' : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'searchText': searchText
    }).then((res) {
      print(res.data);
      List tickets = res.data["tickets"];
      dataCount = res.data["count"];
      return DataResponse(dataCount, Ticket.fromJsonArray(tickets));
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
        // _dataLoadingError = true;
      });
    });
  }
}
