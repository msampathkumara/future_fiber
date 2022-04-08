import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/V/Home/UserManager/UpdateUserDetails.dart';
import 'package:smartwind/V/Home/UserManager/user_manager_user_list.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';

import '../../../M/Enums.dart';
import '../../../M/hive.dart';
import '../../../V/Widgets/UserImage.dart';
import '../../Styles/styles.dart';

part 'webUserManager.table.dart';

class WebUserManager extends StatefulWidget {
  const WebUserManager({Key? key}) : super(key: key);

  @override
  State<WebUserManager> createState() => _WebUserManagerState();
}

class _WebUserManagerState extends State<WebUserManager> {
  var _controller = TextEditingController();
  bool loading = false;
  DessertDataSource? _dataSource;
  String searchText = "";

  Production selectedProduction = Production.All;

  NsUser? _selectedUser;

  late DbChangeCallBack _dbChangeCallBack;

  get nsUserCount => _dataSource == null ? 0 : _dataSource?.rowCount;

  @override
  void initState() {
    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update user');
      if (mounted) {
        loadData();
      }
    }, context, collection: DataTables.Users);

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
                Spacer(),
                Wrap(children: [
                  SizedBox(
                    child: SearchBar(
                        onSearchTextChanged: (text) {
                          searchText = text;
                          loadData();
                        },
                        searchController: _controller),
                    width: 300,
                  ),
                ])
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: webUserManagerTable(
                      onInit: (DessertDataSource dataSource) {
                        _dataSource = dataSource;
                      },
                      onTap: (NsUser nsUser) {
                        _selectedUser = nsUser;
                        setState(() {});
                      },
                    )),
              ),
              SizedBox(width: 8),
              if (_selectedUser != null) getUserDetailsUi(_selectedUser!)
            ],
          ),
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
                          HiveBox.getDataFromServer().then((value) => loadData());
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${nsUserCount}",
                      textScaleFactor: 1.1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 36)
                ],
              ),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await UpdateUserDetails(new NsUser()).show(context);
              HiveBox.getDataFromServer();
            },
            child: const Icon(Icons.add),
            backgroundColor: Colors.green));
  }

  void loadData() {
    var nsUser = HiveBox.usersBox.values.where((nsUser) {
      return ((nsUser.name).toLowerCase().contains(searchText.toLowerCase()));
    }).toList();
    _dataSource?.setData(nsUser);
  }

  addItemsBottomSheetMenu(context) {
    showModalBottomSheet(
        constraints: kIsWeb ? BoxConstraints(maxWidth: 600) : null,
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
                Padding(padding: const EdgeInsets.all(16.0), child: Text("Add", textScaleFactor: 1.2)),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ListView(
                        children: [
                          ListTile(
                            title: Text("Add Tickets"),
                            selectedTileColor: Colors.black12,
                            leading: Icon(Icons.picture_as_pdf),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text("Add Data Sheet"),
                            selectedTileColor: Colors.black12,
                            leading: Icon(Icons.list_alt_rounded),
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

  var lt = TextStyle(fontSize: 12, color: Colors.grey);
  var lst = TextStyle(fontSize: 16, color: Colors.black);
  var cp = EdgeInsets.only(bottom: 0.0, top: -10);

  getUserDetailsUi(NsUser selectedUser) {
    return Material(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
                    Text("${selectedUser.name}", style: TextStyle(color: Colors.black), textScaleFactor: 0.7),
                    Text("${selectedUser.uname}", style: TextStyle(color: Colors.blue), textScaleFactor: 0.7),
                  ],
                ),
              )),
          body: ListView(
            children: [
              ListTile(title: Text('Type', style: lt), subtitle: Text('${selectedUser.utype}', style: lst)),
              ListTile(title: Text('EPF', style: lt), subtitle: Text('${selectedUser.epf}', style: lst)),
              ListTile(title: Text('Phone', style: lt), subtitle: Text('${selectedUser.phone}', style: lst)),
              ListTile(title: Text('Email', style: lt), subtitle: Text('${selectedUser.emailAddress}', style: lst))
            ],
          ),
          bottomNavigationBar: BottomAppBar(
              shape: CircularNotchedRectangle(),
              color: Colors.white,
              child: IconTheme(
                data: IconThemeData(color: Colors.black),
                child: Row(
                  children: [
                    IconButton(tooltip: "Edit", icon: Icon(Icons.edit_rounded), onPressed: () {}),
                    const Spacer(),
                    IconButton(tooltip: "Delete", icon: Icon(Icons.delete_rounded, color: Colors.red), onPressed: () {}),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
