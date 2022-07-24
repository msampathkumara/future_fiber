import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/M/CPR/CPR.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/Web/Styles/styles.dart';
import 'package:smartwind/Web/V/MaterialManagement/CPR/AddCpr.dart';
import 'package:smartwind/Web/V/MaterialManagement/CPR/CprView.dart';
import 'package:smartwind/Web/V/MaterialManagement/CPR/TicketSelector.dart';
import 'package:smartwind/Web/Widgets/myDropDown.dart';

import '../../../../M/AppUser.dart';
import '../../../../M/Ticket.dart';
import '../../../../V/Widgets/NoResultFoundMsg.dart';

part 'webCpr.options.dart';
part 'webCpr.table.dart';

class WebCpr extends StatefulWidget {
  const WebCpr({Key? key}) : super(key: key);

  @override
  State<WebCpr> createState() => _WebCprState();
}

class _WebCprState extends State<WebCpr> {
  final _controller = TextEditingController();
  bool loading = false;

  // DessertDataSource? _dataSource;
  String searchText = "";

  Production selectedProduction = Production.All;

  bool requested = false;

  int dataCount = 0;

  bool _dataLoadingError = false;

  late DessertDataSourceAsync _dataSource;

  final _status = ['All', 'Sent', 'Ready', 'Pending', 'Order'];
  String selectedStatus = 'All';

  bool e = false;

  @override
  void initState() {
    // Ticket t = HiveBox.ticketBox.values.where((element) => element.mo == 'MO-00317274').toList()[0];
    // WidgetsBinding.instance?.addPostFrameCallback((_) => AddCpr(t).show(context));

    // getData(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Ticket? ticket = await const TicketSelector().show(context);
              if (ticket != null) {
                AddCpr(ticket).show(context);
              }
            },
            child: const Icon(Icons.add)),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Row(
              children: [
                Text("CPR", style: mainWidgetsTitleTextStyle),
                const Spacer(),
                Wrap(children: [
                  myDropDown<Production>(
                      items: Production.values,
                      elevation: 4,
                      lable: 'Production',
                      value: Production.None,
                      selectedText: (selectedItem) {
                        return (selectedItem).getValue();
                      },
                      onSelect: (x) {
                        selectedProduction = x;
                        setState(() {});
                        loadData();
                        return selectedProduction.getValue();
                      },
                      onChildBuild: (Production item) {
                        return Text(item.getValue());
                      }),
                  const SizedBox(width: 20),
                  myDropDown<String>(
                      items: _status,
                      elevation: 4,
                      lable: 'Status',
                      value: selectedStatus,
                      selectedText: (selectedItem) {
                        return (selectedItem);
                      },
                      onSelect: (x) {
                        selectedStatus = x;
                        setState(() {});
                        loadData();
                        return selectedStatus;
                      },
                      onChildBuild: (item) {
                        return Text('$item');
                      }),
                  // const SizedBox(
                  //   width: 200,
                  // ),
                  // Material(
                  //   elevation: 4,
                  //   borderRadius: BorderRadius.circular(8),
                  //   child: SizedBox(
                  //     height: 40,
                  //     child: DropdownButtonHideUnderline(
                  //       child: DropdownButton<Production>(
                  //         value: selectedProduction,
                  //         selectedItemBuilder: (_) {
                  //           return Production.values.map<Widget>((Production item) {
                  //             return Center(
                  //                 child: Padding(
                  //               padding: const EdgeInsets.all(8.0),
                  //               child: Text("${item.getValue()}"),
                  //             ));
                  //           }).toList();
                  //         },
                  //         items: Production.values.map((Production value) {
                  //           return DropdownMenuItem<Production>(
                  //             value: value,
                  //             child: Text(value.getValue()),
                  //           );
                  //         }).toList(),
                  //         onChanged: (_) {
                  //           selectedProduction = _ ?? Production.All;
                  //           setState(() {});
                  //           loadData();
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(width: 20),
                  // Material(
                  //   elevation: 4,
                  //   borderRadius: BorderRadius.circular(8),
                  //   child: SizedBox(
                  //     height: 40,
                  //     child: DropdownButtonHideUnderline(
                  //       child: DropdownButton<String>(
                  //         value: selectedStatus,
                  //         selectedItemBuilder: (_) {
                  //           return _status.map<Widget>((String item) {
                  //             return Padding(
                  //               padding: const EdgeInsets.only(left: 8, right: 8),
                  //               child: Column(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   const Text("Status", style: TextStyle(fontSize: 12)),
                  //                   Text("${item}", style: const TextStyle(fontSize: 16)),
                  //                 ],
                  //               ),
                  //             );
                  //           }).toList();
                  //         },
                  //         items: _status.map((String value) {
                  //           return DropdownMenuItem<String>(value: value, child: Text(value));
                  //         }).toList(),
                  //         onChanged: (_) {
                  //           selectedStatus = _ ?? 'All';
                  //           setState(() {});
                  //           loadData();
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 20),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                        height: 40,
                        width: 200,
                        child: TextFormField(
                          controller: _controller,
                          onChanged: (text) {
                            searchText = text;
                            loadData();
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: _controller.clear),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 15, bottom: 11, top: 10, right: 15),
                              hintText: "Search Text"),
                        )),
                  ),
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
            child: WebCPRTable(onInit: (DessertDataSourceAsync dataSource) {
              _dataSource = dataSource;
            }, onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
              return getData(page, startingAt, count, sortedBy, sortedAsc);
            })),
      ),
      // bottomNavigationBar: Material(
      //   borderRadius: BorderRadius.circular(8.0),
      //   clipBehavior: Clip.antiAlias,
      //   child: BottomAppBar(
      //       shape: const CircularNotchedRectangle(),
      //       child: IconTheme(
      //         data: const IconThemeData(color: Colors.white),
      //         child: Row(
      //           children: [
      //             InkWell(
      //               onTap: () {},
      //               splashColor: Colors.red,
      //               child: Ink(
      //                 child: IconButton(
      //                   icon: const Icon(Icons.refresh),
      //                   onPressed: () {
      //                     _dataSource.refreshDatasource();
      //                   },
      //                 ),
      //               ),
      //             ),
      //             // const Spacer(),
      //             // const Padding(
      //             //   padding: EdgeInsets.all(8.0),
      //             //   child: Text(
      //             //     "${0}",
      //             //     textScaleFactor: 1.1,
      //             //     style: TextStyle(color: Colors.white),
      //             //   ),
      //             // ),
      //             const Spacer(),
      //             const SizedBox(width: 36)
      //           ],
      //         ),
      //       )),
      // )
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
    return Api.get("materialManagement/cpr/search", {
      'production': selectedProduction.getValue(),
      'status': selectedStatus,
      'sortDirection': sortedAsc ? "asc" : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'searchText': searchText
    }).then((res) {
      // print(res.data);
      List cprs = res.data["cprs"];
      dataCount = res.data["count"];

      _dataLoadingError = false;
      var x = CPR.fromJsonArray(cprs);
      return DataResponse(dataCount, x);
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
      setState(() {
        _dataLoadingError = true;
      });
    });
  }
}
