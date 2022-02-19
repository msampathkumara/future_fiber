import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

import 'AddNfcCard.dart';
import 'AddUser.dart';
import 'UpdateUserDetails.dart';
import 'UserDetails.dart';
import 'UserPermissions.dart';

class UserManagerUserList extends StatefulWidget {
  var idToken;

  UserManagerUserList(this.idToken, {Key? key}) : super(key: key);

  @override
  _UserManagerUserListState createState() => _UserManagerUserListState();
}

class _UserManagerUserListState extends State<UserManagerUserList> with TickerProviderStateMixin {
  var database;

  var _themeColor = Colors.orange;
  var _deactivateThemeColor = Colors.grey;
  var _activeThemeColor = Colors.orange;

  late bool nfcIsAvailable;

  var idToken;

  List<NsUser> filteredAllUsersList = [];

  var _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool _setIdCards = false;

  var _showDeactivatedUsers = false;

  @override
  initState() {
    super.initState();
    idToken = widget.idToken;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: " + _tabBarController!.index.toString());
      });

      NfcManager.instance.isAvailable().then((value) {
        nfcIsAvailable = value;
      });
    });
    _refreshIndicatorKey.currentState?.show();
    reloadData().then((value) {
      if (_refreshIndicatorKey.currentState != null) _refreshIndicatorKey.currentState!.deactivate();
    });
    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      // reloadData();
      print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
    }, context, collection: DataTables.Users);
  }

  late DbChangeCallBack _dbChangeCallBack;
  late List listsArray;

  @override
  void dispose() {
    super.dispose();
    _dbChangeCallBack.dispose();
  }

  TextEditingController searchController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    _themeColor = _showDeactivatedUsers ? _deactivateThemeColor : _activeThemeColor;

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton<String>(
                onSelected: (s) async {
                  if (s == "deactivatedUsers") {
                    _showDeactivatedUsers = !_showDeactivatedUsers;
                    _setIdCards = false;
                    await filterUsers();
                  } else if (s == "id") {
                    _setIdCards = !_setIdCards;
                  }
                  print(s);
                  setState(() {});
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      CheckedPopupMenuItem<String>(value: "deactivatedUsers", child: Text("Deactivated Users"), checked: _showDeactivatedUsers),
                      if (!_showDeactivatedUsers) CheckedPopupMenuItem<String>(value: "id", child: Text("Set ID Cards"), checked: _setIdCards),
                    ])
          ],
          elevation: 0.0,
          toolbarHeight: 80,
          backgroundColor: _themeColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            children: [
              Text(
                "User Manager",
                textScaleFactor: 1.2,
              ),
              if (_showDeactivatedUsers)
                Text(
                  "(Deactivated Users)",
                ),
            ],
          ),
          bottom: SearchBar(
            searchController: searchController,
            onSearchTextChanged: (text) {
              searchText = text;
              print("SEARCHING FOR $searchText");
              filterUsers();
            },
            onSubmitted: (text) {},
            // onBarCode: (barcode) {
            //   print("xxxxxxxxxxxxxxxxxx $barcode");
            // },
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
                      filteredAllUsersList == AllUsersList ? filteredAllUsersList.length.toString() : "${filteredAllUsersList.length.toString()}/${AllUsersList.length.toString()}",
                      textScaleFactor: 1.1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer()
                ],
              ),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: _showDeactivatedUsers
            ? null
            : OpenContainer(
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

  String listSortBy = "uptime";
  String sortedBy = "Date";
  String searchText = "";
  var subscription;
  List<Map> currentFileList = [];

  final tabs = ["All", "Upwind", "OD", "Nylon", "OEM", "No Pool"];
  TabController? _tabBarController;

  getBody() {
    return _tabBarController == null ? Container() : Scaffold(backgroundColor: Colors.white, body: getTicketListByCategory(filteredAllUsersList));
  }

  final int CAT_ALL = 0;
  final int CAT_UPWIND = 1;
  final int CAT_OD = 2;
  final int CAT_NYLON = 3;
  final int CAT_OEM = 4;

  // var indicator = new GlobalKey<RefreshIndicatorState>();

  getTicketListByCategory(List<NsUser> filesList) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              return reloadData();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: filesList.length,
                itemBuilder: (BuildContext context, int index) {
                  NsUser nsUser = filesList[index];
                  // print("nsUser.hasNfc ${nsUser.hasNfc}");
                  return ListTile(
                    onLongPress: () async {
                      await showUserOptions(nsUser, context);
                      setState(() {});
                    },
                    onTap: () {
                      UserDetails.show(context, nsUser);
                    },
                    leading: UserImage(nsUser: nsUser, radius: 24),
                    title: Text(nsUser.name),
                    subtitle: Text("#" + nsUser.uname),
                    trailing: Wrap(children: [
                      if (_setIdCards)
                        IconButton(
                            icon: Icon(Icons.badge_outlined, color: nsUser.hasNfc == 0 ? Colors.grey : Colors.green),
                            tooltip: ' ',
                            onPressed: () {
                              setState(() {
                                showAddNfcDialog(nsUser);
                              });
                            })
                    ]),
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
          decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          height: 500,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: UserImage(nsUser: nsUser, radius: 24),
                  title: Text(nsUser.name),
                  subtitle: Text("#" + nsUser.uname),
                ),
                Divider(),
                if (nfcIsAvailable)
                  ListTile(
                    title: Text(nsUser.userHasNfc() ? "Remove ID Card" : "Add ID Card"),
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.nfc_outlined),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      if (nsUser.userHasNfc()) {
                      } else {
                        showAddNfcDialog(nsUser);
                      }
                    },
                  ),
                ListTile(
                  title: Text("Edit"),
                  subtitle: Text("Update user details"),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.edit),
                  ),
                  onTap: () async {
                    UpdateUserDetails.show(context, nsUser);
                  },
                ),
                ListTile(
                  title: Text("Permissions"),
                  subtitle: Text("Update,Add or Remove Permissions"),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.gpp_good_outlined),
                  ),
                  onTap: () async {
                    UserPermissions.show(context, nsUser);
                  },
                ),
                ListTile(
                  title: Text(nsUser.isDisabled ? "Activate User" : "Deactivate User"),
                  subtitle: Text(nsUser.isDisabled ? "Activate all activities on system for this user" : "Deactivate all activities on system for this user"),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.person_off_rounded),
                  ),
                  onTap: () async {
                    //  TODO , add server call
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

  Future<void> reloadData() {
    filterUsers();
    return DB.updateDatabase(context).then((value) {
      return filterUsers();
    });
  }

  void showAddNfcDialog(nsUser) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddNfcCard(nsUser);
        });
  }

  Future<void> filterUsers() async {
    String q = " select * from users ";
    if (_showDeactivatedUsers) {
      q = " select * from users where deactivate=1";
    }
    await DB.getDB().then((value) => value!.rawQuery(q).then((users) {
          AllUsersList = List<NsUser>.from(users.map((model) => NsUser.fromJson(model)));
        }));

    if (searchText.trim().isEmpty) {
      filteredAllUsersList = AllUsersList;
    } else {
      filteredAllUsersList = AllUsersList.where((element) {
        return (element.name.toLowerCase().contains(searchText) |
            element.uname.toLowerCase().contains(searchText) |
            element.emailAddress.toLowerCase().contains(searchText) |
            element.phone.toLowerCase().contains(searchText));
      }).toList();
    }
    setState(() {});
  }
}
