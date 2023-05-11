import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind_future_fibers/C/Api.dart';
import 'package:smartwind_future_fibers/M/CPR/KIT.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/Web/Styles/styles.dart';
import 'package:smartwind_future_fibers/Web/V/MaterialManagement/KIT/ScanReadyKits.dart';
import 'package:smartwind_future_fibers/Web/V/MaterialManagement/KIT/SendKits.dart';

import '../../../../C/DB/DB.dart';
import '../../../../M/AppUser.dart';
import '../../../../M/EndPoints.dart';
import '../../../../M/PermissionsEnum.dart';
import '../../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../../../../Mobile/V/Widgets/SearchBar.dart';
import '../../../Widgets/myDropDown.dart';
import '../../ProductionPool/copy.dart';
import '../orderOprions.dart';
import 'KitView.dart';
import '../../../../M/Extensions.dart';
import 'ReceiveKits.dart';

part 'webKit.options.dart';

part 'webKit.table.dart';

class WebKit extends StatefulWidget {
  const WebKit({Key? key}) : super(key: key);

  @override
  State<WebKit> createState() => _WebKitState();
}

class _WebKitState extends State<WebKit> {
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

  DbChangeCallBack? _dbChangeCallBack;

  bool filterByStartTicket = false;

  @override
  void initState() {
    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update kit');
      if (mounted) {
        loadData();
      }
    }, context, collection: DataTables.kit);
    super.initState();
  }

  @override
  void dispose() {
    _dbChangeCallBack?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Row(
              children: [
                Text("KIT", style: mainWidgetsTitleTextStyle),
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
                          DateTime now = DateTime.now();
                          String lastMonth = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month - 1, now.day));
                          String nextMonth = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, now.day));
                          Api.downloadFile(EndPoints.materialManagement_kit_getExcel, {}, "$lastMonth - $nextMonth.xlsx");
                        },
                        label: const Text("Download Exel"),
                        icon: const Icon(Icons.download))),
                const SizedBox(width: 50),
                Wrap(children: [
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
                  const SizedBox(width: 24),
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

                  //-------------------------------------------------------------------------------------------------

                  const SizedBox(width: 24),
                  if (AppUser.havePermissionFor(NsPermissions.KIT_SCAN_READY_KITS))
                    SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              await const ScanReadyKits().show(context);
                              loadData();
                            },
                            label: const Text("Scan Ready Kits"),
                            icon: const Icon(Icons.settings_overscan))),
                  if (AppUser.havePermissionFor(NsPermissions.KIT_SEND_KITS))
                    Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                              onPressed: () async {
                                await const SendKits().show(context);
                                loadData();
                              },
                              label: const Text("Send"),
                              icon: const Icon(Icons.send)),
                        )),
                  if (AppUser.havePermissionFor(NsPermissions.KIT_RECEIVE_KITS))
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                            onPressed: () async => {await const ReceiveKits().show(context), loadData()},
                            label: const Text("Receive"),
                            icon: const Icon(Icons.call_received_rounded)),
                      ),
                    ),
                  const SizedBox(width: 20),
                  Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(height: 40, width: 250, child: S_SearchBar(searchController: _controller, onSearchTextChanged: (text) => {searchText = text, loadData()}))),
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
                child: WebKITTable(onInit: (DessertDataSourceAsync dataSource) {
                  _dataSource = dataSource;
                }, onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
                  return getData(page, startingAt, count, sortedBy, sortedAsc);
                }))));
  }

  Filters dataFilter = Filters.none;

  void loadData() {
    _dataSource.refreshData();
  }

  Future<DataResponse> getData(page, startingAt, count, sortedBy, sortedAsc) {
    setState(() {
      requested = true;
    });
    return Api.get(EndPoints.materialManagement_kit_search, {
      'production': selectedProduction.getValue(),
      'status': selectedStatus,
      'sortDirection': sortedAsc ? "asc" : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'searchText': searchText,
      'filterByStartTicket': filterByStartTicket
    }).then((res) {
      List kits = res.data["kits"];
      dataCount = res.data["count"];

      var x = KIT.fromJsonArray(kits);
      setState(() {});
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
}
