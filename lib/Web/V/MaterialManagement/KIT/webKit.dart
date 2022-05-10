import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/M/CPR/KIT.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/Web/Styles/styles.dart';
import 'package:smartwind/Web/V/MaterialManagement/KIT/ScanReadyKits.dart';
import 'package:smartwind/Web/V/MaterialManagement/KIT/SendKits.dart';

import '../../../../C/DB/DB.dart';
import '../../../Widgets/myDropDown.dart';
import 'KitView.dart';

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

  bool _dataLoadingError = false;

  late DessertDataSourceAsync _dataSource;

  final _status = ['All', 'Sent', 'Ready', 'Pending', 'Order'];
  String selectedStatus = 'All';

  var _dbChangeCallBack;

  // get kitCount => _dataSource == null ? 0 : _dataSource?.rowCount;

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
    _dbChangeCallBack.dispose();
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
                Wrap(children: [
                  myDropDown<Production>(
                      items: Production.values,
                      elevation: 4,
                      lable: 'Production',
                      value: Production.None,
                      selectedText: (selectedItem) {
                        return (selectedItem as Production).getValue();
                      },
                      onSelect: (x) {
                        selectedProduction = x;
                        setState(() {});
                        loadData();
                        return selectedProduction.getValue();
                      },
                      onChildBuild: (Production item) {
                        return Text('${item.getValue()}');
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
                        return Text('${item}');
                      }),

                  //-------------------------------------------------------------------------------------------------

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
                  const VerticalDivider(color: Colors.red),
                  ElevatedButton.icon(
                      onPressed: () async {
                        await const ScanReadyKits().show(context);
                        loadData();
                      },
                      label: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text("Scan Ready Kits"),
                      ),
                      icon: const Icon(Icons.settings_overscan)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton.icon(
                        onPressed: () async {
                          await const SendKits().show(context);
                          loadData();
                        },
                        label: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text("Send"),
                        ),
                        icon: const Icon(Icons.send)),
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
              child: WebKITTable(onInit: (DessertDataSourceAsync dataSource) {
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
    return Api.get("materialManagement/kit/search", {
      'production': selectedProduction.getValue(),
      'status': selectedStatus,
      'sortDirection': sortedAsc ? "asc" : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'searchText': searchText
    }).then((res) {
      print(res.data);
      List kits = res.data["kits"];
      dataCount = res.data["count"];

      _dataLoadingError = false;
      var x = KIT.fromJsonArray(kits);
      setState(() {});
      return DataResponse(dataCount, x);
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
}
