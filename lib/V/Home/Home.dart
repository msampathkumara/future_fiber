import 'package:flutter/material.dart';
import 'package:smartwind/V/Home/UserManager/UserManager.dart';

import 'Tickets/FinishedGoods/FinishedGoods.dart';
import 'Tickets/ProductionPool/ProductionPool.dart';
import 'Tickets/StandardFiles/StandardFiles.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();



  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Wrap(
            direction: Axis.vertical,
            children: [
              ElevatedButton(onPressed: () => show(ProductionPool()), child: Text("Production Pool")),
              ElevatedButton(onPressed: () => show(FinishedGoods()), child: Text("Finished Goods")),
              ElevatedButton(onPressed: () => show(StandardFiles()), child: Text("Standard Library")),
              ElevatedButton(onPressed: () => show(UserManager()), child: Text("User Manager")),
              ElevatedButton(onPressed: () => show(ProductionPool()), child: Text("CPR")),
            ],
          ),
        ),
      ),
    );
  }

  void show(Widget window) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => window));
  }
}
