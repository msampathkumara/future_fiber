import 'dart:io';

import 'package:animations/animations.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:device_information/device_information.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/C/App.dart';
import 'package:smartwind/C/FCM.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/V/Home/CPR/CPRList.dart';
import 'package:smartwind/V/Home/CurrentUser/CurrentUserDetails.dart';
import 'package:smartwind/V/Home/HR/HRSystem.dart';
import 'package:smartwind/V/Home/Tickets/Print/PrintManager.dart';
import 'package:smartwind/V/Home/Tickets/ProductionPool/ProductionPool.dart';
import 'package:smartwind/V/Login/Login.dart';
import 'package:smartwind/V/Login/SectionSelector.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

import 'About.dart';
import 'Admin/AdminCpanel.dart';
import 'BlueBook/BlueBook.dart';
import 'J109.dart';
import 'Tickets/FinishedGoods/FinishedGoods.dart';
import 'Tickets/QC/QCList.dart';
import 'Tickets/StandardFiles/StandardFiles.dart';
import 'UserManager/UserManager.dart';

class Home extends StatefulWidget {
  Home();

  @override
  _HomeState createState() {
    return _HomeState();
  }
}

enum MenuItems { logout, dbReload, changeSection, cpanel, DeleteDownloadedFiles }

class _HomeState extends State<Home> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NsUser? nsUser;

  var appVersion;

  late Function onUserUpdate;

  @override
  void initState() {
    super.initState();
    FCM.setListener(context);
    // DB.updateDatabase(context);

    PackageInfo.fromPlatform().then((appInfo) {
      print(appInfo);
      setState(() {
        appVersion = appInfo.version;
      });
    });
    onUserUpdate = () {
      print('USER UPDATE');
      if (mounted) {
        nsUser = AppUser.getUser();

        if (nsUser == null) {
          _logout();
        }
      }
      setState(() {});
    };
    onUserUpdate();
    AppUser.onUpdate(onUserUpdate);
  }

  var idToken;

  @override
  void dispose() {
    super.dispose();
    FCM.unsubscribe();
    AppUser.removeOnUpdate(onUserUpdate);
  }

  void _showMarkedAsDoneSnackBar(bool? isMarkedAsDone) {
    if (isMarkedAsDone ?? false)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Marked as done!'),
      ));
  }

  double iconSize = 100.0;

  @override
  Widget build(BuildContext context) {
    return nsUser == null
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
              toolbarHeight: 100,
              title: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ListTile(
                  // leading: CircleAvatar(radius: 24.0, backgroundImage: nsUser.getUserImage(), backgroundColor: Colors.transparent),
                  leading: UserImage(
                    nsUser: nsUser,
                    radius: 24,
                  ),
                  title: Text(nsUser!.name, textScaleFactor: 1.2),
                  subtitle: AppUser.getSelectedSection() != null ? Text("${AppUser.getSelectedSection()?.sectionTitle} @ ${AppUser.getSelectedSection()?.factory}") : Text(""),
                  trailing: _currentUserOperionMenu(),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CurrentUserDetails(nsUser!)));
                  },
                ),
              ),
            ),
            body: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                child: Stack(children: [
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
                  SingleChildScrollView(
                    child: Align(
                      alignment: FractionalOffset.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 48.0),
                        child: Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _OpenContainerWrapper(
                                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                  return _menuButton(openContainer, Icon(Icons.precision_manufacturing_outlined, size: iconSize), "Production Pool");
                                },
                                openWidget: ProductionPool(),
                                onClosed: _showMarkedAsDoneSnackBar),
                            if (AppUser.havePermissionFor(Permissions.CPR))
                              _OpenContainerWrapper(
                                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                    return _menuButton(openContainer, Icon(Icons.local_mall_rounded, color: Colors.amber, size: iconSize), "CPR");
                                  },
                                  openWidget: CPRList(),
                                  onClosed: _showMarkedAsDoneSnackBar),
                            _OpenContainerWrapper(
                                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                  return _menuButton(openContainer, Icon(Icons.inventory_2_rounded, color: Colors.deepOrange, size: iconSize), "Finished Goods");
                                },
                                openWidget: FinishedGoods(),
                                onClosed: _showMarkedAsDoneSnackBar),
                            _OpenContainerWrapper(
                              closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                return _menuButton(openContainer, Icon(Icons.collections_bookmark_outlined, size: iconSize), "Standard Library");
                              },
                              openWidget: StandardFiles(),
                              onClosed: _showMarkedAsDoneSnackBar,
                            ),
                            if (AppUser.havePermissionFor(Permissions.USER_MANAGER))
                              _OpenContainerWrapper(
                                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                    return _menuButton(openContainer, Icon(Icons.people_outline_outlined, color: Colors.lightGreen, size: iconSize), "User Manager");
                                  },
                                  openWidget: UserManager(),
                                  onClosed: _showMarkedAsDoneSnackBar),
                            if (AppUser.havePermissionFor(Permissions.PRINTING))
                              _OpenContainerWrapper(
                                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                    return _menuButton(openContainer, Icon(Icons.print_rounded, size: iconSize, color: Colors.blue), "Print");
                                  },
                                  openWidget: PrintManager(),
                                  onClosed: _showMarkedAsDoneSnackBar),
                            if (AppUser.havePermissionFor(Permissions.QC))
                              _OpenContainerWrapper(
                                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                    return _menuButton(openContainer, Icon(Icons.verified_rounded, size: iconSize, color: Colors.green), "QA & QC");
                                  },
                                  openWidget: QCList(),
                                  onClosed: _showMarkedAsDoneSnackBar),
                            if (AppUser.havePermissionFor(Permissions.J109))
                              _OpenContainerWrapper(
                                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                    return _menuButton(openContainer, Icon(Icons.subject_rounded, size: iconSize, color: Colors.pinkAccent), "J109");
                                  },
                                  openWidget: J109(),
                                  onClosed: _showMarkedAsDoneSnackBar),
                            if (AppUser.havePermissionFor(Permissions.BLUE_BOOK))
                              _OpenContainerWrapper(
                                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                    return _menuButton(openContainer, Icon(Icons.menu_book_rounded, size: iconSize, color: Colors.blueAccent), "Blue Book");
                                  },
                                  openWidget: BlueBook(),
                                  onClosed: _showMarkedAsDoneSnackBar),
                            if (AppUser.havePermissionFor(Permissions.HR))
                              _OpenContainerWrapper(
                                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                    return _menuButton(openContainer, Icon(Icons.groups_rounded, size: iconSize, color: Colors.orange), "HR System");
                                  },
                                  openWidget: HESystem(),
                                  onClosed: _showMarkedAsDoneSnackBar),
                            ElevatedButton(
                                onPressed: () {
                                  HiveBox.getDataFromServer();
                                  AppUser.refreshUserData();
                                },
                                child: Text("ssssssssssss")),
                            ElevatedButton(
                                onPressed: () {
                                  HiveBox.getDataFromServer(clean: true);
                                  AppUser.refreshUserData();
                                },
                                child: Text("ssssssssssss")),
                            // ElevatedButton(
                            //     onPressed: () {
                            //       App.tryOtaUpdate((OtaEvent event) {
                            //         print('OTA status: ${event.status} : ${event.value} \n');
                            //       });
                            //     },
                            //     child: Text("Update Apk"))
                          ],
                        ),
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
                                  closedColor: Colors.transparent,
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
                                        label: Text('NS Smart Wind $appVersion ${Server.local ? " | Local Server" : " |  Online"}'));
                                  }))))
                ])));
  }

  void show(Widget window) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => window));
  }

  Future<void> _logout() async {
    String imeiNo = await DeviceInformation.deviceIMEINumber;
    await OnlineDB.apiPost("tabs/logout", {"imei": imeiNo}).then((response) async {
      if (response.data["saved"] == true) {
        print("----------------------------------------55555555555555555555");
      } else {
        ErrorMessageView(errorMessage: response.data).show(context);
      }
      print(response.data);

      return 1;
    }).catchError((onError) {
      print(onError);
    });
    FirebaseAuth.instance.signOut();
    AppUser.logout();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
  }

  _currentUserOperionMenu() {
    return PopupMenuButton<MenuItems>(
      onSelected: (MenuItems result) async {
        if (result == MenuItems.logout) {
          await _logout();
        } else if (result == MenuItems.dbReload) {
          // await DB.dropDatabase();
          // await DB.loadDB();
          // DB.updateDatabase(context, showLoadingDialog: true, reset: true);
          HiveBox.getDataFromServer(clean: true);
        } else if (result == MenuItems.changeSection) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SectionSelector(nsUser!)), (Route<dynamic> route) => false);
        } else if (result == MenuItems.cpanel) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminCpanel()));
        } else if (result == MenuItems.DeleteDownloadedFiles) {
          var ed = await getExternalStorageDirectory();
          if (ed != null) {
            List<FileSystemEntity> files = ed.listSync();

            for (FileSystemEntity file in files) {
              if (p.extension(file.path).toLowerCase() == ".pdf") {
                print(p.extension(file.path).toLowerCase());
                file.deleteSync(recursive: true);
              }
            }

            HiveBox.localFileVersionsBox.clear();

            // DB.getDB().then((db) => db!.rawQuery("delete from files").then((data) {
            //       print(data);
            //     }));
          }
        }

        setState(() {});
        // print(result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItems>>[
        const PopupMenuItem<MenuItems>(
          value: MenuItems.dbReload,
          child: Text('Reload Database'),
        ),
        const PopupMenuItem<MenuItems>(
          value: MenuItems.DeleteDownloadedFiles,
          child: Text('Delete Downloaded Files'),
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

  _menuButton(openContainer, Icon image, title) {
    return SizedBox(
        height: 170,
        width: 170,
        child: InkWell(
            onTap: openContainer,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              Expanded(
                  child: Container(
                      height: 170,
                      child: Center(
                          child: DecoratedIcon(
                        image.icon ?? Icons.android,
                        color: image.color,
                        size: image.size,
                        // shadows: [BoxShadow(blurRadius: 5.0, color: Colors.black45 ),BoxShadow(blurRadius: 20.0, color: Colors.black38 )],
                      )))),
              Center(
                child: Padding(padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0), child: Text(title, textScaleFactor: 1)),
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
