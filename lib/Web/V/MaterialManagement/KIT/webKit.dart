import 'package:data_table_2/data_table_2.dart';
import 'package:deebugee_plugin/DeeBugeeSearchBar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../C/Api.dart';
import '../../../../C/DB/DB.dart';
import '../../../../M/AppUser.dart';
import '../../../../M/CPR/KIT.dart';
import '../../../../M/EndPoints.dart';
import '../../../../M/Enums.dart';
import '../../../../M/PermissionsEnum.dart';
import '../../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../../../Styles/styles.dart';
import '../../ProductionPool/copy.dart';
import '../orderOprions.dart';
import 'KitView.dart';
import '../../../../M/Extensions.dart';
import 'ScanReadyKits.dart';
import 'SendKits.dart';

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

  final _status = ['All', 'Sent', 'Ready', 'Pending', 'Order', 'Received'];
  String selectedStatus = 'All';

  DbChangeCallBack? _dbChangeCallBack;

  bool filterByStartTicket = false;

  String selectedOrderType = "All";

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

  Map<int, KIT> selectedList = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Row(
              children: [
                Text("KIT", style: mainWidgetsTitleTextStyle),
                const Spacer(),
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
                const SizedBox(width: 16),
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
                const SizedBox(width: 16),
                if (AppUser.havePermissionFor(NsPermissions.KIT_SEND_KITS))
                  Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              await SendKits(selectedList).show(context);
                              loadData();
                            },
                            label: Text(selectedList.isEmpty ? "Send" : "Send (${selectedList.length})"),
                            icon: const Icon(Icons.send)),
                      )),
                const SizedBox(width: 50),
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                  IconButton(
                    icon: CircleAvatar(backgroundColor: Colors.white, radius: 16, child: Icon(Icons.play_arrow, color: filterByStartTicket ? Colors.red : Colors.black, size: 20)),
                    tooltip: 'Filter by start ticket',
                    onPressed: () async {
                      filterByStartTicket = !filterByStartTicket;
                      loadData();
                    },
                  ),
                  const SizedBox(width: 20),
                  Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: PopupMenuButton<String>(
                          offset: const Offset(0, 30),
                          padding: const EdgeInsets.all(16.0),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          child: Chip(
                              avatar: const Icon(Icons.factory_rounded, color: Colors.black),
                              label: Row(children: [Text(selectedProduction.getValue()), const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)])),
                          onSelected: (result) {},
                          itemBuilder: (BuildContext context) {
                            return Production.values.map((Production value) {
                              return PopupMenuItem<String>(
                                  value: value.getValue(),
                                  onTap: () {
                                    selectedProduction = value;
                                    setState(() {});
                                    loadData();
                                  },
                                  child: Text(value.getValue()));
                            }).toList();
                          })),

                  Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: PopupMenuButton<String>(
                          offset: const Offset(0, 30),
                          padding: const EdgeInsets.all(16.0),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          child: Chip(
                              avatar: const Icon(Icons.more, color: Colors.black),
                              label: Row(children: [Text(selectedStatus), const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)])),
                          onSelected: (result) {},
                          itemBuilder: (BuildContext context) {
                            return _status.map((String value) {
                              return PopupMenuItem<String>(
                                  value: value,
                                  onTap: () {
                                    selectedStatus = value;
                                    setState(() {});
                                    loadData();
                                  },
                                  child: Text(value));
                            }).toList();
                          })),
                  const SizedBox(width: 16),
                  PopupMenuButton<String>(
                      tooltip: "Filter By Order Type",
                      offset: const Offset(0, 30),
                      padding: const EdgeInsets.all(16.0),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child: Chip(
                          avatar: const Icon(Icons.star_rounded, color: Colors.black),
                          label: Row(children: [Text(selectedOrderType), const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)])),
                      onSelected: (result) {},
                      itemBuilder: (BuildContext context) {
                        return ['All', 'Urgent', 'Normal', 'Urgent + Normal'].map((String value) {
                          return PopupMenuItem<String>(
                              value: value,
                              onTap: () {
                                selectedOrderType = value;
                                setState(() {});
                                loadData();
                              },
                              child: Text(value));
                        }).toList();
                      }),

                  //-------------------------------------------------------------------------------------------------

                  const SizedBox(width: 20),
                  Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                          height: 40, width: 250, child: DeeBugeeSearchBar(searchController: _controller, onSearchTextChanged: (text) => {searchText = text, loadData()}))),
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
                }, onSelectChange: (selectedList) {
                  this.selectedList = selectedList;
                  setState(() {});
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
      'filterByStartTicket': filterByStartTicket,
      'orderType': selectedOrderType
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
