import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smartwind_future_fibers/C/DB/DB.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/M/NsUser.dart';
import 'package:deebugee_plugin/DeeBugeeSearchBar.dart';
import 'package:smartwind_future_fibers/Web/V/UserManager/UpdateUserDetails.dart';
import 'package:smartwind_future_fibers/Web/Widgets/ShowMessage.dart';

import '../../../../C/Api.dart';
import '../../../../C/DB/hive.dart';
import '../../../../M/EndPoints.dart';
import '../../../../Web/V/UserManager/GenaratePassword.dart';
import '../../Widgets/UserImage.dart';
import 'AddNfcCard.dart';
import 'GenerateOTP.dart';
import 'UserDetails.dart';
import 'UserPermissions.dart';

part 'user_manager_user_list_options.dart';

class UserManagerUserList extends StatefulWidget {
  const UserManagerUserList({Key? key}) : super(key: key);

  @override
  _UserManagerUserListState createState() => _UserManagerUserListState();
}

class _UserManagerUserListState extends State<UserManagerUserList> with TickerProviderStateMixin {
  // var database;

  var _themeColor = Colors.orange;
  final _deactivateThemeColor = Colors.grey;
  final _activeThemeColor = Colors.orange;

  late bool nfcIsAvailable;

  List<NsUser> filteredAllUsersList = [];

  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool _setIdCards = false;

  var _showDeactivatedUsers = false;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: ${_tabBarController!.index}");
      });

      NfcManager.instance.isAvailable().then((value) {
        nfcIsAvailable = value;
      });
    });
    _refreshIndicatorKey.currentState?.show();

    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update tickets');
      if (mounted) {
        filterUsers();
      }
    }, context, collection: DataTables.users);
    filterUsers();
  }

  late DbChangeCallBack _dbChangeCallBack;
  late List listsArray;

  @override
  void dispose() {
    super.dispose();
    _dbChangeCallBack.dispose();
  }

  TextEditingController searchController = TextEditingController();

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
                    CheckedPopupMenuItem<String>(value: "deactivatedUsers", checked: _showDeactivatedUsers, child: const Text("Deactivated Users")),
                    if (!_showDeactivatedUsers) CheckedPopupMenuItem<String>(value: "id", checked: _setIdCards, child: const Text("Set ID Cards")),
                  ])
        ],
        elevation: 0.0,
        toolbarHeight: 100,
        backgroundColor: _themeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text("User Manager", textScaleFactor: 1.2),
            if (_showDeactivatedUsers) const Text("(Deactivated Users)", textScaleFactor: 0.7),
          ],
        ),
        bottom: DeeBugeeSearchBar(
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
          shape: const CircularNotchedRectangle(),
          color: _themeColor,
          child: IconTheme(
            data: const IconThemeData(color: Colors.white),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    filteredAllUsersList == allUsersList ? filteredAllUsersList.length.toString() : "${filteredAllUsersList.length.toString()}/${allUsersList.length.toString()}",
                    textScaleFactor: 1.1,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const Spacer()
              ],
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      // floatingActionButton: _showDeactivatedUsers
      //     ? null
      //     : OpenContainer(
      //     closedShape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(50.0),
      //         ),
      //         closedElevation: 2,
      //         closedColor: _themeColor,
      //         transitionDuration: const Duration(milliseconds: 500),
      //         openBuilder: (BuildContext context, void Function({Object? returnValue}) action) {
      //           return const AddUser();
      //         },
      //         closedBuilder: (BuildContext context, void Function() action) {
      //           return const InkWell(
      //               child: Padding(
      //             padding: EdgeInsets.all(16.0),
      //             child: Icon(Icons.person_add_outlined, size: 24, color: Colors.white),
      //           ));
      //         })
    );
  }

  String listSortBy = "uptime";
  String sortedBy = "Date";
  String searchText = "";

  // var subscription;
  List<Map> currentFileList = [];

  final tabs = ["All", "EC-SIX", "AERO-SIX", "FIBRE LITE", "Machine Shop", "PULTRUSION", "TACO", "No Pool"];
  TabController? _tabBarController;

  getBody() {
    return _tabBarController == null ? Container() : Scaffold(backgroundColor: Colors.white, body: getTicketListByCategory(filteredAllUsersList, context));
  }

  getTicketListByCategory(List<NsUser> filesList, _context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              return HiveBox.getDataFromServer(cleanUsers: true);
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
                      await showUserOptions(nsUser, context, _context, nfcIsAvailable, onRemoveNfcCard: () {
                        nsUser.removeNfcCard(context, onDone: () {
                          setState(() {});
                        });
                      });
                      setState(() {});
                    },
                    onTap: () {
                      UserDetails(nsUser).show(context);
                    },
                    leading: UserImage(nsUser: nsUser, radius: 24, key: Key("${nsUser.uptime}")),
                    title: Text(nsUser.name),
                    subtitle: Text("#${nsUser.uname}"),
                    trailing: Wrap(children: [
                      if (nsUser.isDeactivated)
                        const Icon(
                          Icons.person_off_outlined,
                        ),
                      if (_setIdCards)
                        IconButton(
                            icon: Icon(Icons.badge_outlined, color: nsUser.hasNfc == 0 ? Colors.grey : Colors.green),
                            tooltip: ' ',
                            onPressed: () {
                              setState(() {
                                showAddNfcDialog(nsUser, _context);
                              });
                            })
                    ]),
                  );
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

  List<NsUser> allUsersList = [];

  Future<void> filterUsers() async {
    allUsersList = HiveBox.usersBox.values.toList();
    print('Searching users $searchText __ ${allUsersList.length} __ $_showDeactivatedUsers');

    if (searchText.trim().isEmpty) {
      filteredAllUsersList = allUsersList.where((element) => element.isDeactivated == (_showDeactivatedUsers)).toList();
    } else {
      filteredAllUsersList = allUsersList.where((nsUser) {
        return (_showDeactivatedUsers == nsUser.isDeactivated) &&
            searchText.containsInArrayIgnoreCase([nsUser.uname, nsUser.nic, nsUser.name, nsUser.emailAddress, nsUser.phone, nsUser.getEpf().toString()]);
      }).toList();
    }
    setState(() {});
  }
}
