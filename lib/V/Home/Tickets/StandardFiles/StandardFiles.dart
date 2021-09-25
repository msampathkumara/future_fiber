import 'package:flutter/material.dart';
import 'package:smartwind/C/App.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/StandardTicket.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';

import 'StandardTicketInfo.dart';

class StandardFiles extends StatefulWidget {
  StandardFiles({Key? key}) : super(key: key);

  @override
  _StandardFilesState createState() {
    return _StandardFilesState();
  }
}

class _StandardFilesState extends State<StandardFiles> with TickerProviderStateMixin {
  var database;
  late int _selectedTabIndex;
  bool loading = true;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: " + _tabBarController!.index.toString());
      });

      loadOnlineData().then((value) {
        DB.setOnDBChangeListener(() {
          reloadData();
        }, context, collection: DataTables.standardTickets);
      });
    });
    App.getAppInfo();
  }

  late List listsArray;

  @override
  void dispose() {
    super.dispose();
  }

  bool _showAllTickets = true;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
            Text("Loading")
          ])))
        : Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: (s) {
                    print(s);
                    _showAllTickets = !_showAllTickets;

                    // tabs = ["All", "Upwind", "OD", "Nylon", "OEM", "No Pool"];

                    _tabBarController = TabController(length: tabs.length, vsync: this);
                    loadData().then((value) => setState(() {}));
                  },
                  itemBuilder: (BuildContext context) {
                    return {"Show All Tickets"}.map((String choice) {
                      return CheckedPopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                        checked: _showAllTickets,
                      );
                    }).toList();
                  },
                ),
              ],
              elevation: 0.0,
              toolbarHeight: 80,
              backgroundColor: Colors.green,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Standard Files",
                textScaleFactor: 1.2,
              ),
              bottom: SearchBar(
                onSearchTextChanged: (text) {
                  if (subscription != null) {
                    subscription.cancel();
                  }
                  searchText = text;

                  var future = new Future.delayed(const Duration(milliseconds: 300));
                  subscription = future.asStream().listen((v) {
                    print("SEARCHING FOR $searchText");
                    var t = DateTime.now().millisecondsSinceEpoch;
                    loadData().then((value) {
                      print("SEARCHING time ${(DateTime.now().millisecondsSinceEpoch - t)}");
                      t = DateTime.now().millisecondsSinceEpoch;
                      setState(() {});
                      print("load time ${(DateTime.now().millisecondsSinceEpoch - t)}");
                    });
                  });
                },
                onSubmitted: (text) {},
                onBarCode: (barcode) {
                  print("xxxxxxxxxxxxxxxxxx $barcode");
                },
              ),
              centerTitle: true,
            ),
            body: getBody(),
            bottomNavigationBar: BottomAppBar(
                shape: CircularNotchedRectangle(),
                color: Colors.green,
                child: IconTheme(
                  data: IconThemeData(color: Colors.white),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${currentFileList.length}",
                          textScaleFactor: 1.1,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Sorted by $sortedBy",
                        style: TextStyle(color: Colors.white),
                      ),
                      InkWell(
                        onTap: () {},
                        splashColor: Colors.red,
                        child: Ink(
                          child: IconButton(
                            icon: Icon(Icons.sort_outlined),
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

  String listSortBy = "uptime DESC";
  String sortedBy = "Date";
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
          loadData().then((value) {
            setState(() {});
          });
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Sort By",
                    textScaleFactor: 1.2,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ListView(
                        children: [
                          getListItem("Date", Icons.date_range_rounded, "uptime DESC"),
                          getListItem("Name", Icons.sort_by_alpha_rounded, "oe"),
                          getListItem("Usage", Icons.data_usage_outlined, "usedCount DESC")
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }

  final tabs = ["All", "Upwind", "OD", "Nylon", "OEM", "No Pool"];
  final tabsColors = [null, "Upwind", "OD", "Nylon", "OEM", "No Pool"];

  TabController? _tabBarController;

  getBody() {
    var l = tabs.length;
    print('tab length = $l');
    return _tabBarController == null
        ? Container()
        : DefaultTabController(
            length: tabs.length,
            child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  toolbarHeight: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.green,
                  elevation: 4.0,
                  bottom: TabBar(
                    controller: _tabBarController,
                    indicatorWeight: 4.0,
                    indicatorColor: Colors.white,
                    isScrollable: true,
                    tabs: [
                      for (final tab in tabs)
                        Tab(
                          child: Wrap(alignment: WrapAlignment.center, children: [
                            // Icon(
                            //   Icons.fiber_manual_record_outlined,
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 4, left: 2),
                              child: Text(tab),
                            )
                          ]),
                        ),
                    ],
                  ),
                ),
                body: TabBarView(controller: _tabBarController, children: [
                  getTicketListByCategory(_allFilesList),
                  getTicketListByCategory(_upwindFilesList),
                  getTicketListByCategory(_oDFilesList),
                  getTicketListByCategory(_nylonFilesList),
                  getTicketListByCategory(_oEMFilesList),
                  getTicketListByCategory(_noPoolFilesList),
                ])),
          );
  }

  getTicketListByCategory(List<Map<String, dynamic>> _filesList) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              return loadOnlineData().then((value) {
                // return loadData().then((value) {
                //   setState(() {});
                // });
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _filesList.length,
                itemBuilder: (BuildContext context, int index) {
                  StandardTicket ticket = StandardTicket.fromJson(_filesList[index]);
                  // print(ticket.toJson());
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: () async {
                      await showTicketOptions(ticket, context);
                      setState(() {});
                    },
                    onTap: () {
                      var ticketInfo = StandardTicketInfo(ticket);
                      ticketInfo.show(context);
                    },
                    onDoubleTap: () async {
                      ticket.open(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                          color: ticket.isHold == 1 ? Colors.black12 : Colors.white, border: Border.all(color: Colors.white), borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: ListTile(
                        leading: Text("${index + 1}"),
                        title: Text((ticket.oe ?? ""), style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(ticket.getUpdateDateTime()),
                        trailing: Wrap(children: []),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(height: 1, endIndent: 0.5, color: Colors.black12);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _allFilesList = [];

  List<Map<String, dynamic>> _upwindFilesList = [];
  List<Map<String, dynamic>> _oDFilesList = [];
  List<Map<String, dynamic>> _nylonFilesList = [];
  List<Map<String, dynamic>> _oEMFilesList = [];
  List<Map<String, dynamic>> _noPoolFilesList = [];

  Future<void> loadData() async {
    _selectedTabIndex = _tabBarController!.index;
    print('loadData listSortBy $listSortBy');

    // String canOpen = _showAllTickets ? " " : " and canOpen=1  and openSections like '%#1#%' ";

    NsUser? nsUser = await App.getCurrentUser();
    var section = nsUser!.section!.id;
    // String canOpen = _showAllTickets ? "  file=1 and completed=0" : " canOpen=1   and file=1   and completed=0 ";
    String canOpen = " ";
    String searchQ = " uptime > 0 ";
    if (searchText.isNotEmpty) {
      searchQ = "   oe like '%$searchText%'   ";
    }

    print('current user $section');
    // listSortBy = "uptime";

    _allFilesList = await database.rawQuery('SELECT * FROM standardTickets where  $searchQ   ' + canOpen + '   order by $listSortBy  ');

    _upwindFilesList = await database.rawQuery('SELECT * FROM standardTickets where $searchQ   ' + canOpen + ' and production=\'Upwind\' order by $listSortBy ');

    _oDFilesList = await database.rawQuery('SELECT * FROM standardTickets where $searchQ   ' + canOpen + ' and production=\'OD\' order by $listSortBy  ');

    _nylonFilesList = await database.rawQuery('SELECT * FROM standardTickets where $searchQ   ' + canOpen + ' and production=\'Nylon\' order by $listSortBy  ');

    _oEMFilesList = await database.rawQuery('SELECT * FROM standardTickets where $searchQ   ' + canOpen + ' and production=\'OEM\' order by $listSortBy  ');

    _noPoolFilesList = await database.rawQuery('SELECT * FROM standardTickets where $searchQ   ' + canOpen + ' and production is null or production=""  order by $listSortBy  ');

    listsArray = [_allFilesList, _upwindFilesList, _oDFilesList, _nylonFilesList, _oEMFilesList, _noPoolFilesList];
    currentFileList = listsArray[_selectedTabIndex];
    print(currentFileList.length);
  }

  Future<void> showTicketOptions(StandardTicket ticket, BuildContext context1) async {
    print(ticket.toJson());
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          height: 650,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(
                title: Text(ticket.mo ?? ticket.oe!),
                subtitle: Text(ticket.oe!),
              ),
              Divider(),
              Expanded(
                  child: Container(
                child: SingleChildScrollView(
                    child: Column(children: [
                  ListTile(
                      title: Text("Change Factory"),
                      leading: Icon(Icons.send_outlined, color: Colors.lightBlue),
                      onTap: () async {
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                      title: Text("Delete"),
                      leading: Icon(Icons.delete_forever, color: Colors.red),
                      onTap: () async {
                        Navigator.of(context).pop();
                      }),
                ])),
              ))
            ],
          ),
        );
      },
    );
  }

  Future reloadData() {
    return DB.getDB().then((value) async {
      database = value;
      return loadData().then((value) {
        try {
          this.setState(() {});
        } catch (e) {}
      });
    });
  }

  Future loadOnlineData() {
    return OnlineDB.updateStandardTicketsDB(context).then((response) async {
      loading = false;
      return reloadData();
    });
  }
}
