import 'package:flutter/material.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/QC.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';
import 'package:smartwind/Web/V/QC/webTicketQView.dart';

class QCList extends StatefulWidget {
  const QCList();

  @override
  _QCListState createState() => _QCListState();
}

class _QCListState extends State<QCList> with TickerProviderStateMixin {
  var database;
  var themeColor = Colors.green;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData(0);
    });
  }

  late List listsArray;

  @override
  void dispose() {
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: const <Widget>[],
          elevation: 0.0,
          toolbarHeight: 80,
          backgroundColor: themeColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("QA & QC", textScaleFactor: 1.2),
          bottom: SearchBar(
              searchController: searchController,
              delay: 300,
              onSearchTextChanged: (text) {
                searchText = text;
                _ticketQcList = [];

                loadData(0).then((value) {
                  setState(() {});
                });
              },
              onSubmitted: (text) {}),
          centerTitle: true,
        ),
        body: getBody(),
        bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            color: themeColor,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: Row(
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: Text("${_ticketQcList.length}/$dataCount", textScaleFactor: 1.1, style: const TextStyle(color: Colors.white))),
                  const Spacer(),
                  Text("Sorted by $sortedBy", style: const TextStyle(color: Colors.white)),
                  InkWell(
                    onTap: () {},
                    splashColor: Colors.red,
                    child: Ink(
                      child: IconButton(
                        icon: const Icon(Icons.sort_by_alpha_rounded),
                        onPressed: () {
                          _sortByBottomSheetMenu();
                        },
                      ),
                    ),
                  )
                ],
              ),
            )));
  }

  String listSortBy = "dnt";
  String sortedBy = "dnt";
  String searchText = "";
  var subscription;
  List<Map> currentFileList = [];

  void _sortByBottomSheetMenu() {
    getListItem(String title, icon, key) {
      return ListTile(
        title: Text(title),
        selectedTileColor: Colors.black12,
        selected: listSortBy == key,
        leading: icon is IconData ? Icon(icon) : icon,
        onTap: () {
          listSortBy = key;
          sortedBy = title;
          Navigator.pop(context);
          _ticketQcList = [];
          loadData(0);
          setState(() {});
        },
      );
    }

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        context: context,
        builder: (builder) {
          return Container(
            color: Colors.transparent,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Sort By",
                    textScaleFactor: 1.2,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ListView(
                        children: [getListItem("Date", Icons.date_range_rounded, "dnt"), getListItem("Ticket", Icons.sort_by_alpha_rounded, "ticketId")],
                      )),
                ),
              ],
            ),
          );
        });
  }

  getBody() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          backgroundColor: themeColor,
          elevation: 5,
          actions: const [],
          title: Wrap(
            spacing: 5,
            children: [_typeChip(Type.All), _typeChip(Type.QC), _typeChip(Type.QA)],
          ),
        ),
        body: _getTicketsList());
  }

  _getTicketsList() {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              return loadData(0).then((value) {
                setState(() {});
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _ticketQcList.length < dataCount ? _ticketQcList.length + 1 : _ticketQcList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (_ticketQcList.length == index) {
                    if (!requested && (!_dataLoadingError)) {
                      var x = ((_ticketQcList.length) / 20);

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
                                            var x = ((_ticketQcList.length) / 20);
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
                                                    : const Icon(Icons.refresh_rounded, size: 18))))))));
                  }

                  QC _ticketQc = (_ticketQcList[index]);
                  var tc = _ticketQc.isQc() ? Colors.redAccent : Colors.black;
                  Section? section = _ticketQc.getSection();
                  return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () async {
                        // await showTicketOptions(ticketPrint, context);
                        // setState(() {});
                      },
                      onTap: () async {
                        // await Navigator.push(context, MaterialPageRoute(builder: (context) => QCView(_ticketQc)));
                        WebTicketQView(_ticketQc.ticket ?? Ticket(), true).show(context);
                      },
                      onDoubleTap: () async {
                        // print(await ticket.getLocalFileVersion());
                        // ticket.open(context);
                      },
                      child: Ink(
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                            color: _ticketQc.isQc() ? Colors.redAccent : Colors.white,
                            width: 3.0,
                          ))),
                          child: ListTile(
                              leading: Container(width: 50, alignment: Alignment.center, height: double.infinity, child: Text("${index + 1}", textAlign: TextAlign.center)),
                              title: Text(_ticketQc.ticket!.getName(), style: TextStyle(fontWeight: FontWeight.bold, color: tc)),
                              subtitle: Wrap(direction: Axis.vertical, children: [
                                if ((_ticketQc.ticket!.mo ?? "").trim().isNotEmpty) Text((_ticketQc.ticket!.oe ?? "")),
                                Text("${_ticketQc.getDateTime()}"),
                              ]),
                              // subtitle: Text(ticket.fileVersion.toString()),
                              trailing: Wrap(alignment: WrapAlignment.center, direction: Axis.vertical, children: [
                                Text(section?.factory ?? ''),
                                Text(section?.sectionTitle ?? '')
                                // UserImage(nsUser: NsUser.fromId(_ticketQc.userId), radius: 20),
                                // Text(_ticketQc.user != null ? _ticketQc.user!.uname : "", textScaleFactor: 1)
                              ]))));
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 5,
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

  Future<void> showTicketOptions(Ticket ticket, BuildContext context1) async {
    print(ticket.toJson());
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          height: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(
                title: Text(ticket.mo ?? ticket.oe!),
                subtitle: Text(ticket.oe!),
              ),
              const Divider(),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                ListTile(
                    title: const Text("Send Ticket"),
                    leading: const Icon(Icons.send_rounded, color: Colors.lightBlue),
                    onTap: () async {
                      await ticket.sharePdf(context);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    title: const Text("Delete"),
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    onTap: () async {
                      Navigator.of(context).pop();
                    }),
              ])))
            ],
          ),
        );
      },
    );
  }

  bool requested = false;
  int dataCount = 0;
  List<QC> _ticketQcList = [];
  bool _dataLoadingError = false;

  Future loadData(int page) {
    requested = true;
    return OnlineDB.apiGet(
            "tickets/qc/getList", {'type': _selectedType.getValue(), 'sortDirection': "desc", 'sortBy': listSortBy, 'pageIndex': page, 'pageSize': 20, 'searchText': searchText})
        .then((res) {
      print(res.data);
      List qcs = res.data["qcs"];
      dataCount = res.data["count"];

      for (var element in qcs) {
        _ticketQcList.add(QC.fromJson(element));
      }
      final ids = _ticketQcList.map((e) => e.id).toSet();
      _ticketQcList.retainWhere((x) => ids.remove(x.id));
      _dataLoadingError = false;
      setState(() {});
    }).whenComplete(() {
      setState(() {
        requested = false;
      });
    }).catchError((err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(err.toString()),
            action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  loadData(page);
                })));
        setState(() {
          _dataLoadingError = true;
        });
        throw err;
      }
    });
  }

  Type _selectedType = Type.All;

  _typeChip(Type p) {
    return FilterChip(
        selectedColor: Colors.white,
        checkmarkColor: themeColor,
        label: Text(
          p.getValue(),
          style: TextStyle(color: _selectedType == p ? themeColor : Colors.black),
        ),
        selected: _selectedType == p,
        onSelected: (bool value) {
          _selectedType = p;
          _ticketQcList = [];
          loadData(0);
          setState(() {});
        });
  }
}
