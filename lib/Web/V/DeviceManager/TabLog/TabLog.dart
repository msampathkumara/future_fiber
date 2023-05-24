import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/DeviceLog.dart';

import '../../../../C/Api.dart';
import '../../../../M/Device.dart';
import '../../../../M/EndPoints.dart';
import '../../../../M/NsUser.dart';
import 'package:deebugee_plugin/DialogView.dart';
import '../../../../Mobile/V/Widgets/UserImage.dart';
import '../../../Widgets/DialogView.dart';

part 'tabLog.table.dart';

class TabLog extends StatefulWidget {
  final Device device;

  const TabLog(this.device, {Key? key}) : super(key: key);

  @override
  State<TabLog> createState() => _TabLogState();

  void show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _TabLogState extends State<TabLog> {
  late Device device;

  @override
  void initState() {
    device = widget.device;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogView(
        width: 1000,
        child: Scaffold(
            appBar: AppBar(title: const Text("Tab Log")),
            body: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Material(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                            width: 250,
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(children: [
                                  Text(device.name, textScaleFactor: 1.2, style: const TextStyle(color: Colors.red)),
                                  Text("${device.imei}"),
                                  Text("${device.model}"),
                                  Text("${device.modelNumber}")
                                ]))))),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16.0, 16, 16),
                  child: Material(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: TabLogDataTable(
                        onInit: (TabLogDataSourceAsync dataSource) {},
                        onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
                          return getData(page, startingAt, count, sortedBy, sortedAsc);
                        },
                        onTap: (sheetData) {},
                      )),
                ))
              ],
            )));
  }

  getData(int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
    return Api.get(EndPoints.tabs_logList, {'tab': device.id, 'type': 'All', 'sortedAsc': sortedAsc, 'sortBy': sortedBy, 'pageIndex': page, 'pageSize': count})
        .then((res) {
          List log = res.data["tabLog"];
          var dataCount = res.data["count"];
          return DataResponse(dataCount, DeviceLog.fromJsonArray(log));
        })
        .whenComplete(() {})
        .catchError((err) {
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
