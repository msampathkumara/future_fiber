import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind_future_fibers/C/Api.dart';
import 'package:smartwind_future_fibers/M/CPR/CPR.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:deebugee_plugin/DeeBugeeSearchBar.dart';
import 'package:smartwind_future_fibers/Web/Styles/styles.dart';
import 'package:smartwind_future_fibers/Web/V/MaterialManagement/CPR/AddCpr.dart';
import 'package:smartwind_future_fibers/Web/V/MaterialManagement/CPR/TicketSelector.dart';
import 'package:smartwind_future_fibers/Web/V/MaterialManagement/CPR/webCprView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/myDropDown.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../M/AppUser.dart';
import '../../../../M/PermissionsEnum.dart';
import '../../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../../ProductionPool/copy.dart';
import '../orderOprions.dart';

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

  String selectedSupplierStatus = 'None';

  DateTime rangeStartDate = DateTime.now();

  DateTime? rangeEndDate = DateTime.now();

  DateTime? selectedDate = DateTime.now();

  bool singleDate = false;

  String? _title;

  bool filterByDate = false;

  @override
  void initState() {
    super.initState();
  }

  bool filterByStartTicket = false;
  List<String> supplierStatusList = List.from(["None", "Cutting Pending", "Cutting Sent", "SA Pending", "SA Sent", "Printing Pending", "Printing Sent"]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
        floatingActionButton: (AppUser.havePermissionFor(NsPermissions.CPR_ADD_CPR))
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton.small(
                    onPressed: () async {
                      await const TicketSelector().show(context).then((ticket) async {
                        if (ticket != null) {
                          await AddCpr(ticket).show(context).then((v) {
                            if (v == true) {
                              loadData();
                            }
                          });
                        }
                      });
                    },
                    child: const Icon(Icons.add)),
              )
            : null,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Row(
              children: [
                Text("CPR", style: mainWidgetsTitleTextStyle),
                const Spacer(),
                SizedBox(height: 36, child: ElevatedButton.icon(onPressed: () => {downloadExcel()}, label: const Text("Download Exel"), icon: const Icon(Icons.download))),
                const SizedBox(width: 16),
                IconButton(
                    icon: CircleAvatar(backgroundColor: Colors.white, radius: 16, child: Icon(Icons.play_arrow, color: filterByStartTicket ? Colors.red : Colors.black, size: 20)),
                    tooltip: 'Filter by start ticket',
                    onPressed: () async {
                      filterByStartTicket = !filterByStartTicket;
                      loadData();
                    }),
                const SizedBox(width: 16),
                Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: PopupMenuButton<int>(
                        tooltip: "Select Date or Date range to filer by CPR Due Date",
                        offset: const Offset(0, 30),
                        padding: const EdgeInsets.all(16.0),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        child: Chip(
                            deleteIcon: const Icon(Icons.close, color: Colors.red),
                            onDeleted: filterByDate ? () => {filterByDate = false, _title = null, loadData()} : null,
                            // backgroundColor: _selectedFilter == e ? Colors.red : null,
                            avatar: const Icon(Icons.date_range, color: Colors.black),
                            label: Text(_title ?? "Select Due Date", style: const TextStyle(color: Colors.black))),
                        onSelected: (result) {},
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                                value: 0,
                                enabled: false,
                                child: SizedBox(
                                    width: 500,
                                    height: 300,
                                    child: SfDateRangePicker(
                                        initialSelectedRange: PickerDateRange(rangeStartDate, rangeEndDate),
                                        maxDate: DateTime.now(),
                                        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                                          print(args.value);

                                          rangeEndDate = null;
                                          selectedDate = null;
                                          if (args.value is PickerDateRange) {
                                            rangeStartDate = args.value.startDate;
                                            rangeEndDate = args.value.endDate;
                                            if (rangeStartDate == rangeEndDate) {
                                              rangeEndDate = null;
                                            }
                                          } else if (args.value is DateTime) {
                                            selectedDate = args.value;
                                          } else if (args.value is List<DateTime>) {
                                          } else {}
                                          rangeEndDate = rangeEndDate == rangeStartDate ? null : rangeEndDate;
                                          if (rangeEndDate == null || rangeStartDate.isSameDate(rangeEndDate!)) {
                                            singleDate = true;
                                          } else {
                                            singleDate = false;
                                          }
                                        },
                                        selectionMode: DateRangePickerSelectionMode.range))),
                            PopupMenuItem(
                              value: 1,
                              enabled: false,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: () => {
                                            _title = singleDate
                                                ? DateFormat("yyyy MMMM dd").format(rangeStartDate)
                                                : "${DateFormat("yyyy/MM/dd").format(rangeStartDate)} to ${DateFormat("yyyy/MM/dd").format(rangeEndDate!)}",
                                            filterByDate = true,
                                            Navigator.of(context).pop(),
                                            loadData()
                                          },
                                      child: const Text('Done')),
                                  const Spacer(),
                                  TextButton(onPressed: () => {filterByDate = false, _title = null, Navigator.of(context).pop(), loadData()}, child: const Text('Cancel')),
                                ],
                              ),
                            )
                          ];
                        })),
                const SizedBox(width: 16),
                Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: PopupMenuButton<String>(
                        offset: const Offset(0, 30),
                        padding: const EdgeInsets.all(16.0),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        child: Chip(
                            avatar: const Icon(Icons.factory, color: Colors.black),
                            label: Row(children: [Text(selectedSupplierStatus), const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)])),
                        onSelected: (result) {},
                        itemBuilder: (BuildContext context) {
                          return supplierStatusList.map((String value) {
                            return PopupMenuItem<String>(
                                value: value,
                                onTap: () {
                                  selectedSupplierStatus = value;
                                  setState(() {});
                                  loadData();
                                },
                                child: Text(value));
                          }).toList();
                        })),
                const SizedBox(width: 16),
                Wrap(children: [
                  MyDropDown<String>(
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
                  MyDropDown<Production>(
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
                  MyDropDown<String>(
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
                      child:
                          SizedBox(height: 40, width: 300, child: DeeBugeeSearchBar(searchController: _controller, onSearchTextChanged: (text) => {searchText = text, loadData()})))
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
    return Api.get(EndPoints.materialManagement_cpr_search, {
      "supplierStatus": selectedSupplierStatus,
      'production': selectedProduction.getValue(),
      'status': selectedStatus,
      'sortDirection': sortedAsc ? "asc" : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'orderType': selectedOrderType,
      'searchText': searchText,
      'filterByStartTicket': filterByStartTicket,
      "startDate": selectedDate,
      "rangeStartDate": filterByDate ? rangeStartDate : null,
      "rangeEndDate": filterByDate ? rangeEndDate : null
    }).then((res) {
      print('--------------------------------------------------------------------------------------------------xxxxxxxx-');
      print('---------------------------------------------------------------------------------------------------_${res.data["count"]}');
      dataCount = int.parse("${res.data["count"]}");

      var x = CPR.fromJsonArray(res.data["cprs"]);
      // print('---------------------------------------------------------------------------------------------------${res.data}');
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
              onPressed: () async {
                // await getData(page, startingAt, count, sortedBy, sortedAsc);
                _dataSource.refreshDatasource();
              })));
      setState(() {});
    });
  }

  Future<void> downloadExcel() async {
    DateTime now = DateTime.now();
    String lastMonth = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month - 1, now.day));
    String nextMonth = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, now.day));

    Api.downloadFile(EndPoints.materialManagement_cpr_getExcel, {}, "cpr-$lastMonth - $nextMonth.xlsx");
  }
}
