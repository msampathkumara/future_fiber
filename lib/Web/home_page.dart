import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/Web/V/Admin/webAdmin.dart';
import 'package:smartwind/Web/V/CPR/webCpr.dart';
import 'package:smartwind/Web/V/FinishedGoods/webFinishedGoods.dart';
import 'package:smartwind/Web/V/PendingToFinish/webPendingToFinish.dart';
import 'package:smartwind/Web/V/Print/web_print.dart';
import 'package:smartwind/Web/V/QC/web_qc.dart';
import 'package:smartwind/Web/V/SheetData/webSheetData.dart';
import 'package:smartwind/Web/V/UserManager/webUserManager.dart';

import '../V/Home/UserManager/UpdateUserDetails.dart';
import '../V/Widgets/UserImage.dart';
import 'V/DashBoard/dashBoard.dart';
import 'V/ProductionPool/webProductionPool.dart';
import 'V/StandardLibrary/webStandardLibrary.dart';
import 'V/Tabs/web_tabs.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({Key? key}) : super(key: key);

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> with SingleTickerProviderStateMixin {
  bool _menuExpanded = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) => UpdateUserDetails(NsUser()).show(context));

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
    return Scaffold(
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
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 16, 8, 16),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              _menuExpanded = !_menuExpanded;
                            });
                          },
                          icon: Icon(Icons.menu))),
                  Expanded(
                      child: TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                          tween: Tween<double>(begin: _menuExpanded ? 0.1 : _size, end: _menuExpanded ? _size : 0.1),
                          builder: (_, size, __) {
                            return SingleChildScrollView(
                                child: ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: 500),
                                    child: IntrinsicHeight(
                                        child: Column(
                                      children: [
                                        Expanded(
                                          child: NavigationRail(
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
                                              if (AppUser.havePermissionFor(Permissions.PRODUCTION_POOL))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.favorite_border),
                                                    selectedIcon: Icon(Icons.favorite),
                                                    label: Text('Dash Board', style: TextStyle(fontSize: size))),
                                              if (AppUser.havePermissionFor(Permissions.FINISH_TICKET))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.bookmark_border),
                                                    selectedIcon: Icon(Icons.book),
                                                    label: Text('Production Pool', style: TextStyle(fontSize: size))),
                                              NavigationRailDestination(
                                                  icon: Icon(Icons.check_box),
                                                  selectedIcon: Icon(Icons.check_box_outlined),
                                                  label: Text('Finished Goods', style: TextStyle(fontSize: size))),
                                              if (AppUser.havePermissionFor(Permissions.CPR))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.library_books_rounded),
                                                    selectedIcon: Icon(Icons.library_books_outlined),
                                                    label: Text('Standard Library', style: TextStyle(fontSize: size))),
                                              if (AppUser.havePermissionFor(Permissions.USER_MANAGER))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.star_border), selectedIcon: Icon(Icons.star), label: Text('CPR', style: TextStyle(fontSize: size))),
                                              if (AppUser.havePermissionFor(Permissions.QC))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.supervised_user_circle_outlined),
                                                    selectedIcon: Icon(Icons.supervised_user_circle_rounded),
                                                    label: Text('User Manager', style: TextStyle(fontSize: size))),
                                              if (AppUser.havePermissionFor(Permissions.PRINTING))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.star_border), selectedIcon: Icon(Icons.star), label: Text('QA & QC', style: TextStyle(fontSize: size))),
                                              if (AppUser.havePermissionFor(Permissions.PRINTING))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.print_outlined),
                                                    selectedIcon: Icon(Icons.print_rounded),
                                                    label: Text('Printing', style: TextStyle(fontSize: size))),
                                              if (AppUser.havePermissionFor(Permissions.PENDING_TO_FINISH))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.pending_actions_outlined),
                                                    selectedIcon: Icon(Icons.pending_actions_rounded),
                                                    label: Text('Pending To Finish', style: TextStyle(fontSize: size))),
                                              if (AppUser.havePermissionFor(Permissions.SHEET_DATA))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.list_alt_outlined),
                                                    selectedIcon: Icon(Icons.list_alt_rounded),
                                                    label: Text('Sheet Data', style: TextStyle(fontSize: size))),
                                              if (AppUser.havePermissionFor(Permissions.TAB))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.tablet_android_outlined),
                                                    selectedIcon: Icon(Icons.tablet_android_rounded),
                                                    label: Text('Tabs', style: TextStyle(fontSize: size))),
                                              if (AppUser.havePermissionFor(Permissions.ADMIN))
                                                NavigationRailDestination(
                                                    icon: Icon(Icons.admin_panel_settings_outlined),
                                                    selectedIcon: Icon(Icons.admin_panel_settings_rounded),
                                                    label: Text('Admin', style: TextStyle(fontSize: size))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ))));
                          })),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: UserImage(nsUser: AppUser.getUser(), radius: 24),
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
                DashBoard(),
                WebProductionPool(),
                WebFinishedGoods(),
                WebStandardLibrary(),
                WebCpr(),
                WebUserManager(),
                WebQc(),
                WebPrint(),
                webPendingToFinish(),
                WebSheetData(),
                WebTabs(),
                WebAdmin()
              ].elementAt(_selectedIndex),
            ),
          )
        ],
      ),
    );
  }
}
