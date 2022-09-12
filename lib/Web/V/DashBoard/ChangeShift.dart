import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';
import 'package:smartwind/globals.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../C/Api.dart';
import 'M/Shift.dart';

class ChangeShifts extends StatefulWidget {
  const ChangeShifts({Key? key}) : super(key: key);

  @override
  State<ChangeShifts> createState() => _ChangeShiftsState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _ChangeShiftsState extends State<ChangeShifts> {
  bool loading = false;

  DateTime? selectedDate;

  List<Shift> _shiftsList = [];

  Map<String, Shift> shiftsMap = {};

  get isDateSelected => selectedDate != null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi(), width: 500, height: 500));
  }

  getWebUi() {
    return Scaffold(
        appBar: AppBar(title: const Text("Change Shifts Time")),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : !isDateSelected
                ? getDateSector()
                : Column(
                    children: [
                      getDateSector(),
                      const Divider(),
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
                                      Padding(padding: const EdgeInsets.all(8.0), child: Text((e.shiftName ?? '').capitalize())),
                                      (e.isActive) ? getTimeSelector(e.startAtTime, (TimeOfDay t) => e.setStartTime(t)) : Chip(label: Text(e.startAtTime.format(context))),
                                      (e.isActive) ? getTimeSelector(e.endAtTime, (t) => e.setEndTime(t)) : Chip(label: Text(e.endAtTime.format(context))),
                                      Padding(padding: const EdgeInsets.all(8.0), child: Text(dif(e.startAtTime, e.endAtTime)))
                                    ]))
                                .toList()
                          ],
                        ),
                      ),
                      Spacer()
                    ],
                  ),
        bottomNavigationBar: (loading || !isDateSelected)
            ? null
            : BottomAppBar(child: Padding(padding: const EdgeInsets.all(8.0), child: ElevatedButton(onPressed: save, child: const Text("Save")))));
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

  Widget getDateSector() {
    var x = [
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: PopupMenuButton<int>(
            offset: const Offset(0, 30),
            padding: const EdgeInsets.all(16.0),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Chip(
                label: Text(selectedDate == null ? "Select Date" : DateFormat('yyyy MMMM dd').format(selectedDate ?? DateTime.now()), style: const TextStyle(color: Colors.black))),
            onSelected: (result) {},
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<int>>[
                PopupMenuItem(
                  value: 0,
                  enabled: false,
                  child: SizedBox(
                      width: 500,
                      height: 300,
                      child: SfDateRangePicker(
                          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                            print(args.value);
                            if (args.value is DateTime) {
                              selectedDate = args.value;

                              getShiftsByDate();
                            }
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          selectionMode: DateRangePickerSelectionMode.single)),
                )
              ];
            }),
      ),
      const SizedBox(width: 16),
    ];

    return loading
        ? const Center(child: CircularProgressIndicator())
        : isDateSelected
            ? Row(children: x)
            : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: x));
  }

  getShiftsByDate() {
    setState(() {
      loading = true;
    });

    Api.get(EndPoints.dashboard_settings_getShiftsByDate, {'date': selectedDate}).then((res) {
      Map data = res.data;
      print(data);

      _shiftsList = Shift.fromJsonArray(data["shifts"]);

      _shiftsList.forEach((element) {
        print(element.toJson());
      });
      shiftsMap = {for (var e in _shiftsList) e.shiftName ?? '': e};
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: getShiftsByDate)));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  void save() {
    setState(() {
      loading = true;
    });

    var shifts = shiftsMap.values.where((element) => element.isActive).map((e) {
      e.duration = getDuration(e.startAtTime, e.endAtTime);
      print(e.toJson());
      return e;
    }).toList();

    Api.post(EndPoints.dashboard_settings_saveShifts, {"shifts": shifts}).then((res) {
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
}
