import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/StandardTicket.dart';

import '../../../C/Api.dart';
import '../../../M/Enums.dart';
import '../../../M/Ticket.dart';
import '../../Styles/styles.dart';
import 'webStandardLibrary.table.dart';

class WebStandardLibrary extends StatefulWidget {
  const WebStandardLibrary({Key? key}) : super(key: key);

  @override
  State<WebStandardLibrary> createState() => _WebStandardLibraryState();
}

class _WebStandardLibraryState extends State<WebStandardLibrary> {
  var _controller = TextEditingController();
  bool loading = false;

  // DessertDataSource? _dataSource;
  String searchText = "";

  Production selectedProduction = Production.All;

  bool requested = false;

  int dataCount = 0;

  List<Ticket> _ticketList = [];

  bool _dataLoadingError = false;

  late DessertDataSourceAsync _dataSource;

  // get ticketCount => _dataSource == null ? 0 : _dataSource?.rowCount;

  @override
  void initState() {
    // getData(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Row(
              children: [
                Text("Standard Library", style: mainWidgetsTitleTextStyle),
                Spacer(),
                Wrap(children: [
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Production>(
                          value: selectedProduction,
                          selectedItemBuilder: (_) {
                            return Production.values.map<Widget>((Production item) {
                              return Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${item.getValue()}"),
                              ));
                            }).toList();
                          },
                          items: Production.values.map((Production value) {
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
                  SizedBox(width: 20),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                        height: 40,
                        width: 200,
                        child: TextFormField(
                          controller: _controller,
                          onChanged: (text) {
                            searchText = text;
                            loadData();
                          },
                          cursorColor: Colors.black,
                          decoration: new InputDecoration(
                              prefixIcon: Icon(Icons.search_rounded),
                              suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: _controller.clear),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 10, right: 15),
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
              child: WebStandardLibraryTable(onInit: (DessertDataSourceAsync dataSource) {
                _dataSource = dataSource;
              }, onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
                return getData(page, startingAt, count, sortedBy, sortedAsc);
              })),
        ),
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            color: Colors.green,
            child: IconTheme(
              data: IconThemeData(color: Colors.white),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {},
                    splashColor: Colors.red,
                    child: Ink(
                      child: IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          _dataSource.refreshDatasource();
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${0}",
                      textScaleFactor: 1.1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 36)
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

      tickets.forEach((element) {
        _ticketList.add(Ticket.fromJson(element));
      });
      final ids = _ticketList.map((e) => e.id).toSet();
      _ticketList.retainWhere((x) => ids.remove(x.id));
      _dataLoadingError = false;

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
      setState(() {
        _dataLoadingError = true;
      });
    });
  }
}
