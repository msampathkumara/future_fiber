import 'package:flutter/material.dart';
import 'package:smartwind/C/App.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/StandardTicket.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/V/Home/Tickets/StandardFiles/factory_selector.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';

import '../../../../M/Enums.dart';
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

      reloadData().then((value) {
        DB.setOnDBChangeListener(() {
          loadData();
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
  TextEditingController searchController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _loading
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
                    loadData();
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
                searchController: searchController,
                delay: 300,
                onSearchTextChanged: (text) {
                  searchText = text;
                  loadData();
                },
                onSubmitted: (text) {},
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

  List<StandardTicket> currentFileList = [];

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
          loadData();
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

  getTicketListByCategory(List<StandardTicket> _filesList) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              return reloadData();
            },
            child: _filesList.length == 0
                ? Center(child: Text(searchText.isEmpty ? "No Tickets Found" : "⛔ Work Ticket not found.\n Please contact  Ticket Checking department", textScaleFactor: 1.5))
                : Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        StandardTicket ticket = (_filesList[index]);
                        print("#####################################################################################################");
                        print(ticket.toJson());
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
                                color: ticket.isHold == 1 ? Colors.black12 : Colors.white,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.all(Radius.circular(20))),
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

  List<StandardTicket> _allFilesList = [];

  List<StandardTicket> _upwindFilesList = [];
  List<StandardTicket> _oDFilesList = [];
  List<StandardTicket> _nylonFilesList = [];
  List<StandardTicket> _oEMFilesList = [];
  List<StandardTicket> _noPoolFilesList = [];

  List<StandardTicket> _load(Production selectedProduction, section, _showAllTickets, searchText, {crossProduction = false}) {
    List<StandardTicket> l = HiveBox.standardTicketsBox.values.where((t) {
      if (selectedProduction == Production.None) {
        if ((t.production ?? "") != "") {
          return false;
        }
      } else if (selectedProduction != Production.All) {
        if (selectedProduction.getValue() != t.production) {
          return false;
        }
      }

      if (!searchByText(t, searchText)) {
        return false;
      }
      return true;
    }).toList();
    l.sort((a, b) => (a.toJson()[listSortBy] ?? "").compareTo((b.toJson()[listSortBy] ?? "")));
    // if (listSortDirectionIsDESC) {
    //   l = l.reversed.toList();
    // }
    return l;
  }

  setLoading(l) {
    setState(() {
      _loading = l;
    });
  }

  bool _loading = true;

  loadData() {
    print('---------------------------------------------- Start loading');
    _selectedTabIndex = _tabBarController!.index;
    String searchText = this.searchText.toLowerCase();

    if (_showAllTickets) {
      _allFilesList = _load(Production.All, 0, true, searchText);
      _upwindFilesList = _load(Production.Upwind, 0, true, searchText);
      _oDFilesList = _load(Production.OD, 0, true, searchText);
      _nylonFilesList = _load(Production.Nylon, 0, true, searchText);
      _oEMFilesList = _load(Production.OEM, 0, true, searchText);
      _noPoolFilesList = _load(Production.None, 0, true, searchText);
      listsArray = [_allFilesList, _upwindFilesList, _oDFilesList, _nylonFilesList, _oEMFilesList, _noPoolFilesList];
    } else {
      _allFilesList = _load(Production.All, 0, false, searchText);
    }
    currentFileList = listsArray[_selectedTabIndex];
    print('---------------------------------------------- end loading');
  }

  bool searchBySection(t, section) {
    return (!t.openSections.contains(section.toString()));
  }

  searchByProduction(StandardTicket t, Production selectedProduction) {
    if (selectedProduction == Production.All) {
      return true;
    }
    if (selectedProduction == Production.None && ((t.production ?? '').trim().isEmpty)) {
      return true;
    }
    return (t.production ?? '').toLowerCase() == selectedProduction.getValue().toLowerCase();
  }

  bool searchByText(t, searchText) {
    if (searchText.isNotEmpty) {
      if ((t.mo ?? "").toLowerCase().contains(searchText) || (t.mo ?? "").toLowerCase().contains(searchText)) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  Future<void> showTicketOptions(StandardTicket ticket, BuildContext context1) async {
    print(ticket.toJson());
    await showModalBottomSheet<void>(
      context: context1,
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
                        showFactories(ticket, context1);
                        // await Navigator.push(context1, MaterialPageRoute(builder: (context) => changeFactory(ticket)));
                        // Navigator.of(context).pop();
                      }),
                  ListTile(
                      title: Text("Delete"),
                      leading: Icon(Icons.delete_forever, color: Colors.red),
                      onTap: () async {
                        // TODO add link
                        OnlineDB.apiPost("tickets/standard/delete", {'id': ticket.id.toString()}).then((response) async {
                          print(response.data);
                        });
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

  Future<void> showFactories(StandardTicket ticket, BuildContext context1) async {
    print(ticket.toJson());
    await showModalBottomSheet<void>(
      context: context1,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          height: 650,
          child: FactorySelector(ticket.production ?? "", (factory) {
            print(factory);
          }),
        );
      },
    );
  }

  Future reloadData() async {
    await HiveBox.getDataFromServer();
    loadData();
    setLoading(false);
  }
}
