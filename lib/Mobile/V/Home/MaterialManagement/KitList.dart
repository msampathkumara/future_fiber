import 'package:flutter/material.dart';

import '../../../../C/Api.dart';
import '../../../../M/CPR/KIT.dart';
import '../../../../M/EndPoints.dart';
import '../../../../M/Enums.dart';
import '../../../../Web/V/MaterialManagement/KIT/KitView.dart';
import '../../Widgets/NoResultFoundMsg.dart';
import '../../Widgets/SearchBar.dart';

class KitList extends StatefulWidget {
  const KitList({Key? key}) : super(key: key);

  @override
  State<KitList> createState() => _KitListState();
}

class _KitListState extends State<KitList> {
  TextEditingController searchController = TextEditingController();

  String searchText = '';
  List<KIT> _kitList = [];
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
                _kitList = [];
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
            child: (_kitList.isEmpty && (!requested))
                ? Center(
                    child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.vertical,
                    children: [
                      // Text(searchText.isEmpty ? "No KITs Found" : "⛔ Work Ticket not found.\n Please contact  Ticket Checking department", textScaleFactor: 1.5),
                      Center(child: Container(padding: const EdgeInsets.all(20), child: const NoResultFoundMsg())),
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
                      itemCount: _kitList.length < dataCount ? _kitList.length + 1 : _kitList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_kitList.length == index) {
                          if (!requested && (!_dataLoadingError)) {
                            var x = ((_kitList.length) / 20);

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
                                                var x = ((_kitList.length) / 20);
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

                        KIT kit = (_kitList[index]);
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onLongPress: () async {},
                          onTap: () {
                            KitView(kit, (b) {}).show(context);
                          },
                          onDoubleTap: () async {},
                          child: Ink(
                            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: Container(
                              decoration: BoxDecoration(border: Border(left: BorderSide(color: kit.status.getColor(), width: 5))),
                              child: ListTile(
                                leading: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("${index + 1}")]),
                                title: Text((kit.ticket?.mo ?? "").trim().isEmpty ? (kit.ticket?.oe ?? "") : kit.ticket?.mo ?? "",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: kit.isTicketStarted ? Colors.green : null)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [Text(kit.ticket?.oe ?? "")],
                                ),
                                trailing: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  direction: Axis.vertical,
                                  children: [
                                    Text("${kit.client}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(kit.suppliers.join(',')),
                                    Text(kit.kitType ?? "", style: const TextStyle(color: Colors.red))
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

    return Api.get(EndPoints.materialManagement_kit_search, {
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
        _kitList = [];
      }

      _dataLoadingError = false;
      _kitList.addAll(KIT.fromJsonArray(res.data["kits"]));

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
    return getData(page, 20, 'cpr.id', true);
  }
}
