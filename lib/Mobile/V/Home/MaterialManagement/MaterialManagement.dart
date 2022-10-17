import 'package:flutter/material.dart';
import 'package:smartwind/Mobile/V/Home/MaterialManagement/BattrenList.dart';
import 'package:smartwind/Mobile/V/Home/MaterialManagement/CprList.dart';
import 'package:smartwind/Mobile/V/Home/MaterialManagement/KitList.dart';

class MaterialManagement extends StatefulWidget {
  const MaterialManagement({Key? key}) : super(key: key);

  @override
  State<MaterialManagement> createState() => _MaterialManagementState();
}

class _MaterialManagementState extends State<MaterialManagement> {
  MaterialTypes _materialType = MaterialTypes.CPR;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: const Text("Material Management"),
              bottom: TabBar(
                onTap: (int selectedIndex) {
                  _materialType = MaterialTypes.values[selectedIndex];
                  loadData();
                },
                tabs: MaterialTypes.values.map((e) => Tab(text: e.getValue())).toList(),
              ),
            ),
            body: const TabBarView(children: [CprList(), KitList(), BattrenList()])));
  }

  void loadData() {
    print(_materialType.getValue());
  }
}

enum MaterialTypes { CPR, KIT, Batten }

extension MaterialTypesExtension on MaterialTypes {
  String getValue() {
    return (this).toString().split('.').last.replaceAll('_', " ").trim();
  }

  bool equalCaseInsensitive(String production) {
    return (this).toString().split('.').last.replaceAll('_', " ").trim().toLowerCase() == production.toLowerCase().trim();
  }
}
