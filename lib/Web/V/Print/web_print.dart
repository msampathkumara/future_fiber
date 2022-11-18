import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/Web/V/Print/ticket_print_list.dart';

import '../../../C/Api.dart';
import '../../../M/TicketPrint.dart';
import '../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../../../Mobile/V/Widgets/SearchBar.dart';
import '../../../Mobile/V/Widgets/UserImage.dart';
import '../../Styles/styles.dart';

part 'web_print.table.dart';

class WebPrint extends StatefulWidget {
  const WebPrint({Key? key}) : super(key: key);

  @override
  State<WebPrint> createState() => _WebPrintState();
}

class _WebPrintState extends State<WebPrint> {
  final _controller = TextEditingController();
  bool loading = false;

  String searchText = "";

  bool requested = false;

  int dataCount = 0;

  late PrintDataSourceAsync _dataSource;

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
              Text("Print", style: mainWidgetsTitleTextStyle),
              const Spacer(),
              Wrap(children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(spacing: 8, children: [_statusChip(Status.All), _statusChip(Status.Done), _statusChip(Status.Sent), _statusChip(Status.Cancel)])),
                const SizedBox(width: 20),
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 40,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Production>(
                        value: _selectedProduction,
                        selectedItemBuilder: (_) {
                          return Production.values.map<Widget>((Production item) {
                            return Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item.getValue()),
                            ));
                          }).toList();
                        },
                        items: Production.values.map((Production value) {
                          return DropdownMenuItem<Production>(
                            value: value,
                            child: Text(value.getValue()),
                          );
                        }).toList(),
                        onChanged: (_) {
                          _selectedProduction = _ ?? Production.All;
                          setState(() {});
                          loadData();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
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
            child: WebPrintTable(onInit: (PrintDataSourceAsync dataSource) {
              _dataSource = dataSource;
            }, onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
              return getData(page, startingAt, count, sortedBy, sortedAsc);
            }, onTap: (TicketPrint ticketPrint) {
              if (ticketPrint.ticket != null) {
                TicketPrintList(ticketPrint.ticket!).show(context);
              }
            })),
      ),
      // bottomNavigationBar: BottomAppBar(
      //     shape: const CircularNotchedRectangle(),
      //     color: Colors.green,
      //     child: IconTheme(
      //       data: const IconThemeData(color: Colors.white),
      //       child: Row(
      //         children: [
      //           InkWell(
      //             onTap: () {},
      //             splashColor: Colors.red,
      //             child: Ink(
      //               child: IconButton(
      //                 icon: const Icon(Icons.refresh),
      //                 onPressed: () {
      //                   _dataSource.refreshDatasource();
      //                 },
      //               ),
      //             ),
      //           ),
      //           const Spacer(),
      //           const Padding(
      //             padding: EdgeInsets.all(8.0),
      //             child: const Text(
      //               "${0}",
      //               textScaleFactor: 1.1,
      //               style: const TextStyle(color: Colors.white),
      //             ),
      //           ),
      //           const Spacer(),
      //           const SizedBox(width: 36)
      //         ],
      //       ),
      //     ))
    );
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

    return Api.get("tickets/print/getList", {
      'status': _selectedStatus.getValue(),
      'sortDirection': sortedAsc ? "asc" : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'searchText': searchText,
      'production': _selectedProduction.getValue()
    }).then((res) {
      print(res.data);
      List ticketPrint = res.data["prints"];
      dataCount = res.data["count"];

      setState(() {});
      return DataResponse(dataCount, TicketPrint.fromJsonArray(ticketPrint));
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

  _statusChip(Status p) {
    return FilterChip(
        selectedColor: Colors.white,
        checkmarkColor: Colors.orange,
        label: Text(
          p.getValue(),
          style: TextStyle(color: _selectedStatus == p ? Colors.orange : Colors.black),
        ),
        selected: _selectedStatus == p,
        onSelected: (bool value) {
          _selectedStatus = p;

          loadData();
        });
  }
}
