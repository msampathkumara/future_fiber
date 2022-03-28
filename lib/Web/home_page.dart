import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/Web/V/CPR/webCpr.dart';
import 'package:smartwind/Web/V/FinishedGoods/webFinishedGoods.dart';
import 'package:smartwind/Web/V/QC/web_qc.dart';
import 'package:smartwind/Web/V/SheetData/webSheetData.dart';
import 'package:smartwind/Web/V/UserManager/web_user_manager.dart';

import '../V/Widgets/UserImage.dart';
import 'V/DashBoard/dashBoard.dart';
import 'V/ProductionPool/webProductionPool.dart';
import 'V/StandardLibrary/webStandardLibrary.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({Key? key}) : super(key: key);

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  bool _menuExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  int _selectedIndex = 3;

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
                    child: NavigationRail(
                      extended: false,
                      trailing: IconButton(
                          onPressed: () {
                            HiveBox.getDataFromServer(clean: true);
                          },
                          icon: Icon(Icons.refresh)),
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
                          icon: Icon(Icons.favorite_border),
                          selectedIcon: Icon(Icons.favorite),
                          label: Text(_menuExpanded ? 'Dash Board' : ''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.bookmark_border),
                          selectedIcon: Icon(Icons.book),
                          label: Text(_menuExpanded ? 'Production Pool' : ''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.check_box),
                          selectedIcon: Icon(Icons.check_box_outlined),
                          label: Text(_menuExpanded ? 'Finished Goods' : ''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.library_books_rounded),
                          selectedIcon: Icon(Icons.library_books_outlined),
                          label: Text(_menuExpanded ? 'Standard Library' : ''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.star_border),
                          selectedIcon: Icon(Icons.star),
                          label: Text(_menuExpanded ? 'CPR' : ''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.star_border),
                          selectedIcon: Icon(Icons.star),
                          label: Text(_menuExpanded ? 'User Manager' : ''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.star_border),
                          selectedIcon: Icon(Icons.star),
                          label: Text(_menuExpanded ? 'QA & QC' : ''),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.list_alt_outlined),
                          selectedIcon: Icon(Icons.list_alt_rounded),
                          label: Text(_menuExpanded ? 'Sheet Data' : ''),
                        ),
                      ],
                    ),
                  ),
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
              child: [DashBoard(), WebProductionPool(), WebFinishedGoods(), WebStandardLibrary(), WebCpr(), WebUserManager(), WebQc(), WebSheetData()].elementAt(_selectedIndex),
            ),
          )
        ],
      ),
    );
  }
}
