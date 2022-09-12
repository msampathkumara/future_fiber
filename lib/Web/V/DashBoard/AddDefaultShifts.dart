import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';
import 'package:smartwind/globals.dart';

import '../../../C/Api.dart';
import 'M/DefaultShift.dart';

class AddDefaultShifts extends StatefulWidget {
  const AddDefaultShifts({Key? key}) : super(key: key);

  @override
  State<AddDefaultShifts> createState() => _AddDefaultShiftsState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddDefaultShiftsState extends State<AddDefaultShifts> {
  bool loading = true;

  TimeOfDay getTime(startAt) => TimeOfDay(hour: int.tryParse(startAt!.split(":")[0]) ?? 0, minute: int.tryParse(startAt!.split(":")[1]) ?? 0);

  Map<String, DefaultShift> shiftsMap = {
    "Morning": DefaultShift.fromJson({"shiftName": "Morning", "startAt": '06:00', 'endAt': '14:00', 'deleted': 0}),
    "Evening": DefaultShift.fromJson({"shiftName": "Evening", "startAt": '14:00', 'endAt': '22:00', 'deleted': 0}),
    // "Night": Shift.fromJson({"shiftName": "Night", "startAt": '22:00', 'endAt': '06:00', 'deleted': 1})
  };

  @override
  void initState() {
    // TODO: implement initState
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi(), width: 500, height: 500));
  }

  getWebUi() {
    return Scaffold(
        appBar: AppBar(title: const Text("Set Default Shifts")),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      children: [
                        TableRow(
                            children: [const Text("Shift Name"), const Text("Start Time"), const Text("End Time"), const Text("Duration")]
                                .map((e) => Padding(padding: const EdgeInsets.all(8.0), child: e))
                                .toList()),
                        ...shiftsMap.values
                            .map((e) => TableRow(children: [
                                  // Switch(value: e.isActive, onChanged: (bool v) => setState(() => e.deleted = v ? 0 : 1)),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(e.shiftName ?? '')),
                                  (e.isActive)
                                      ? getTimeSelector(getTime(e.startAt), (TimeOfDay t) => e.startAt = "${t.hour}:${t.minute}")
                                      : Chip(label: Text(getTime(e.startAt).format(context))),
                                  (e.isActive) ? getTimeSelector(getTime(e.endAt), (t) => e.endAt = "${t.hour}:${t.minute}") : Chip(label: Text(getTime(e.endAt).format(context))),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(dif(getTime(e.startAt), getTime(e.endAt))))
                                ]))
                            .toList()
                      ],
                    ),
                  ),
                  Spacer()
                ],
              ),
        bottomNavigationBar:
            loading ? null : BottomAppBar(child: Padding(padding: const EdgeInsets.all(8.0), child: ElevatedButton(onPressed: save, child: const Text("Save as Defaults")))));
  }

  String dif(TimeOfDay t1, TimeOfDay t2) {
    int min = ((t2.hour * 60 + t2.minute)) - ((t1.hour * 60 + t1.minute));
    print((min > 0 ? min : (24 * 60) - min.abs()) / 60);
    return '${(Duration(minutes: min > 0 ? min : (24 * 60) - min.abs()))}'.split('.')[0].padLeft(8, '0');
  }

  double getDuration(TimeOfDay t1, TimeOfDay t2) {
    int min = ((t2.hour * 60 + t2.minute)) - ((t1.hour * 60 + t1.minute));
    return (min > 0 ? min : (24 * 60) - min.abs()) / 60;
  }

  getUi() {}

  getTimeSelector(TimeOfDay time, f) {
    return ActionChip(
      backgroundColor: getPrimaryColor(context),
      label: Text(time.format(context)),
      onPressed: () async {
        final TimeOfDay? newTime = await showTimePicker(
          context: context,
          initialTime: time,
          initialEntryMode: TimePickerEntryMode.input,
        );
        if (newTime != null) {
          f(newTime);
          setState(() {});
        }
      },
    );
  }

  void save() {
    setState(() {
      loading = true;
    });

    var shifts = shiftsMap.values.where((element) => element.isActive).map((e) {
      e.duration = getDuration(getTime(e.startAt), getTime(e.endAt));
      return e;
    }).toList();

    Api.post(EndPoints.dashboard_settings_saveDefaultShifts, {"defaultShifts": shifts}).then((res) {
      Map data = res.data;
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                save();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  loadData() {
    Api.get(EndPoints.dashboard_settings_getDefaultShifts, {}).then((res) {
      Map data = res.data;
      print(data);

      var List = DefaultShift.fromJsonArray(data["defaultShifts"]);
      shiftsMap = {
        ...shiftsMap,
        ...{for (var e in List) e.shiftName ?? '': e}
      };
    }).whenComplete(() {
      loading = false;
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                loadData();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
