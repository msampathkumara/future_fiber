import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/M/CPR/CPR.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';
import 'package:smartwind/Web/Styles/styles.dart';
import 'package:smartwind/Web/V/MaterialManagement/CPR/AddCpr.dart';
import 'package:smartwind/Web/V/MaterialManagement/CPR/TicketSelector.dart';
import 'package:smartwind/Web/V/MaterialManagement/CPR/webCprView.dart';
import 'package:smartwind/Web/Widgets/myDropDown.dart';

import '../../../../M/AppUser.dart';
import '../../../../M/PermissionsEnum.dart';
import '../../../../M/Ticket.dart';
import '../../../../V/Widgets/NoResultFoundMsg.dart';
import '../../../Widgets/ShowMessage.dart';
import '../../ProductionPool/copy.dart';

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

  late DessertDataSourceAsync _dataSource;

  final _status = ['All', 'Sent', 'Ready', 'Pending', 'Order'];
  String selectedStatus = 'All';

  bool e = false;

  String selectedOrderType = 'All';

  @override
  void initState() {
    super.initState();
  }

  bool filterByStartTicket = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: FloatingActionButton.small(
            onPressed: () async {
              Ticket? ticket = await const TicketSelector().show(context);
              if (ticket != null) {
                await AddCpr(ticket).show(context);
              }
            },
            child: const Icon(Icons.add)),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Row(
              children: [
                Text("CPR", style: mainWidgetsTitleTextStyle),
                const Spacer(),
                IconButton(
                  icon: CircleAvatar(backgroundColor: Colors.white, radius: 16, child: Icon(Icons.play_arrow, color: filterByStartTicket ? Colors.red : Colors.black, size: 20)),
                  tooltip: 'Filter by start ticket',
                  onPressed: () async {
                    filterByStartTicket = !filterByStartTicket;

                    loadData();
                  },
                ),
                const SizedBox(width: 50),
                SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          downloadExcel();
                        },
                        label: const Text("Download Exel"),
                        icon: const Icon(Icons.download))),
                const SizedBox(width: 50),
                Wrap(children: [
                  myDropDown<String>(
                      items: const ['All', 'Urgent', 'Normal'],
                      elevation: 4,
                      lable: 'OrderType',
                      value: 'All',
                      selectedText: (selectedItem) {
                        return (selectedItem);
                      },
                      onSelect: (x) {
                        selectedOrderType = x;
                        setState(() {});
                        loadData();
                        return selectedOrderType;
                      },
                      onChildBuild: (item) {
                        return Text(item);
                      }),
                  const SizedBox(width: 20),
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
                        return Text(item);
                      }),
                  const SizedBox(width: 20),
                  Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                          height: 40,
                          width: 200,
                          child: SearchBar(
                              searchController: _controller,
                              onSearchTextChanged: (text) {
                                searchText = text;
                                loadData();
                              })))
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
        ));
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
      'orderType': selectedOrderType,
      'searchText': searchText
    }).then((res) {
      print('--------------------------------------------------------------------------------------------------xxxxxxxx-');
      dataCount = res.data["count"];

      var x = CPR.fromJsonArray(res.data["cprs"]);
      print('---------------------------------------------------------------------------------------------------');
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
      setState(() {});
    });
  }

  Future<void> downloadExcel() async {
    DateTime now = DateTime.now();
    String lastMonth = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month - 1, now.day));
    String nextMonth = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, now.day));

    Api.downloadFile("materialManagement/cpr/getExcel", {}, "cpr-$lastMonth - $nextMonth.xlsx");
  }
}
