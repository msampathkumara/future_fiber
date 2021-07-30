import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Home/UserManager/AddNfcCard.dart';
import 'package:smartwind/V/Home/UserManager/AddUser.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';

import 'UpdateUserDetails.dart';
import 'UserDetails.dart';
import 'UserPermissions.dart';

class UserManager extends StatefulWidget {
  UserManager({Key? key}) : super(key: key);

  @override
  _UserManagerState createState() {
    return _UserManagerState();
  }
}

class _UserManagerState extends State<UserManager> with SingleTickerProviderStateMixin {
  var database;
  late int _selectedTabIndex;

  var _themeColor = Colors.orange;

  late bool NfcIsAvailable;

  var idToken;

  List<NsUser> filteredAllUsersList = [];

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _TabBarcontroller = TabController(length: tabs.length, vsync: this);
      _TabBarcontroller!.addListener(() {
        print("Selected Index: " + _TabBarcontroller!.index.toString());
      });

      getDataFromServer();

      NfcManager.instance.isAvailable().then((value) {
        NfcIsAvailable = value;
      });
    });
  }

  late List listsArray;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<String>(
      future: getJwt(), // a Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Please wait its loading...'));
        } else {
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}');
          else
            return Scaffold(
                appBar: AppBar(
                  actions: <Widget>[
                    PopupMenuButton<String>(
                      onSelected: (s) {
                        print(s);
                        _showAllTickets = !_showAllTickets;
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
                  toolbarHeight: 150,
                  backgroundColor: _themeColor,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    "User Manager",
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
                        print("SEARCHING FOR ${searchText}");
                      });
                    },
                    onSubmitted: (text) {},
                    OnBarcode: (barcode) {
                      print("xxxxxxxxxxxxxxxxxx ${barcode}");
                    },
                  ),
                  centerTitle: true,
                ),
                body: getBody(),
                bottomNavigationBar: BottomAppBar(
                    shape: CircularNotchedRectangle(),
                    color: _themeColor,
                    child: IconTheme(
                      data: IconThemeData(color: Colors.white),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              currentFileList.length.toString(),
                              textScaleFactor: 1.1,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const Spacer()
                        ],
                      ),
                    )),
                floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
                floatingActionButton: OpenContainer(
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    closedElevation: 2,
                    closedColor: _themeColor,
                    transitionDuration: Duration(milliseconds: 500),
                    openBuilder: (BuildContext context, void Function({Object? returnValue}) action) {
                      return AddUser();
                    },
                    closedBuilder: (BuildContext context, void Function() action) {
                      return InkWell(
                          child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.person_add_outlined, size: 24, color: Colors.white),
                      ));
                    }));
        }
      },
    );
  }

  String listSortBy = "uptime";
  String sorted_by = "Date";
  String searchText = "";
  var subscription;
  bool _showAllTickets = false;
  List<Map> currentFileList = [];

  final tabs = ["All", "Upwind", "OD", "Nylon", "OEM", "No Pool"];
  TabController? _TabBarcontroller;

  // getBody() {
  //   return _TabBarcontroller == null
  //       ? Container()
  //       : DefaultTabController(
  //           length: tabs.length,
  //           child: Scaffold(
  //             backgroundColor: Colors.white,
  //             appBar: AppBar(
  //               toolbarHeight: 50,
  //               automaticallyImplyLeading: false,
  //               backgroundColor: _themeColor,
  //               elevation: 4.0,
  //               bottom: TabBar(
  //                 controller: _TabBarcontroller,
  //                 indicatorWeight: 4.0,
  //                 indicatorColor: Colors.white,
  //                 isScrollable: true,
  //                 tabs: [
  //                   for (final tab in tabs) Tab(text: tab),
  //                 ],
  //               ),
  //             ),
  //             body: TabBarView(
  //               controller: _TabBarcontroller,
  //               children: [
  //                 GetTicketListByCategoty(AllUsersList),
  //                 GetTicketListByCategoty(UpwindUsersList),
  //                 GetTicketListByCategoty(ODUsersList),
  //                 GetTicketListByCategoty(NylonUsersList),
  //                 GetTicketListByCategoty(OEMUsersList),
  //                 GetTicketListByCategoty(NoPoolUsersList),
  //               ],
  //             ),
  //           ),
  //         );
  // }

  getBody() {
    return _TabBarcontroller == null ? Container() : Scaffold(backgroundColor: Colors.white, body: GetTicketListByCategoty(filteredAllUsersList));
  }

  final int CAT_ALL = 0;
  final int CAT_UPWIND = 1;
  final int CAT_OD = 2;
  final int CAT_NYLON = 3;
  final int CAT_OEM = 4;

  // var indicator = new GlobalKey<RefreshIndicatorState>();

  GetTicketListByCategoty(List<NsUser> FilesList) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              return getDataFromServer();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: FilesList.length,
                itemBuilder: (BuildContext context, int index) {
                  NsUser nsUser = FilesList[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: () async {
                      await showUserOptions(nsUser, context);
                      setState(() {});
                    },
                    onTap: () {
                      UserDetails.show(context, nsUser);
                    },
                    onDoubleTap: () async {
                      // print(await ticket.getLocalFileVersion());
                      // ticket.open(context);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                          radius: 24.0,
                          backgroundImage: NetworkImage(Server.getServerApiPath("users/getImage?img=" + nsUser.img + "&size=62"),
                              headers: {"authorization": '$idToken'}),
                          backgroundColor: Colors.transparent),
                      title: Text(nsUser.name),
                      subtitle: Text("#" + nsUser.uname),
                      trailing: Wrap(children: []),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
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

  List<NsUser> AllUsersList = [];
  List<NsUser> UpwindUsersList = [];
  List<NsUser> ODUsersList = [];
  List<NsUser> NylonUsersList = [];
  List<NsUser> OEMUsersList = [];
  List<NsUser> NoPoolUsersList = [];

  Future<void> showUserOptions(NsUser nsUser, BuildContext context1) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration:
              BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          height: 500,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                      radius: 24.0,
                      backgroundImage: NetworkImage(Server.getServerApiPath("users/getImage?img=" + nsUser.img + "&size=48"),
                          headers: {"authorization": '$idToken'}),
                      backgroundColor: Colors.transparent),
                  title: Text(nsUser.name),
                  subtitle: Text("#" + nsUser.uname),
                ),
                Divider(),
                if (NfcIsAvailable)
                  ListTile(
                    title: Text("Add ID Card"),
                    leading: Icon(Icons.nfc_outlined),
                    onTap: () async {
                      Navigator.of(context).pop();
                      showAddNfcDialog(nsUser);
                    },
                  ),
                ListTile(
                  title: Text("Edit"),
                  subtitle: Text("Update user details"),
                  leading: Icon(Icons.edit),
                  onTap: () async {
                    UpdateUserDetails.show(context, nsUser);
                  },
                ),
                ListTile(
                  title: Text("Permissions"),
                  subtitle: Text("Update,Add or Remove Permissions"),
                  leading: Icon(Icons.gpp_good_outlined),
                  onTap: () async {
                    UserPermissions.show(context, nsUser);
                  },
                ),
                Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  void reloadData() {
    DB.getDB().then((value) async {
      database = value;
      // loadData().then((value) {
      //   setState(() {});
      // });
    });
  }

  Future<void> getDataFromServer() {
    var t = DateTime.now().millisecondsSinceEpoch;
    return OnlineDB.apiGet("users/getUsers", {"uptime": "0"}).then((response) {
      Map res = (json.decode(response.body) as Map);
      List users = (res["users"] ?? []);

      users.forEach((user) {
        print(user);
        print("--------------------------------------");
      });

      AllUsersList = List<NsUser>.from(users.map((model) => NsUser.fromJson(model)));
      filterUsers();

      setState(() {});
    });
  }

  void showAddNfcDialog(nsUser) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddNfcCard(nsUser);
        });
  }

  Future<String> getJwt() async {
    final user = FirebaseAuth.instance.currentUser;
    idToken = await user!.getIdToken();
    print('id token === $idToken');
    return (idToken);
  }

  String searchKey = "";

  void filterUsers() {
    if (searchKey.isEmpty) {
      filteredAllUsersList = AllUsersList;
    }
  }
}
