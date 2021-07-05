import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/C/App.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Home/CurrentUser/CurrentUserDetails.dart';
import 'package:smartwind/V/Home/Tickets/ProductionPool/ProductionPool.dart';
import 'package:smartwind/V/Login/Login.dart';
import 'package:smartwind/V/Login/SectionSelector.dart';

import 'About.dart';
import 'Admin/AdminCpanel.dart';
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
  NsUser? nsUser ;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.subscribeToTopic('file_update');
    FirebaseMessaging.instance.subscribeToTopic('TicketDbReset');
    DB.updateDatabase();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (json.decode(message.data["FILE_DB_UPDATE"]) != null) {
        DB.updateDatabase();
      } else if (json.decode(message.data["updateTicketDB"]) != null) {
        DB.updateDatabase(reset: true);
        print('--------------------------RESEING DATABASE-----------------');
      }
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    App.getCurrentUser().then((value) {
      nsUser = value;
      setState(() {});
    });

    // SharedPreferences.getInstance().then((prefs) {
    //   var u = prefs.getString("user");
    //
    //   if (u != null) {
    //     setState(() {
    //       nsUser = NsUser.fromJson(json.decode(u));
    //     });
    //   } else {
    //     _logout();
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  var _selection;

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
                    leading: CircleAvatar(
                        radius: 24.0,
                        backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"),
                        backgroundColor: Colors.transparent),
                    title: Text(nsUser!.name, textScaleFactor: 1.2),
                    subtitle: Text("${nsUser!.section!.sectionTitle}@${nsUser!.section!.factory}"),
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
                      child: Wrap(
                        direction: Axis.horizontal,
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
                                    Icons.inventory_2_outlined,
                                    size: 100,
                                  ),
                                  "Finished Goods");
                            },
                            openWidget: FinishedGoods(),
                            onClosed: _showMarkedAsDoneSnackbar,
                          ),
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
                            onClosed: _showMarkedAsDoneSnackbar,
                          ),
                        ],
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
                                        label: const Text('NS Smart Wind 1.0'),
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
      onSelected: (MenuItems result) {
        if (result == MenuItems.logout) {
          _logout();
        } else if (result == MenuItems.dbReload) {
          DB.updateDatabase(context: context, showLoadingDialog: true, reset: true);
        } else if (result == MenuItems.changeSection) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SectionSelector(nsUser!)), (Route<dynamic> route) => false);
        } else if (result == MenuItems.cpanel) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminCpanel()));
        }

        setState(() {
          _selection = result;
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
          ),
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
