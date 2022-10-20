import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/Mobile/V/Home/UserManager/user_manager_user_list.dart';
import 'package:smartwind/Mobile/V/Widgets/SearchBar.dart';
import 'package:smartwind/Web/V/UserManager/GenaratePassword.dart';
import 'package:smartwind/Web/V/UserManager/UpdateUserDetails.dart';

import '../../../M/Enums.dart';
import '../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../../../Mobile/V/Widgets/UserImage.dart';
import '../../Styles/styles.dart';

part 'webUserManager.table.dart';

enum UserFilters { none, locked, deactivated }

class WebUserManager extends StatefulWidget {
  const WebUserManager({Key? key}) : super(key: key);

  @override
  State<WebUserManager> createState() => _WebUserManagerState();
}

class _WebUserManagerState extends State<WebUserManager> {
  final _controller = TextEditingController();
  bool loading = true;
  UserManagerDataSource? _dataSource;
  String searchText = "";

  Production selectedProduction = Production.All;

  NsUser? _selectedUser;

  late DbChangeCallBack _dbChangeCallBack;

  final _scrollController = ScrollController();

  get nsUserCount => _dataSource == null ? 0 : _dataSource?.rowCount;

  @override
  void initState() {
    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update user');
      if (mounted) {
        loadData();
      }
    }, context, collection: DataTables.users);

    HiveBox.getDataFromServer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dbChangeCallBack.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Row(
              children: [
                Text("User Manager", style: mainWidgetsTitleTextStyle),
                const Spacer(),
                flagIcon(UserFilters.locked, Icons.lock_rounded, "Filter   Locked Account"),
                flagIcon(UserFilters.deactivated, Icons.no_accounts_rounded, "Filter Deactivated accounts"),
                const SizedBox(width: 50),
                Wrap(children: [
                  SizedBox(
                      width: 400,
                      child: SearchBar(
                          onSearchTextChanged: (text) {
                            searchText = text;
                            loadData();
                          },
                          searchController: _controller))
                ])
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, right: 16),
          child: Row(
            children: [
              Expanded(
                child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: WebUserManagerTable(
                      onInit: (UserManagerDataSource dataSource) {
                        _dataSource = dataSource;
                      },
                      onTap: (NsUser nsUser) {
                        _selectedUser = nsUser;
                        setState(() {});
                      },
                    )),
              ),
              const SizedBox(width: 8),
              if (_selectedUser != null) getUserDetailsUi(_selectedUser!)
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              UpdateUserDetails(NsUser()).show(context).then((NsUser? nsUser) async {
                if (nsUser != null) {
                  await GeneratePassword(nsUser).show(context);
                }
                HiveBox.getDataFromServer();
              });
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add)));
  }

  void loadData() {
    print('*************************************************************$dataFilter');
    var nsUser = HiveBox.usersBox.values.where((nsUser) {
      if (dataFilter != UserFilters.none) {
        if ((dataFilter == UserFilters.deactivated && nsUser.isNotDeactivated)) {
          return false;
        } else if (dataFilter == UserFilters.locked && nsUser.isNotLocked) {
          return false;
        }
      }
      if (dataFilter == UserFilters.none && nsUser.isDeactivated) {
        return false;
      }

      return (searchText.containsInArrayIgnoreCase([nsUser.name, nsUser.uname, nsUser.nic, nsUser.getEpf().toString()]));
    }).toList();
    _dataSource?.setData(nsUser);
    if (_selectedUser != null) {
      _selectedUser = HiveBox.usersBox.get(_selectedUser?.id);
    }
    loading = false;
    setState(() {});
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
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.all(16.0), child: Text("Add", textScaleFactor: 1.2)),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ListView(
                        children: [
                          ListTile(
                            title: const Text("Add Tickets"),
                            selectedTileColor: Colors.black12,
                            leading: const Icon(Icons.picture_as_pdf),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text("Add Data Sheet"),
                            selectedTileColor: Colors.black12,
                            leading: const Icon(Icons.list_alt_rounded),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }

  var lt = const TextStyle(fontSize: 12, color: Colors.grey);
  var lst = const TextStyle(fontSize: 16, color: Colors.black);
  var cp = const EdgeInsets.only(bottom: 0.0, top: -10);

  getUserDetailsUi(NsUser selectedUser) {
    return Material(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 350,
        child: Scaffold(
          appBar: AppBar(
              toolbarHeight: 200,
              backgroundColor: Colors.white,
              elevation: 4,
              title: Center(
                child: Column(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: UserImage(nsUser: selectedUser, radius: 64, padding: 2)),
                    Text(selectedUser.name, style: const TextStyle(color: Colors.black), textScaleFactor: 0.7),
                    Text(selectedUser.uname, style: const TextStyle(color: Colors.blue), textScaleFactor: 0.7),
                  ],
                ),
              )),
          body: Scrollbar(
            controller: _scrollController,
            child: ListView(
              controller: _scrollController,
              children: [
                ListTile(title: Text('NIC', style: lt), subtitle: Text(selectedUser.nic ?? '-', style: lst)),
                ListTile(title: Text('Type', style: lt), subtitle: Text(selectedUser.utype, style: lst)),
                ListTile(title: Text('EPF', style: lt), subtitle: Text(selectedUser.getEpf().toString(), style: lst)),
                ListTile(
                    title: Text('Phone', style: lt),
                    subtitle: Wrap(
                        children: (selectedUser.phone.split(','))
                            .map((e) => Padding(padding: const EdgeInsets.all(4.0), child: Chip(avatar: const Icon(Icons.phone), label: Text(e))))
                            .toList())),
                ListTile(
                    title: Text('Email(s)', style: lt),
                    subtitle: Wrap(
                        children: (selectedUser.emailAddress.split(','))
                            .map((e) => Padding(padding: const EdgeInsets.all(4.0), child: Chip(avatar: const Icon(Icons.alternate_email_rounded), label: Text(e))))
                            .toList())),
                ListTile(
                    title: Text('Sections', style: lt),
                    subtitle: Wrap(
                        children:
                            selectedUser.sections.map((e) => Padding(padding: const EdgeInsets.all(4.0), child: Chip(label: Text("${e.sectionTitle} @ ${e.factory}")))).toList()))
              ],
            ),
          ),
        ),
      ),
    );
  }

  UserFilters dataFilter = UserFilters.none;

  flagIcon(UserFilters filter, IconData? icon, tooltip, {String? text, Function? onPressed, bool? checked}) {
    checked = checked ?? dataFilter == filter;

    return IconButton(
      icon: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 16,
          child: (text != null)
              ? Text(text, style: TextStyle(color: checked ? Colors.red : Colors.black, fontWeight: FontWeight.bold))
              : Icon(icon, color: checked ? Colors.red : Colors.black, size: 20)),
      tooltip: tooltip,
      onPressed: () async {
        if (onPressed != null) {
          onPressed();
          return;
        }

        dataFilter = dataFilter == filter ? UserFilters.none : filter;
        loadData();
        setState(() {});
      },
    );
  }
}
