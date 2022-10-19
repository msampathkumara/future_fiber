import 'package:flutter/material.dart';

import '../../../../C/Api.dart';
import '../../../../M/CPR/CPR.dart';
import '../../../../M/Enums.dart';
import '../../../../Web/V/MaterialManagement/CPR/webCpr.dart';
import '../../../../Web/V/MaterialManagement/CPR/webCprView.dart';
import '../../Widgets/NoResultFoundMsg.dart';
import '../../Widgets/SearchBar.dart';

class CprList extends StatefulWidget {
  const CprList({Key? key}) : super(key: key);

  @override
  State<CprList> createState() => _CprListState();
}

class _CprListState extends State<CprList> {
  TextEditingController searchController = TextEditingController();

  String searchText = '';

  List<CPR> _cprList = [];

  bool requested = false;

  num dataCount = 0;

  bool _dataLoadingError = false;

  Production selectedProduction = Production.All;
  String selectedStatus = 'All';

  @override
  initState() {
    loadData(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: const <Widget>[],
          elevation: 0.0,
          bottom: SearchBar(
              delay: 300,
              searchController: searchController,
              onSearchTextChanged: (text) {
                searchText = text;
                _cprList = [];

                print("SEARCHING FOR $searchText");

                loadData(0);
              }),
          centerTitle: true,
        ),
        body: getBody());
  }

  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  getBody() {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              return loadData(0);
            },
            child: (_cprList.isEmpty && (!requested))
                ? Center(
                    child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.vertical,
                    children: [
                      Center(child: Container(padding: const EdgeInsets.all(20), child: const NoResultFoundMsg())),
                      // Text(searchText.isEmpty ? "No CPRs Found" : "⛔ Work Ticket not found.\n Please contact  Ticket Checking department", textScaleFactor: 1.5),
                      ElevatedButton(
                          onPressed: () {
                            loadData(0);
                          },
                          child: const Text("Reload"))
                    ],
                  ))
                : Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _cprList.length < dataCount ? _cprList.length + 1 : _cprList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_cprList.length == index) {
                          if (!requested && (!_dataLoadingError)) {
                            var x = ((_cprList.length) / 20);

                            loadData(x.toInt());
                          }
                          return SizedBox(
                              height: 100,
                              child: Center(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: SizedBox(
                                          height: 48,
                                          width: 48,
                                          child: InkWell(
                                            onTap: () {
                                              if (_dataLoadingError) {
                                                setState(() {
                                                  _dataLoadingError = false;
                                                });
                                                var x = ((_cprList.length) / 20);
                                                loadData(x.toInt());
                                              }
                                            },
                                            child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(100.0),
                                                ),
                                                child: Padding(
                                                    padding: const EdgeInsets.all(12.0),
                                                    child: !_dataLoadingError
                                                        ? const CircularProgressIndicator(color: Colors.red, strokeWidth: 2)
                                                        : const Icon(
                                                            Icons.refresh_rounded,
                                                            size: 18,
                                                          ))),
                                          )))));
                        }

                        CPR cpr = (_cprList[index]);
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onLongPress: () async {
                            await showCprOptions(cpr, context, context, () {
                              loadData(0);
                            });
                            setState(() {});
                          },
                          onTap: () {
                            CprView(cpr, (b) {}).show(context);
                          },
                          onDoubleTap: () async {},
                          child: Ink(
                            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: Container(
                              decoration: BoxDecoration(border: Border(left: BorderSide(color: cpr.status.getColor(), width: 5))),
                              child: ListTile(
                                leading: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("${index + 1}")]),
                                title: Text((cpr.ticket?.mo ?? "").trim().isEmpty ? (cpr.ticket?.oe ?? "") : cpr.ticket?.mo ?? "",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: cpr.isTicketStarted ? Colors.green : null)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cpr.ticket?.oe ?? ""),
                                    Text(cpr.shortageType ?? "", style: const TextStyle(color: Colors.blue)),
                                  ],
                                ),
                                trailing: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  direction: Axis.vertical,
                                  children: [
                                    Text("${cpr.client}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(cpr.suppliers.join(',')),
                                    Text(cpr.cprType ?? "", style: const TextStyle(color: Colors.red))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(
                          height: 1,
                          endIndent: 0.5,
                          color: Colors.black12,
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future getData(page, count, sortedBy, sortedAsc) {
    requested = true;

    return Api.get("materialManagement/cpr/search", {
      'production': selectedProduction.getValue(),
      'status': selectedStatus,
      'sortDirection': sortedAsc ? "asc" : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'searchText': searchText
    }).then((res) {
      dataCount = res.data["count"];
      if (page == 0) {
        _cprList = [];
      }

      _dataLoadingError = false;
      _cprList.addAll(CPR.fromJsonArray(res.data["cprs"]));

      setState(() {});
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
                getData(page, count, sortedBy, sortedAsc);
              })));
      setState(() {
        _dataLoadingError = true;
      });
    });
  }

  Future loadData(int page) {
    return getData(page, 20, 'mo', true);
  }
}
