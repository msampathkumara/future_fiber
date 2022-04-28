import 'package:flutter/material.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/Web/V/Admin/webAdmin.dart';
import 'package:smartwind/Web/V/FinishedGoods/webFinishedGoods.dart';
import 'package:smartwind/Web/V/Print/web_print.dart';
import 'package:smartwind/Web/V/QC/web_qc.dart';
import 'package:smartwind/Web/V/SheetData/webSheetData.dart';
import 'package:smartwind/Web/V/UserManager/webUserManager.dart';

import '../V/Widgets/UserImage.dart';
import 'V/DashBoard/dashBoard.dart';
import 'V/ProductionPool/webProductionPool.dart';
import 'V/StandardLibrary/webStandardLibrary.dart';
import 'V/Tabs/web_tabs.dart';
import 'Widgets/login_change.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({Key? key}) : super(key: key);

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> with SingleTickerProviderStateMixin {
  bool _menuExpanded = false;

  @override
  void initState() {
    // var t = HiveBox.ticketBox.get(38886);
    //
    // if (t != null) {
    //   WidgetsBinding.instance?.addPostFrameCallback((_) => TicketSortMaterials(t).show(context));
    // }

    // Future(() {
    //   if (!AppUser.isLogged) {
    //     Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    //   }
    // });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _selectedIndex = 0;
  double _size = 12;

  @override
  Widget build(BuildContext context) {
    return LoginChangeWidget(
      loginChild: Text(""),
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.white,
                elevation: 8,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _menuExpanded = !_menuExpanded;
                          });
                        },
                        icon: Icon(Icons.menu, color: Colors.deepOrange)),
                    Expanded(
                        child: TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                            tween: Tween<double>(begin: _menuExpanded ? 0.1 : _size, end: _menuExpanded ? _size : 0.1),
                            builder: (_, size, __) {
                              return SingleChildScrollView(
                                  child: ConstrainedBox(
                                      constraints: BoxConstraints(minHeight: 100),
                                      child: IntrinsicHeight(
                                          child: NavigationRail(
                                        useIndicator: true,
                                        extended: false,
                                        // trailing: IconButton(
                                        //     onPressed: () {
                                        //       HiveBox.getDataFromServer(clean: true);
                                        //     },
                                        //     icon: Icon(Icons.refresh)),
                                        selectedIndex: _selectedIndex,
                                        onDestinationSelected: (int index) {
                                          setState(() {
                                            _selectedIndex = index;
                                          });
                                        },
                                        labelType: NavigationRailLabelType.all,
                                        selectedIconTheme: IconThemeData(color: Colors.deepOrange),
                                        selectedLabelTextStyle: TextStyle(color: Colors.deepOrange),
                                        destinations: [
                                          NavigationRailDestination(
                                              icon: const Icon(Icons.favorite_border),
                                              selectedIcon: Icon(Icons.favorite),
                                              label: Text('Dash Board', style: TextStyle(fontSize: size))),
                                          if (AppUser.havePermissionFor(Permissions.PRODUCTION_POOL))
                                            NavigationRailDestination(
                                                icon: const Icon(Icons.bookmark_border),
                                                selectedIcon: const Icon(Icons.book),
                                                label: Text('Production Pool', style: TextStyle(fontSize: size))),
                                          if (AppUser.havePermissionFor(Permissions.FINISH_TICKET))
                                            NavigationRailDestination(
                                                icon: const Icon(Icons.check_box),
                                                selectedIcon: const Icon(Icons.check_box_outlined),
                                                label: Text('Finished Goods', style: TextStyle(fontSize: size))),
                                          if (AppUser.havePermissionFor(Permissions.STANDARD_FILES))
                                            NavigationRailDestination(
                                                icon: const Icon(Icons.library_books_rounded),
                                                selectedIcon: const Icon(Icons.library_books_outlined),
                                                label: Text('Standard Library', style: TextStyle(fontSize: size))),
                                          // if (AppUser.havePermissionFor(Permissions.CPR))
                                          //   NavigationRailDestination(
                                          //       icon: Icon(Icons.star_border), selectedIcon: Icon(Icons.star), label: Text('CPR', style: TextStyle(fontSize: size))),
                                          if (AppUser.havePermissionFor(Permissions.USER_MANAGER))
                                            NavigationRailDestination(
                                                icon: const Icon(Icons.supervised_user_circle_outlined),
                                                selectedIcon: const Icon(Icons.supervised_user_circle_rounded),
                                                label: Text('User Manager', style: TextStyle(fontSize: size))),
                                          if (AppUser.havePermissionFor(Permissions.QC))
                                            NavigationRailDestination(
                                                icon: const Icon(Icons.star_border),
                                                selectedIcon: const Icon(Icons.star),
                                                label: Text('QA & QC', style: TextStyle(fontSize: size))),
                                          if (AppUser.havePermissionFor(Permissions.PRINTING))
                                            NavigationRailDestination(
                                                icon: const Icon(Icons.print_outlined),
                                                selectedIcon: const Icon(Icons.print_rounded),
                                                label: Text('Printing', style: TextStyle(fontSize: size))),
                                          // if (AppUser.havePermissionFor(Permissions.PENDING_TO_FINISH))
                                          //   NavigationRailDestination(
                                          //       icon: Icon(Icons.pending_actions_outlined),
                                          //       selectedIcon: Icon(Icons.pending_actions_rounded),
                                          //       label: Text('Pending To Finish', style: TextStyle(fontSize: size))),
                                          if (AppUser.havePermissionFor(Permissions.SHEET_DATA))
                                            NavigationRailDestination(
                                                icon: const Icon(Icons.list_alt_outlined),
                                                selectedIcon: const Icon(Icons.list_alt_rounded),
                                                label: Text('Sheet Data', style: TextStyle(fontSize: size))),
                                          if (AppUser.havePermissionFor(Permissions.TAB))
                                            NavigationRailDestination(
                                                icon: const Icon(Icons.tablet_android_outlined),
                                                selectedIcon: const Icon(Icons.tablet_android_rounded),
                                                label: Text('Tabs', style: TextStyle(fontSize: size))),
                                          if (AppUser.havePermissionFor(Permissions.ADMIN))
                                            NavigationRailDestination(
                                                icon: const Icon(Icons.admin_panel_settings_outlined),
                                                selectedIcon: const Icon(Icons.admin_panel_settings_rounded),
                                                label: Text('Admin', style: TextStyle(fontSize: size))),
                                        ],
                                      ))));
                            })),
                    PopupMenuButton<int>(
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      offset: const Offset(70, 200),
                      child: Padding(padding: const EdgeInsets.only(bottom: 8.0), child: UserImage(nsUser: AppUser.getUser(), radius: 24)),
                      onSelected: (result) {
                        if (result == 1) {
                          AppUser.logout(context);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                        PopupMenuItem(
                          value: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: UserImage(nsUser: AppUser.getUser(), radius: 68),
                          ),
                          enabled: false,
                        ),
                        const PopupMenuItem(
                          value: 1,
                          child: Text('Logout'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            // VerticalDivider(thickness: 1, width: 1),
            // This is the main content.
            Expanded(
                child: Center(
                    child: [
              const DashBoard(),
              if (AppUser.havePermissionFor(Permissions.PRODUCTION_POOL)) const WebProductionPool(),
              if (AppUser.havePermissionFor(Permissions.FINISH_TICKET)) const WebFinishedGoods(),
              if (AppUser.havePermissionFor(Permissions.STANDARD_FILES)) const WebStandardLibrary(),
              if (AppUser.havePermissionFor(Permissions.USER_MANAGER)) const WebUserManager(),
              if (AppUser.havePermissionFor(Permissions.QC)) const WebQc(),
              if (AppUser.havePermissionFor(Permissions.PRINTING)) const WebPrint(),
              if (AppUser.havePermissionFor(Permissions.SHEET_DATA)) const WebSheetData(),
              if (AppUser.havePermissionFor(Permissions.TAB)) const WebTabs(),
              if (AppUser.havePermissionFor(Permissions.ADMIN)) const WebAdmin()
            ].elementAt(_selectedIndex)))
          ],
        ),
      ),
    );
  }
}
