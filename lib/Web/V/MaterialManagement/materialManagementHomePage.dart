import 'package:flutter/material.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/Web/V/MaterialManagement/CPR/webCpr.dart';
import 'package:smartwind/Web/V/MaterialManagement/KIT/webKit.dart';
import 'package:smartwind/generated/assets.dart';

import '../../../M/PermissionsEnum.dart';
import '../../../Mobile/V/Widgets/UserImage.dart';
import '../../../globals.dart';
import '../../Widgets/login_change.dart';

class MaterialManagementHomePage extends StatefulWidget {
  const MaterialManagementHomePage({Key? key}) : super(key: key);

  @override
  State<MaterialManagementHomePage> createState() => _MaterialManagementHomePageState();
}

class _MaterialManagementHomePageState extends State<MaterialManagementHomePage> with SingleTickerProviderStateMixin {
  bool _menuExpanded = true;

  @override
  void initState() {
    super.initState();
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
      loginChild: const Text(""),
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: (AppUser.havePermissionFor(NsPermissions.MATERIAL_MANAGEMENT_MATERIAL_MANAGEMENT))
            ? Row(
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
                              icon: const Icon(Icons.menu)),
                          Expanded(
                              child: TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                  tween: Tween<double>(begin: _menuExpanded ? 0.1 : _size, end: _menuExpanded ? _size : 0.1),
                                  builder: (_, size, __) {
                                    return SingleChildScrollView(
                                        child: ConstrainedBox(
                                            constraints: const BoxConstraints(minHeight: 100),
                                            child: IntrinsicHeight(
                                                child: NavigationRail(
                                              indicatorColor: Colors.white,
                                              useIndicator: true,
                                              extended: false,
                                              selectedIndex: _selectedIndex,
                                              onDestinationSelected: (int index) {
                                                setState(() {
                                                  _selectedIndex = index;
                                                });
                                              },
                                              labelType: NavigationRailLabelType.all,
                                              // selectedIconTheme: const IconThemeData(color: Colors.deepOrange),
                                              // selectedLabelTextStyle: const TextStyle(color: Colors.deepOrange),
                                              destinations: [
                                                if (AppUser.havePermissionFor(NsPermissions.CPR_CPR))
                                                  NavigationRailDestination(
                                                      icon: const Icon(Icons.local_mall_outlined),
                                                      selectedIcon: const Icon(Icons.local_mall_rounded),
                                                      label: Text('CPR', style: TextStyle(fontSize: size))),
                                                if (AppUser.havePermissionFor(NsPermissions.KIT_KIT))
                                                  NavigationRailDestination(
                                                      icon: const Icon(Icons.view_in_ar_outlined),
                                                      selectedIcon: const Icon(Icons.view_in_ar_rounded),
                                                      label: Text('KIT', style: TextStyle(fontSize: size))),
                                                // NavigationRailDestination(
                                                //     icon: const Icon(Icons.star_border),
                                                //     selectedIcon: const Icon(Icons.star),
                                                //     label: Text('Batten', style: TextStyle(fontSize: size))),
                                              ],
                                            ))));
                                  })),
                          PopupMenuButton<int>(
                            padding: const EdgeInsets.all(16.0),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                            offset: const Offset(70, 200),
                            child: Padding(padding: const EdgeInsets.only(bottom: 8.0), child: UserImage(nsUser: AppUser.getUser(), radius: 24)),
                            onSelected: (result) {
                              if (result == 1) {
                                AppUser.logout(context);
                              } else if (result == 2) {
                                isMaterialManagement = !isMaterialManagement;
                                Navigator.pushNamed(context, "/");
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                              PopupMenuItem(
                                  value: 0,
                                  enabled: false,
                                  child: Center(child: Padding(padding: const EdgeInsets.all(16.0), child: UserImage(nsUser: AppUser.getUser(), radius: 68)))),
                              PopupMenuItem(value: 1, child: Row(children: const [Icon(Icons.logout_rounded), SizedBox(width: 36), Text('Logout')])),
                              // CheckedPopupMenuItem(value: 2, checked: isMaterialManagement, child: const Text("Material Management"),padding: EdgeInsets.all(0.0),),
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
                    if (AppUser.havePermissionFor(NsPermissions.CPR_CPR)) const WebCpr(),
                    if (AppUser.havePermissionFor(NsPermissions.KIT_KIT)) const WebKit(),
                    // const WebBatten()
                  ].elementAt(_selectedIndex)))
                ],
              )
            : Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 256, child: Image.asset(Assets.assetsNoPermissions)),
                  const Text('You don\'t have permissions ', textScaleFactor: 1.2, style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 36),
                  ElevatedButton(onPressed: () => {AppUser.logout(context)}, child: const Text("Logout"))
                ],
              )),
      ),
    );
  }
}
