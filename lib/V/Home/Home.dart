import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/C/App.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Home/CPR/CPRList.dart';
import 'package:smartwind/V/Home/CurrentUser/CurrentUserDetails.dart';
import 'package:smartwind/V/Home/HR/HRSystem.dart';
import 'package:smartwind/V/Home/Tickets/Print/PrintManager.dart';
import 'package:smartwind/V/Home/Tickets/ProductionPool/ProductionPool.dart';
import 'package:smartwind/V/Login/Login.dart';
import 'package:smartwind/V/Login/SectionSelector.dart';

import 'About.dart';
import 'Admin/AdminCpanel.dart';
import 'BlueBook/BlueBook.dart';
import 'J109.dart';
import 'Tickets/FinishedGoods/FinishedGoods.dart';
import 'Tickets/StandardFiles/StandardFiles.dart';
import 'UserManager/UserManager.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() {
    return _HomeState();
  }
}

enum MenuItems { logout, dbReload, changeSection, cpanel }

class _HomeState extends State<Home> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NsUser? nsUser;

  var appVersion;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.subscribeToTopic('file_update');
    FirebaseMessaging.instance.subscribeToTopic('TicketDbReset');
    FirebaseMessaging.instance.subscribeToTopic('userUpdates');
    DB.updateDatabase(context);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (json.decode(message.data["FILE_DB_UPDATE"]) != null) {
        DB.updateDatabase(context);
      } else if (json.decode(message.data["updateTicketDB"]) != null) {
        DB.updateDatabase(context, reset: true);
        print('--------------------------RESEING DATABASE-----------------');
      } else if (json.decode(message.data["userUpdates"]) != null) {
        DB.updateDatabase(context, reset: true);
        print('--------------------------UPDATING USER DATABASE-----------------');
      }
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    App.getCurrentUser().then((value) {
      if (value != null) {
        final user = FirebaseAuth.instance.currentUser;
        user!.getIdToken().then((t) {
          idToken = t;
          nsUser = value;
          setState(() {});
        });
      } else {
        _logout();
      }
    });
    PackageInfo.fromPlatform().then((appInfo) {
      print(appInfo);
      appVersion = appInfo.version;
    });
  }

  var idToken;

  @override
  void dispose() {
    super.dispose();
  }



  void _showMarkedAsDoneSnackbar(bool? isMarkedAsDone) {
    if (isMarkedAsDone ?? false)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Marked as done!'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: nsUser == null
          ? Center(
              child: Container(
                  child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [CircularProgressIndicator(), Padding(padding: const EdgeInsets.all(16.0), child: Text("Loading", textScaleFactor: 1))],
            )))
          : Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                toolbarHeight: 150,
                title: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: ListTile(
                    leading: CircleAvatar(radius: 24.0, backgroundImage: NsUser.getUserImage(nsUser), backgroundColor: Colors.transparent),
                    title: Text(nsUser!.name, textScaleFactor: 1.2),
                    subtitle: nsUser!.section != null ? Text("${nsUser!.section!.sectionTitle} @ ${nsUser!.section!.factory}") : Text(""),
                    trailing: _currentUserOprionMenu(),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CurrentUserDetails(nsUser!)));
                    },
                  ),
                ),
              ),
              body: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                child: Stack(
                  children: [
                    new Positioned(
                      bottom: 10,
                      right: 0,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.dstATop),
                        child: Image.asset(
                          "assets/north_sails-logo.png",
                          width: 350,
                        ),
                      ),
                    ),
                    Align(
                      alignment: FractionalOffset.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 48.0),
                        child: Wrap(
                          direction: Axis.horizontal,crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _OpenContainerWrapper(
                              closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                return _menuButton(
                                    openContainer,
                                    Icon(
                                      Icons.precision_manufacturing_outlined,
                                      size: 100,
                                    ),
                                    "Production Pool");
                              },
                              openWidget: ProductionPool(),
                              onClosed: _showMarkedAsDoneSnackbar,
                            ),
                            _OpenContainerWrapper(
                              closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                return _menuButton(
                                    openContainer,
                                    Icon(
                                      Icons.local_mall_rounded,
                                      color: Colors.amber,
                                      size: 100,
                                    ),
                                    "CPR");
                              },
                              openWidget: CPRList(),
                              onClosed: _showMarkedAsDoneSnackbar,
                            ),
                            _OpenContainerWrapper(
                                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                  return _menuButton(openContainer, Icon(Icons.inventory_2_rounded, color: Colors.deepOrange, size: 100), "Finished Goods");
                                },
                                openWidget: FinishedGoods(),
                                onClosed: _showMarkedAsDoneSnackbar),
                            _OpenContainerWrapper(
                              closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                return _menuButton(
                                    openContainer,
                                    Icon(
                                      Icons.collections_bookmark_outlined,
                                      size: 100,
                                    ),
                                    "Standard Library");
                              },
                              openWidget: StandardFiles(),
                              onClosed: _showMarkedAsDoneSnackbar,
                            ),
                            _OpenContainerWrapper(
                                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                  return _menuButton(
                                      openContainer,
                                      Icon(
                                        Icons.people_outline_outlined,
                                        size: 100,
                                      ),
                                      "User Manager");
                                },
                                openWidget: UserManager(),
                                onClosed: _showMarkedAsDoneSnackbar),
                            _OpenContainerWrapper(
                                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                  return _menuButton(openContainer, Icon(Icons.print_rounded, size: 100, color: Colors.blue), "Print");
                                },
                                openWidget: PrintManager(),
                                onClosed: _showMarkedAsDoneSnackbar),
                            _OpenContainerWrapper(
                                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                  return _menuButton(openContainer, Icon(Icons.verified_rounded, size: 100, color: Colors.green), "QA & QC");
                                },
                                openWidget: PrintManager(),
                                onClosed: _showMarkedAsDoneSnackbar),
                            _OpenContainerWrapper(
                                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                  return _menuButton(openContainer, Icon(Icons.subject_rounded, size: 100, color: Colors.pinkAccent), "J109");
                                },
                                openWidget: J109(),
                                onClosed: _showMarkedAsDoneSnackbar),
                            _OpenContainerWrapper(
                                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                  return _menuButton(openContainer, Icon(Icons.menu_book_rounded, size: 100, color: Colors.blueAccent), "Blue Book");
                                },
                                openWidget: BlueBook(),
                                onClosed: _showMarkedAsDoneSnackbar),
                            _OpenContainerWrapper(
                                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                  return _menuButton(openContainer, Icon(Icons.groups_rounded, size: 100, color: Colors.orange), "HR System");
                                },
                                openWidget: HESystem(),
                                onClosed: _showMarkedAsDoneSnackbar),
                          ],
                        ),
                      ),
                    ),
                    new Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: new Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Center(
                                child: OpenContainer(
                                    closedElevation: 0,
                                    transitionDuration: Duration(milliseconds: 500),
                                    openBuilder: (BuildContext context, void Function({Object? returnValue}) action) {
                                      return About();
                                    },
                                    closedBuilder: (BuildContext context, void Function() action) {
                                      return Chip(
                                        avatar: CircleAvatar(
                                          backgroundColor: Colors.grey.shade800,
                                          child: Image.asset("assets/north_sails-logox50.png", width: 50),
                                        ),
                                        label: Text('NS Smart Wind $appVersion '),
                                      );
                                    })))),
                  ],
                ),
              ),
            ),
    );
  }

  void show(Widget window) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => window));
  }

  Future<void> _logout() async {
    FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
  }

  _currentUserOprionMenu() {
    return PopupMenuButton<MenuItems>(
      onSelected: (MenuItems result) async {
        if (result == MenuItems.logout) {
          _logout();
        } else if (result == MenuItems.dbReload) {
          await DB.dropDatabase();
          await DB.loadDB();
          DB.updateDatabase(context, showLoadingDialog: true, reset: true);
        } else if (result == MenuItems.changeSection) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SectionSelector(nsUser!)), (Route<dynamic> route) => false);
        } else if (result == MenuItems.cpanel) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminCpanel()));
        }

        setState(() {

        });
        // print(result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItems>>[
        const PopupMenuItem<MenuItems>(
          value: MenuItems.dbReload,
          child: Text('Reload Database'),
        ),
        const PopupMenuItem<MenuItems>(
          value: MenuItems.logout,
          child: Text('Logout'),
        ),
        const PopupMenuItem<MenuItems>(
          value: MenuItems.changeSection,
          child: Text('Change Section'),
        ),
        if (nsUser!.utype == 'admin')
          const PopupMenuItem<MenuItems>(
            value: MenuItems.cpanel,
            child: Text('Cpanel'),
          )
      ],
    );
  }

  _menuButton(openContainer, image, title) {
    return SizedBox(
        height: 200,
        width: 200,
        child: InkWell(
            onTap: openContainer,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              Expanded(child: Container(height: 170, child: Center(child: image))),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Text(
                    title,
                    textScaleFactor: 1.2,
                  ),
                ),
              )
            ])));
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper({
    required this.openWidget,
    required this.closedBuilder,
    required this.onClosed,
  });

  final Widget openWidget;
  final CloseContainerBuilder closedBuilder;
  final ClosedCallback<bool?> onClosed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OpenContainer<bool>(
        transitionType: ContainerTransitionType.fade,
        openBuilder: (BuildContext context, VoidCallback _) {
          return openWidget;
        },
        onClosed: (x) {
          print('ccccccccccccccccccccccccccccccc');
        },
        tappable: false,
        closedBuilder: closedBuilder,
      ),
    );
  }
}
