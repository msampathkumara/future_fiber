import 'package:flutter/material.dart';
import 'package:smartwind/Web/V/DashBoard/AddEmployeeCounts.dart';
import 'package:smartwind/Web/V/DashBoard/ChangeShift.dart';
import 'package:smartwind/Web/V/DashBoard/CountCards.dart';

import 'AddAvarageSailTimes.dart';
import 'AddDefaultEmployeeCounts.dart';
import 'AddDefaultShifts.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, actions: [
          // IconButton(onPressed: () => const AddEmployeeCounts().show(context), icon: const Icon(Icons.man, color: Colors.redAccent)),
          // IconButton(onPressed: () => const AddShifts().show(context), icon: const Icon(Icons.more_time, color: Colors.redAccent)),
          // IconButton(onPressed: () => const ChangeShifts().show(context), icon: const Icon(Icons.more_time, color: Colors.redAccent)),
          PopupMenuButton<int>(
              offset: const Offset(0, 30),
              padding: const EdgeInsets.all(16.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: const Icon(Icons.settings, color: Colors.redAccent),
              onSelected: (result) {},
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<int>>[
                  PopupMenuItem(value: 0, enabled: true, child: const Text("Add Employee Counts"), onTap: () => const AddEmployeeCounts().show(context)),
                  PopupMenuItem(value: 0, enabled: true, child: const Text("Set default Employee Counts"), onTap: () => const AddDefaultEmployeeCounts().show(context)),
                  PopupMenuItem(value: 0, enabled: true, child: const Text("Set Default shifts"), onTap: () => const AddDefaultShifts().show(context)),
                  PopupMenuItem(value: 0, enabled: true, child: const Text("Change Shift Time"), onTap: () => const ChangeShifts().show(context)),
                  PopupMenuItem(value: 0, enabled: true, child: const Text("Set Average Sail Times"), onTap: () => const AddAverageSailTimes().show(context))
                ];
              }),
          const SizedBox(width: 50)
        ]),
        body: const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(8.0), child: CountCards())));
  }
}

class _PieData {
  _PieData(this.xData, this.yData, this.text);

  final String xData;
  final num yData;
  final String text;
}
