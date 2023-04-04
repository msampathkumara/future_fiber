import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/Mobile/V/Home/UserManager/UserDetails.dart';
import 'package:smartwind/V/PermissionMessage.dart';

import '../C/DB/hive.dart';
import '../M/PermissionsEnum.dart';
import '../Mobile/V/Home/AppInfo.dart';
import '../Mobile/V/Widgets/UserImage.dart';
import 'V/Admin/webAdmin.dart';
import 'V/DashBoard/dashBoard.dart';
import 'V/DeviceManager/web_tabs.dart';
import 'V/FinishedGoods/webFinishedGoods.dart';
import 'V/MaterialManagement/CPR/webCpr.dart';
import 'V/MaterialManagement/KIT/webKit.dart';
import 'V/ProductionPool/webProductionPool.dart';
import 'V/QC/web_qc.dart';
import 'V/SheetData/webSheetData.dart';
import 'V/StandardLibrary/webStandardLibrary.dart';
import 'V/UserManager/webUserManager.dart';
import 'Widgets/StatusBar/StatusBar.dart';
import 'Widgets/StatusBar/StatusBarProgressIndicator.dart';
import 'Widgets/login_change.dart';

class WebHomePage extends StatefulWidget {
  final bool isMaterialManagement;

  const WebHomePage({Key? key, this.isMaterialManagement = false}) : super(key: key);

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> with SingleTickerProviderStateMixin {
  bool _menuExpanded = false;

  String appVersion = '';

  final ScrollController _controller = ScrollController();

  bool loading = true;

  StatusBarProgressIndicatorController statusBarProgressIndicatorController = StatusBarProgressIndicatorController();
  late StatusBarProgressIndicator _statusBarProgressIndicator;

  bool _isMaterialManagement = false;

  double? ticketLoadingProgress;

  List<Widget?> get routeWidgets => [
        if (AppUser.havePermissionFor(NsPermissions.DASHBOARD_DASHBOARD)) const DashBoard(),
        if (AppUser.havePermissionFor(NsPermissions.TICKET_PRODUCTION_POOL)) const WebProductionPool(),
        const WebFinishedGoods(),
        if (AppUser.havePermissionFor(NsPermissions.STANDARD_FILES_STANDARD_FILES)) const WebStandardLibrary(),
        if (AppUser.havePermissionFor(NsPermissions.USERS_USER_MANAGER)) const WebUserManager(),
        const WebQc(),
        if (AppUser.havePermissionFor(NsPermissions.MATERIAL_MANAGEMENT_MATERIAL_MANAGEMENT)) null,
        if (AppUser.havePermissionFor(NsPermissions.SHEET_ADD_DATA_SHEET)) const WebSheetData(),
        if (AppUser.havePermissionFor(NsPermissions.DEVICE_MANAGER_DEVICE_MANAGER)) const WebTabs(),
        if (AppUser.havePermissionFor(NsPermissions.ADMIN_ADMIN)) const WebAdmin(),
        const AppInfo()
      ];

  List<Widget?> get materialManagementRouteWidgets => [null, const WebCpr(), const WebKit(), const AppInfo()];

  List<NavigationRailDestination> getMaterialManagementRouteButtons(size) => [
        NavigationRailDestination(
            icon: const Icon(Icons.keyboard_backspace_rounded),
            selectedIcon: const Icon(Icons.keyboard_backspace_rounded),
            label: Text('SmartWind', style: TextStyle(fontSize: size))),
        NavigationRailDestination(
            icon: const Icon(Icons.local_mall_outlined), selectedIcon: const Icon(Icons.local_mall_rounded), label: Text('CPR', style: TextStyle(fontSize: size))),
        NavigationRailDestination(
            icon: const Icon(Icons.view_in_ar_outlined), selectedIcon: const Icon(Icons.view_in_ar_rounded), label: Text('KIT', style: TextStyle(fontSize: size))),
        NavigationRailDestination(icon: const Icon(Icons.info_outline), selectedIcon: const Icon(Icons.info), label: Text('Info', style: TextStyle(fontSize: size)))
      ];

  @override
  initState() {
    _isMaterialManagement = widget.isMaterialManagement;
    _statusBarProgressIndicator = StatusBarProgressIndicator(controller: statusBarProgressIndicatorController);

    print('HOME PAGE INIT');
    HiveBox.getUserConfig();
    PackageInfo.fromPlatform().then((appInfo) {
      print(appInfo);
      setState(() {
        appVersion = appInfo.version;
      });
    });

    HiveBox.getDataFromServer(cancelable: false).then((value) {
      print('HOME__________________________________________________________________________________________');
      loading = false;
      if (mounted) {
        setState(() {});
      }
    });
    statusBarProgressIndicatorController.onProgressChange((p0) {
      setState(() {
        ticketLoadingProgress = p0;
      });
    });

    // StatusBar.getController().addWidget(_statusBarProgressIndicator);
    // runIndicator().then((value) {
    //   // StatusBar.getController().removeWidget(_statusBarProgressIndicator);
    // });

    // StatusBar.getController().addWidget(_statusBarProgressIndicator);

    super.initState();

    _selectedIndex = _isMaterialManagement ? 1 : 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _selectedIndex = 0;
  final double _size = 12;

  @override
  Widget build(BuildContext context) {
    return LoginChangeWidget(
        loginChild: const Text(" "),
        child: Scaffold(
          backgroundColor: Colors.grey.shade200,
          body: loading
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [CircularProgressIndicator(color: Colors.red)],
                ))
              : (AppUser.havePermissionFor(NsPermissions.MAIN_WEB))
                  ? Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 8, bottom: 12, right: 8),
                                child: Material(
                                  color: Colors.blue,
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
                                          icon: const Icon(Icons.menu)),
                                      Expanded(
                                          child: TweenAnimationBuilder<double>(
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.ease,
                                              tween: Tween<double>(begin: _menuExpanded ? 0.1 : _size, end: _menuExpanded ? _size : 0.1),
                                              builder: (_, size, __) {
                                                return SingleChildScrollView(
                                                    controller: _controller,
                                                    child: Padding(
                                                        padding: EdgeInsets.only(right: _menuExpanded ? 8.0 : 0),
                                                        child: ConstrainedBox(
                                                            constraints: const BoxConstraints(minHeight: 100),
                                                            child: IntrinsicHeight(
                                                                child: NavigationRail(
                                                                    backgroundColor: Colors.transparent,
                                                                    selectedIconTheme: const IconThemeData(
                                                                        color: Colors.black, shadows: <Shadow>[Shadow(color: Colors.white, blurRadius: 4.0)], weight: 5),
                                                                    indicatorColor: Colors.transparent,
                                                                    unselectedIconTheme: const IconThemeData(
                                                                        color: Colors.white, shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 8.0)], weight: 5),
                                                                    selectedLabelTextStyle: const TextStyle(color: Colors.white),
                                                                    unselectedLabelTextStyle: const TextStyle(color: Colors.white),
                                                                    useIndicator: true,
                                                                    extended: false,
                                                                    selectedIndex: _selectedIndex,
                                                                    onDestinationSelected: (int index) async {
                                                                      if (index == materialManagementRouteWidgets.indexOf(null) && _isMaterialManagement) {
                                                                        // _isMaterialManagement = false;
                                                                        // setState(() => {_selectedIndex = 0});
                                                                        Navigator.popAndPushNamed(context, "/");
                                                                        return;
                                                                      } else if (index == routeWidgets.indexOf(null)) {
                                                                        // _isMaterialManagement = true;
                                                                        // setState(() => {_selectedIndex = 1});
                                                                        // if (isLocalServer || await isTestServer) {
                                                                        Navigator.popAndPushNamed(context, "/materialManagement");
                                                                        // } else {
                                                                        //   html.window.open("https://mm.smartwind.nsslsupportservices.com", 'new tab');
                                                                        // }
                                                                        return;
                                                                      }

                                                                      setState(() => {_selectedIndex = index});
                                                                      return;
                                                                    },
                                                                    labelType: NavigationRailLabelType.all,
                                                                    destinations: _isMaterialManagement
                                                                        ? getMaterialManagementRouteButtons(size)
                                                                        : [
                                                                            if (AppUser.havePermissionFor(NsPermissions.DASHBOARD_DASHBOARD))
                                                                              NavigationRailDestination(
                                                                                  padding: const EdgeInsets.all(0),
                                                                                  icon: const Icon(Icons.favorite_border),
                                                                                  selectedIcon: const Icon(Icons.favorite),
                                                                                  label: Text('Dash Board', style: TextStyle(fontSize: size))),
                                                                            if (AppUser.havePermissionFor(NsPermissions.TICKET_PRODUCTION_POOL))
                                                                              NavigationRailDestination(
                                                                                  padding: const EdgeInsets.all(0),
                                                                                  icon: const Icon(Icons.precision_manufacturing_outlined),
                                                                                  selectedIcon: const Icon(Icons.precision_manufacturing_rounded),
                                                                                  label: Text('Production Pool', style: TextStyle(fontSize: size))),
                                                                            NavigationRailDestination(
                                                                                icon: const Icon(Icons.inventory_2_outlined),
                                                                                selectedIcon: const Icon(Icons.inventory_2_rounded),
                                                                                label: Text('Finished Goods', style: TextStyle(fontSize: size))),
                                                                            if (AppUser.havePermissionFor(NsPermissions.STANDARD_FILES_STANDARD_FILES))
                                                                              NavigationRailDestination(
                                                                                  icon: const Icon(Icons.collections_bookmark_outlined),
                                                                                  selectedIcon: const Icon(Icons.collections_bookmark_rounded),
                                                                                  label: Text('Standard Library', style: TextStyle(fontSize: size))),
                                                                            if (AppUser.havePermissionFor(NsPermissions.USERS_USER_MANAGER))
                                                                              NavigationRailDestination(
                                                                                  icon: const Icon(Icons.people_outline_outlined),
                                                                                  selectedIcon: const Icon(Icons.people_outline_rounded),
                                                                                  label: Text('User Manager', style: TextStyle(fontSize: size))),
                                                                            NavigationRailDestination(
                                                                                icon: const Icon(Icons.verified_outlined),
                                                                                selectedIcon: const Icon(Icons.verified_rounded),
                                                                                label: Text('QA & QC', style: TextStyle(fontSize: size))),
                                                                            if (AppUser.havePermissionFor(NsPermissions.MATERIAL_MANAGEMENT_MATERIAL_MANAGEMENT))
                                                                              NavigationRailDestination(
                                                                                  icon: const Icon(Icons.widgets_outlined),
                                                                                  selectedIcon: const Icon(Icons.widgets_rounded),
                                                                                  label: Text('Material Management', style: TextStyle(fontSize: size))),
                                                                            if (AppUser.havePermissionFor(NsPermissions.SHEET_ADD_DATA_SHEET))
                                                                              NavigationRailDestination(
                                                                                  icon: const Icon(Icons.list_alt_outlined),
                                                                                  selectedIcon: const Icon(Icons.list_alt_rounded),
                                                                                  label: Text('Sheet Data', style: TextStyle(fontSize: size))),
                                                                            if (AppUser.havePermissionFor(NsPermissions.DEVICE_MANAGER_DEVICE_MANAGER))
                                                                              NavigationRailDestination(
                                                                                  icon: const Icon(Icons.phone_iphone_outlined),
                                                                                  selectedIcon: const Icon(Icons.phone_iphone_rounded),
                                                                                  label: Text('Tabs', style: TextStyle(fontSize: size))),
                                                                            if (AppUser.havePermissionFor(NsPermissions.ADMIN_ADMIN))
                                                                              NavigationRailDestination(
                                                                                  icon: const Icon(Icons.admin_panel_settings_outlined),
                                                                                  selectedIcon: const Icon(Icons.admin_panel_settings_rounded),
                                                                                  label: Text('Admin', style: TextStyle(fontSize: size))),
                                                                            NavigationRailDestination(
                                                                                icon: const Icon(Icons.info_outline),
                                                                                selectedIcon: const Icon(Icons.info),
                                                                                label: Text('Info', style: TextStyle(fontSize: size))),
                                                                          ])))));
                                              })),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: PopupMenuButton<int>(
                                          padding: const EdgeInsets.all(16.0),
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                          offset: const Offset(70, 200),
                                          child: Padding(padding: const EdgeInsets.only(bottom: 8.0), child: UserImage(nsUser: AppUser.getUser(), radius: 24)),
                                          onSelected: (result) {
                                            if (result == 1) {
                                              AppUser.logout(context);
                                            } else if (result == 2) {
                                              // RF("").show(context);

                                              // isMaterialManagement = !isMaterialManagement;
                                              // Navigator.pushNamed(context, "/materialManagement");
                                            }
                                          },
                                          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                                            PopupMenuItem(
                                                value: 0,
                                                enabled: false,
                                                child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Center(
                                                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                        UserImage(nsUser: AppUser.getUser(), radius: 68),
                                                        const SizedBox(height: 16),
                                                        Text("${AppUser.getUser()?.name}"),
                                                        Text("#${AppUser.getUser()?.uname}", style: TextStyle(color: Theme.of(context).primaryColor)),
                                                        Column(children: [
                                                          TextButton(
                                                              onPressed: () {
                                                                UserDetails(AppUser.getUser()!).show(context);
                                                              },
                                                              child: const Text("Details")),
                                                        ])
                                                      ]),
                                                    ))),
                                            PopupMenuItem(value: 1, child: Row(children: const [Icon(Icons.logout_rounded), SizedBox(width: 36), Text('Logout')])),
                                            // PopupMenuItem(value: 2, child: Row(children: const [Icon(Icons.logout_rounded), SizedBox(width: 36), Text('RF')])),
                                            // if (AppUser.getUser()?.id == 1)
                                            //   CheckedPopupMenuItem(value: 2, checked: isMaterialManagement, padding: const EdgeInsets.all(0.0), child: const Text("Material Management")),
                                          ],
                                        ),
                                      ),
                                      Text('${appVersion}v', style: TextStyle(fontSize: 8, color: Theme.of(context).primaryColor))
                                    ],
                                  ),
                                ),
                              ),
                    Expanded(child: Center(child: (_isMaterialManagement ? materialManagementRouteWidgets : routeWidgets).elementAt(_selectedIndex)))
                            ],
                          ),
                        ),
              const SizedBox(width: double.infinity, child: StatusBar())
                      ],
                    )
                  : const PermissionMessage(),
        ));
  }

  Future<void> runIndicator() async {
    for (var i = 0; i < 500; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      print('Writing another word $i');
      statusBarProgressIndicatorController.setValue(i as double, 500);
    }
  }
}
