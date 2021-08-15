import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/Server.dart';
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
  late int _selectedTabIndex;

  var _themeColor = Colors.orange;

  late bool NfcIsAvailable;

  var idToken;

  List<NsUser> filteredAllUsersList = [];

  var _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool _setIdCards = false;

  @override
  initState() {
    super.initState();
    idToken = widget.idToken;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _TabBarcontroller = TabController(length: tabs.length, vsync: this);
      _TabBarcontroller!.addListener(() {
        print("Selected Index: " + _TabBarcontroller!.index.toString());
      });

      NfcManager.instance.isAvailable().then((value) {
        NfcIsAvailable = value;
      });
    });
    _refreshIndicatorKey.currentState?.show();
    reloadData().then((value) {
      if (_refreshIndicatorKey.currentState != null) _refreshIndicatorKey.currentState!.deactivate();
    });
    _dbChangeCallBack=  DB.setOnDBChangeListener(() {
      reloadData();
    },context,collection: DataTables.Users);
  }
  late DbChangeCallBack _dbChangeCallBack;
  late List listsArray;

  @override
  void dispose() {
    super.dispose();
    _dbChangeCallBack.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton<String>(
                onSelected: (s) {
                  print(s);
                  setState(() {
                    _setIdCards = !_setIdCards;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[CheckedPopupMenuItem<String>(value: "id", child: Text("Set ID Cards"), checked: _setIdCards)])
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
                filterUsers();
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

  String listSortBy = "uptime";
  String sorted_by = "Date";
  String searchText = "";
  var subscription;
  bool _showAllTickets = false;
  List<Map> currentFileList = [];

  final tabs = ["All", "Upwind", "OD", "Nylon", "OEM", "No Pool"];
  TabController? _TabBarcontroller;

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
            key: _refreshIndicatorKey,
            onRefresh: () {
              return reloadData();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: FilesList.length,
                itemBuilder: (BuildContext context, int index) {
                  NsUser nsUser = FilesList[index];
                  print("nsUser.hasNfc ${nsUser.hasNfc}");
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
                      leading: UserImage(nsUser: nsUser),
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
          decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          height: 500,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                      radius: 24.0,
                      backgroundImage: NetworkImage(Server.getServerApiPath("users/getImage?img=" + nsUser.img + "&size=48"), headers: {"authorization": '$idToken'}),
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



  Future<void> reloadData() {
    return DB.getDB().then((value) => value!.rawQuery(" select * from users ").then((users) {
          AllUsersList = List<NsUser>.from(users.map((model) => NsUser.fromJson(model)));
          filterUsers();
        }));

    // var t = DateTime.now().millisecondsSinceEpoch;
    // return OnlineDB.apiGet("users/getUsers", {"uptime": "0"}).then((response) {
    //   Map res = (json.decode(response.body) as Map);
    //   List users = (res["users"] ?? []);
    //
    //   users.forEach((user) {
    //     print(user);
    //     print("--------------------------------------");
    //   });
    //
    //   AllUsersList = List<NsUser>.from(users.map((model) => NsUser.fromJson(model)));
    //   filterUsers();
    // });
  }

  void showAddNfcDialog(nsUser) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddNfcCard(nsUser);
        });
  }

  void filterUsers() {
    if (searchText.trim().isEmpty) {
      filteredAllUsersList = AllUsersList;
    } else {
      filteredAllUsersList = AllUsersList.where((element) {
        return element.name.toLowerCase().contains(searchText) |
            element.uname.toLowerCase().contains(searchText) |
            element.emailAddress.toLowerCase().contains(searchText) |
            element.phone.toLowerCase().contains(searchText);
      }).toList();
    }
    setState(() {});
  }
}




