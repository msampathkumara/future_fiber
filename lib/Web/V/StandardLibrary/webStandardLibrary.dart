import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/StandardTicket.dart';

import '../../../C/Api.dart';
import '../../../C/DB/DB.dart';
import '../../../M/Enums.dart';
import '../../../M/Ticket.dart';
import '../../../V/Widgets/SearchBar.dart';
import '../../Styles/styles.dart';
import '../AddTicket/add_ticket.dart';
import 'webStandardLibrary.table.dart';

class WebStandardLibrary extends StatefulWidget {
  const WebStandardLibrary({Key? key}) : super(key: key);

  @override
  State<WebStandardLibrary> createState() => _WebStandardLibraryState();
}

class _WebStandardLibraryState extends State<WebStandardLibrary> {
  final _controller = TextEditingController();
  bool loading = false;

  // DessertDataSource? _dataSource;
  String searchText = "";

  Production selectedProduction = Production.All;

  bool requested = false;

  int dataCount = 0;

  List<Ticket> _ticketList = [];

  late DessertDataSourceAsync _dataSource;

  // get ticketCount => _dataSource == null ? 0 : _dataSource?.rowCount;
  late DbChangeCallBack _dbChangeCallBack;

  @override
  void initState() {
    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update tickets');
      if (mounted) {
        loadData();
      }
    }, context, collection: DataTables.standardTickets);

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
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartDocked,
      floatingActionButton: FloatingActionButton.small(
          onPressed: () async {
            addItemsBottomSheetMenu(context);
          },
          // backgroundColor: Colors.green,
          child: const Icon(Icons.add)),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          title: Row(
            children: [
              Text("Standard Library", style: mainWidgetsTitleTextStyle),
              const Spacer(),
              Wrap(children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 40,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Production>(
                        value: selectedProduction,
                        selectedItemBuilder: (_) {
                          return Production.values
                              .where((element) => (!['None', '38 Upwind', '38 Nylon', '38 OEM', '38 OD'].contains(element.getValue())))
                              .map<Widget>((Production item) {
                            return Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item.getValue()),
                            ));
                          }).toList();
                        },
                        items: Production.values.where((element) => (!['None', '38 Upwind', '38 Nylon', '38 OEM', '38 OD'].contains(element.getValue()))).map((Production value) {
                          return DropdownMenuItem<Production>(
                            value: value,
                            child: Text(value.getValue()),
                          );
                        }).toList(),
                        onChanged: (_) {
                          selectedProduction = _ ?? Production.All;
                          setState(() {});
                          loadData();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 40,
                    width: 200,
                    child: SearchBar(
                        onSearchTextChanged: (String text) {
                          searchText = text;
                          loadData();
                        },
                        delay: 300,
                        searchController: _controller),
                    // child: TextFormField(
                    //   controller: _controller,
                    //   onChanged: (text) {
                    //     searchText = text;
                    //     loadData();
                    //   },
                    //   cursorColor: Colors.black,
                    //   decoration: InputDecoration(
                    //       prefixIcon: const Icon(Icons.search_rounded),
                    //       suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: _controller.clear),
                    //       border: InputBorder.none,
                    //       focusedBorder: InputBorder.none,
                    //       enabledBorder: InputBorder.none,
                    //       errorBorder: InputBorder.none,
                    //       disabledBorder: InputBorder.none,
                    //       contentPadding: const EdgeInsets.only(left: 15, bottom: 11, top: 10, right: 15),
                    //       hintText: "Search Text"),
                    // )
                  ),
                ),
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
            child: WebStandardLibraryTable(onInit: (DessertDataSourceAsync dataSource) {
              _dataSource = dataSource;
            }, onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
              return getData(page, startingAt, count, sortedBy, sortedAsc);
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
      //             child: Text(
      //               "${0}",
      //               textScaleFactor: 1.1,
      //               style: TextStyle(color: Colors.white),
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

  Future<DataResponse> getData(page, startingAt, count, sortedBy, sortedAsc) {
    setState(() {
      requested = true;
    });
    return Api.get("tickets/standard/getList", {
      'production': selectedProduction.getValue(),
      'sortDirection': sortedAsc ? "asc" : "desc",
      'sortBy': sortedBy,
      'pageIndex': page,
      'pageSize': count,
      'searchText': searchText
    }).then((res) {
      print(res.data);
      List tickets = res.data["tickets"];
      dataCount = res.data["count"];

      for (var element in tickets) {
        _ticketList.add(Ticket.fromJson(element));
      }
      final ids = _ticketList.map((e) => e.id).toSet();
      _ticketList.retainWhere((x) => ids.remove(x.id));

      setState(() {});
      return DataResponse(dataCount, StandardTicket.fromJsonArray(tickets));
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

  addItemsBottomSheetMenu(context) {
    showModalBottomSheet(
        constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        context: context,
        builder: (builder) {
          return Container(
              color: Colors.transparent,
              child: Column(children: [
                const Padding(padding: EdgeInsets.all(16.0), child: Text("Add Standard Tickets", textScaleFactor: 1.2)),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: ListView(
                            children: Production.values
                                .where((element) => (!['All', 'None', '38 Upwind', '38 Nylon', '38 OEM', '38 OD'].contains(element.getValue())))
                                .map((e) => ListTile(
                                    title: Text(e.getValue()),
                                    selectedTileColor: Colors.black12,
                                    leading: const Icon(Icons.picture_as_pdf),
                                    onTap: () {
                                      Navigator.pop(context);
                                      AddTicket(standard: true, production: e).show(context);
                                    }))
                                .toList())))
              ]));
        });
  }
}
