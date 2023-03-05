import 'dart:io';

import 'package:animations/animations.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:device_information/device_information.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/C/FCM.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/Mobile/V/Home/CurrentUser/CurrentUserDetails.dart';
import 'package:smartwind/Mobile/V/Home/HR/HRSystem.dart';
import 'package:smartwind/Mobile/V/Home/MaterialManagement/MaterialManagement.dart';
import 'package:smartwind/Mobile/V/Home/Tickets/ProductionPool/ProductionPool.dart';
import 'package:smartwind/Mobile/V/Login/SectionSelector.dart';
import 'package:smartwind/Mobile/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/PermissionMessage.dart';
import 'package:smartwind/globals.dart';
import 'package:smartwind/res.dart';

import '../../../C/Api.dart';
import '../../../C/DB/hive.dart';
import '../../../M/EndPoints.dart';
import '../../../M/PermissionsEnum.dart';
import '../../../globals.dart';
import '../../../globals.dart';
import '../Widgets/UserImage.dart';
import 'About.dart';
import 'Admin/AdminCpanel.dart';
import 'BlueBook/BlueBook.dart';
import 'Tickets/FinishedGoods/FinishedGoods.dart';
import 'Tickets/QC/QCList.dart';
import 'Tickets/StandardFiles/StandardFiles.dart';
import 'UserManager/UserManager.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({Key? key}) : super(key: key);

  @override
  _MobileHomeState createState() {
    return _MobileHomeState();
  }
}

enum MenuItems { logout, dbReload, changeSection, cpanel, deleteDownloadedFiles }

class _MobileHomeState extends State<MobileHome> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NsUser? nsUser;

  String? appVersion;

  late Function onUserUpdate;

  late SharedPreferences prefs;

  var serverType = Server.local ? " | Local Server" : " |  Online";

  @override
  initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) => prefs = value);

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

    isTestServer.then((value) {
      if (value) {
        setState(() {
          serverType = 'Test Server';
        });
      }
    });
  }

  String? idToken;

  @override
  void dispose() {
    super.dispose();
    FCM.unsubscribe();
    AppUser.removeOnUpdate(onUserUpdate);
  }

  void _showMarkedAsDoneSnackBar(bool? isMarkedAsDone) {
    if (isMarkedAsDone ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as done!')));
    }
  }

  double iconSize = 100.0;

  @override
  Widget build(BuildContext context) {
    return nsUser == null
        ? Center(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [CircularProgressIndicator(), Padding(padding: EdgeInsets.all(16.0), child: Text("Loading", textScaleFactor: 1))],
          ))
        : (AppUser.havePermissionFor(NsPermissions.MAIN_TAB))
            ? Scaffold(
                appBar: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    toolbarHeight: 100,
                    title: Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: ListTile(
                        leading: UserImage(nsUser: nsUser, radius: 24),
                        title: Text(nsUser!.name, textScaleFactor: 1.2),
                        subtitle: AppUser.getSelectedSection() != null
                            ? Text("${AppUser.getSelectedSection()?.sectionTitle} @ ${AppUser.getSelectedSection()?.factory}")
                            : const Text(""),
                        trailing: _currentUserOperionMenu(),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CurrentUserDetails(nsUser!)));
                        },
                      ),
                    )),
                body: SizedBox(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: Stack(children: [
                      Positioned(
                        bottom: 10,
                        right: 0,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.dstATop),
                          child: Image.asset(Res.north_sails_logo, width: 350),
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
                                if (AppUser.havePermissionFor(NsPermissions.TICKET_PRODUCTION_POOL))
                                  _OpenContainerWrapper(
                                      closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                        return _menuButton(openContainer, Icon(Icons.precision_manufacturing_outlined, size: iconSize), "Production Pool");
                                      },
                                      openWidget: const ProductionPool(),
                                      onClosed: _showMarkedAsDoneSnackBar),
                                _OpenContainerWrapper(
                                    closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                      return _menuButton(openContainer, Icon(Icons.inventory_2_rounded, color: Colors.deepOrange, size: iconSize), "Finished Goods");
                                    },
                                    openWidget: const FinishedGoods(),
                                    onClosed: _showMarkedAsDoneSnackBar),
                                if (AppUser.havePermissionFor(NsPermissions.STANDARD_FILES_STANDARD_FILES))
                                  _OpenContainerWrapper(
                                    closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                      return _menuButton(openContainer, Icon(Icons.collections_bookmark_outlined, size: iconSize), "Standard Library");
                                    },
                                    openWidget: const StandardFiles(),
                                    onClosed: _showMarkedAsDoneSnackBar,
                                  ),
                                if (AppUser.havePermissionFor(NsPermissions.USERS_USER_MANAGER))
                                  _OpenContainerWrapper(
                                      closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                        return _menuButton(openContainer, Icon(Icons.people_outline_outlined, color: Colors.lightGreen, size: iconSize), "User Manager");
                                      },
                                      openWidget: const UserManager(),
                                      onClosed: _showMarkedAsDoneSnackBar),
                                _OpenContainerWrapper(
                                    closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                      return _menuButton(openContainer, Icon(Icons.verified_rounded, size: iconSize, color: Colors.green), "QA & QC");
                                    },
                                    openWidget: const QCList(),
                                    onClosed: _showMarkedAsDoneSnackBar),
                                _OpenContainerWrapper(
                                    closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                      return _menuButton(openContainer, Icon(Icons.menu_book_rounded, size: iconSize, color: Colors.blueAccent), "Blue Book");
                                    },
                                    openWidget: const BlueBook(),
                                    onClosed: _showMarkedAsDoneSnackBar),
                                _OpenContainerWrapper(
                                    closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                      return _menuButton(openContainer, Icon(Icons.groups_rounded, size: iconSize, color: Colors.orange), "HR System");
                                    },
                                    openWidget: HRSystem(),
                                    onClosed: _showMarkedAsDoneSnackBar),
                                if (AppUser.havePermissionFor(NsPermissions.MATERIAL_MANAGEMENT_MATERIAL_MANAGEMENT))
                                  _OpenContainerWrapper(
                                      closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                        return _menuButton(openContainer, Icon(Icons.widgets, size: iconSize, color: Colors.purple), "Material Management");
                                      },
                                      openWidget: const MaterialManagement(),
                                      onClosed: _showMarkedAsDoneSnackBar),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Center(
                                  child: OpenContainer(
                                      closedElevation: 0,
                                      closedColor: Colors.transparent,
                                      transitionDuration: const Duration(milliseconds: 500),
                                      openBuilder: (BuildContext context, void Function({Object? returnValue}) action) {
                                        return const About();
                                      },
                                      closedBuilder: (BuildContext context, void Function() action) {
                                        return Chip(
                                            avatar: CircleAvatar(backgroundColor: Colors.grey.shade800, child: Image.asset(Res.north_sails_logox50, width: 50)),
                                            label: Text('NS Smart Wind $appVersion $serverType}'));
                                      }))))
                    ])))
            : const PermissionMessage();
  }

  void show(Widget window) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => window));
  }

  Future<void> _logout() async {
    await prefs.setBool('tabCheck', false);
    PermissionStatus ps = await Permission.phone.request();
    if (ps.isGranted) {
      String imeiNo = await DeviceInformation.deviceIMEINumber;
      await Api.post(EndPoints.tabs_logout, {"imei": imeiNo}).then((response) async {
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
    }
    FirebaseAuth.instance.signOut();
    if (!mounted) return;
    await AppUser.logout(context);
    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
  }

  _currentUserOperionMenu() {
    return PopupMenuButton<MenuItems>(
      onSelected: (MenuItems result) async {
        if (result == MenuItems.logout) {
          await _logout();
        } else if (result == MenuItems.dbReload) {
          HiveBox.getDataFromServer(clean: true);
        } else if (result == MenuItems.changeSection) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserSectionSelector(nsUser!, (Section section) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MobileHome()), (Route<dynamic> route) => false);
                      })));
        } else if (result == MenuItems.cpanel) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCpanel()));
        } else if (result == MenuItems.deleteDownloadedFiles) {
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
      itemBuilder: (BuildContext context) =>
      <PopupMenuEntry<MenuItems>>[
        const PopupMenuItem<MenuItems>(value: MenuItems.dbReload, child: Text('Reload Database')),
        const PopupMenuItem<MenuItems>(value: MenuItems.deleteDownloadedFiles, child: Text('Delete Downloaded Files')),
        const PopupMenuItem<MenuItems>(value: MenuItems.logout, child: Text('Logout')),
        const PopupMenuItem<MenuItems>(value: MenuItems.changeSection, child: Text('Change Section')),
        if (nsUser!.utype == 'admin') const PopupMenuItem<MenuItems>(value: MenuItems.cpanel, child: Text('Cpanel'))
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
                  child: SizedBox(
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

  void changeToProduction() {}
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
