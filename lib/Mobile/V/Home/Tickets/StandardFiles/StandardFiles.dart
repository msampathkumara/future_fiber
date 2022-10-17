import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/M/StandardTicket.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/Mobile/V/Widgets/SearchBar.dart';

import '../../../../../C/Api.dart';
import '../../../../../M/Enums.dart';
import '../../../../../M/Ticket.dart';
import '../../../../../globals.dart';
import '../../../Widgets/NoResultFoundMsg.dart';
import 'StandardTicketInfo.dart';
import 'factory_selector.dart';

class StandardFiles extends StatefulWidget {
  const StandardFiles({Key? key}) : super(key: key);

  @override
  _StandardFilesState createState() {
    return _StandardFilesState();
  }
}

class _StandardFilesState extends State<StandardFiles> with TickerProviderStateMixin {
  bool loading = true;

  late DbChangeCallBack _dbChangeCallBack;

  List<Production> _productions = [];
  List<StandardTicket> currentFileList = [];

  @override
  initState() {
    super.initState();
    _productions = [Production.All, Production.Upwind, Production.OD, Production.Nylon_Standard, Production.OEM];
    tabs = _productions.map<String>((e) => e.getValue()).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: ${_tabBarController!.index}");
        currentFileList = listsMap[_productions[_tabBarController!.index]];
        setState(() {});
      });

      reloadData().then((value) {});
    });

    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update tickets');
      if (mounted) {
        loadData();
      }
    }, context, collection: DataTables.standardTickets);
  }

  @override
  void dispose() {
    _dbChangeCallBack.dispose();
    super.dispose();
  }

  // late List listsArray;

  // bool _showAllTickets = true;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
            Text("Loading")
          ]))
        : Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              toolbarHeight: 80,
              backgroundColor: Colors.green,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text("Standard Files", textScaleFactor: 1.2),
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
                shape: const CircularNotchedRectangle(),
                color: Colors.green,
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("${currentFileList.length}", textScaleFactor: 1.1, style: const TextStyle(color: Colors.white)),
                      ),
                      const Spacer(),
                      Text("Sorted by $sortedBy", style: const TextStyle(color: Colors.white)),
                      InkWell(
                        onTap: () {},
                        splashColor: Colors.red,
                        child: Ink(
                          child: IconButton(
                            icon: const Icon(Icons.sort_outlined),
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
  bool isAsc = true;

  void _sortByBottomSheetMenu() {
    getListItem(String title, icon, key) {
      return ListTile(
        title: Text(title),
        selectedTileColor: Colors.black12,
        selected: listSortBy == key,
        leading: icon is IconData ? Icon(icon) : icon,
        trailing: listSortBy == key
            ? isAsc
                ? const Icon(Icons.arrow_drop_up_outlined)
                : const Icon(Icons.arrow_drop_down_outlined)
            : null,
        onTap: () {
          listSortBy = key;
          sortedBy = title;
          isAsc = !isAsc;
          print('isAsc $isAsc');
          Navigator.pop(context);
          loadData();
        },
      );
    }

    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
        context: context,
        builder: (builder) {
          return Container(
            color: Colors.transparent,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Sort By", textScaleFactor: 1.2),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ListView(
                        children: [
                          getListItem("Date", Icons.date_range_rounded, "uptime"),
                          getListItem("Name", Icons.sort_by_alpha_rounded, "oe"),
                          getListItem("Usage", Icons.data_usage_outlined, "usedCount")
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }

  var tabs = [];
  final tabsColors = [null, "Upwind", "OD", 'Nylon Standard', "OEM", "No Pool"];

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
                body: TabBarView(controller: _tabBarController, children: listsMap.values.map<Widget>((e) => getTicketListByCategory(e)).toList())));
  }

  getTicketListByCategory(List<StandardTicket> _filesList) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              return reloadData();
            },
            child: _filesList.isEmpty
                // ? Center(child: Text(searchText.isEmpty ? "No Tickets Found" : "⛔ Work Ticket not found.\n Please contact  Ticket Checking department", textScaleFactor: 1.5))
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(padding: const EdgeInsets.all(20), child: const NoResultFoundMsg()),
                      ElevatedButton(
                          onPressed: () {
                            reloadData();
                          },
                          child: const Text("Reload"))
                    ],
                  ))
                : Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        StandardTicket ticket = (_filesList[index]);
                        // print("#####################################################################################################");
                        // print(ticket.toJson());
                        return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onLongPress: () async {
                              await showStandardTicketOptions(ticket, context);
                              setState(() {});
                            },
                            onTap: () {
                              var ticketInfo = StandardTicketInfo(ticket);
                              ticketInfo.show(context);
                            },
                            onDoubleTap: () async {
                              Ticket.open(context, ticket);
                            },
                            child: Ink(
                                decoration: BoxDecoration(
                                    color: ticket.isHold == 1 ? Colors.black12 : Colors.white,
                                    border: Border.all(color: Colors.white),
                                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                                child: ListTile(
                                    leading: Text("${index + 1}"),
                                    title: Text((ticket.oe ?? ""), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(ticket.getUpdateDateTime()),
                                    trailing: Text("${ticket.usedCount}"))));
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(height: 1, endIndent: 0.5, color: Colors.black12);
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  List<StandardTicket> _load(Production selectedProduction, section, _showAllTickets, searchText) {
    print('HiveBox.standardTicketsBox.values${HiveBox.standardTicketsBox.values.length}');
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
    if (isAsc) {
      l.sort((a, b) => (a.toJson()[listSortBy] ?? "").compareTo((b.toJson()[listSortBy] ?? "")));
    } else {
      l.sort((b, a) => (a.toJson()[listSortBy] ?? "").compareTo((b.toJson()[listSortBy] ?? "")));
    }
    return l;
  }

  setLoading(l) {
    setState(() {
      _loading = l;
    });
  }

  bool _loading = true;
  Map listsMap = {};

  loadData() {
    print('---------------------------------------------- Start loading');
    String searchText = this.searchText.toLowerCase();

    for (var element in _productions) {
      listsMap[element] = _load(element, 0, true, searchText);
    }
    currentFileList = listsMap[_productions[0]];
    print('---------------------------------------------- end loading');
    setState(() {});
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

  bool searchByText(t, String searchText) {
    if (searchText.isNotEmpty) {
      return searchText.containsInArrayIgnoreCase([t.oe]);
    }
    return true;
  }

  Future reloadData() async {
    await HiveBox.getDataFromServer();
    loadData();
    setLoading(false);
  }
}

Future<void> showStandardTicketOptions(StandardTicket ticket, BuildContext context1) async {
  print(ticket.toJson());
  await showModalBottomSheet<void>(
    constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
    context: context1,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 650,
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
                  title: const Text("Change Factory"),
                  leading: const Icon(Icons.send_outlined, color: Colors.lightBlue),
                  onTap: () async {
                    Navigator.of(context).pop();
                    showFactories(ticket, context1);
                    // await Navigator.push(context1, MaterialPageRoute(builder: (context) => changeFactory(ticket)));
                    // Navigator.of(context).pop();
                  }),
              ListTile(
                  title: const Text("Delete"),
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  onTap: () async {
                    snackBarKey.currentState?.showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        width: 500,
                        backgroundColor: Colors.red,
                        content: Row(
                          children: [
                            const Text("Do You really want to delete this standard ticket ?"),
                            const Spacer(),
                            TextButton(
                                onPressed: () {
                                  snackBarKey.currentState?.showSnackBar(const SnackBar(behavior: SnackBarBehavior.floating, width: 200, content: Text('Deleting')));
                                  Api.post(EndPoints.tickets_standard_delete, {'id': ticket.id.toString()}).then((response) async {
                                    print(response.data);
                                    snackBarKey.currentState?.showSnackBar(
                                        const SnackBar(behavior: SnackBarBehavior.floating, width: 200, backgroundColor: Colors.green, content: Text('Delete Successfully')));
                                  });
                                },
                                child: const Text("Yes"))
                          ],
                        ),
                        action: SnackBarAction(
                            label: 'No',
                            textColor: Colors.white,
                            onPressed: () {
                              snackBarKey.currentState?.removeCurrentSnackBar();
                            })));

                    Navigator.of(context).pop();
                  }),
            ])))
          ],
        ),
      );
    },
  );
}

Future<void> showFactories(StandardTicket ticket, BuildContext context1) async {
  print(ticket.toJson());
  await showModalBottomSheet<void>(
    constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
    context: context1,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 650,
        child: FactorySelector(ticket.production ?? "", onSelect: (factory) async {
          await Api.post(EndPoints.tickets_standard_changeFactory, {'production': factory, 'ticketId': ticket.id});
          // await HiveBox.getDataFromServer();

          print(factory);
        }),
      );
    },
  );
}
