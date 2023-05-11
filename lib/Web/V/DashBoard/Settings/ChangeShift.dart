import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';
import 'package:smartwind_future_fibers/globals.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../C/Api.dart';
import '../M/Shift.dart';

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

  String? selectedFactory;

  late DateTime minStartTime = DateTime.now();

  DateTime? maxEndTime;

  bool get isFactorySelected => selectedFactory != null;

  bool get timeValidateOk {
    List<Map<String, DateTime>> times = [];

    times.add({'start': minStartTime.subtract(const Duration(hours: 1)), 'end': minStartTime});
    if (maxEndTime != null) {
      times.add({'start': maxEndTime!, 'end': maxEndTime!.add(const Duration(hours: 1))});
    }

    for (var e in _shiftsList) {
      DateTime? d = e.startAt;
      TimeOfDay? t = e.startAtTime;
      DateTime start = DateTime(d?.year ?? 0, d?.month ?? 0, d?.day ?? 0, t.hour, t.minute);
      DateTime end = start.add(Duration(minutes: int.parse("${getDuration(e.startAtTime, e.endAtTime) * 60}")));
      times.add({'start': start, 'end': end});
    }

    // times.sort((a, b) => (a['start'])!.compareTo(b['start']!));

    bool x = true;

    times.sort((a, b) {
      // print('${a['start']} -${a['end']} --- ${b['start']} - ${b['end']} ');
      //
      // print('${a['start'].isNotBetween(b['start']!, b['end']!)}'
      //     ' ${b['start'].isNotBetween(a['start']!, a['end']!)}'
      //     ' ${a['end'].isNotBetween(b['start']!, a['end']!)}'
      //     ' ${b['end'].isNotBetween(a['start']!, a['end']!)}');

      if (a['start'].isNotBetween(b['start']!, b['end']!)! &&
          b['start'].isNotBetween(a['start']!, a['end']!)! &&
          a['end'].isNotBetween(b['start']!, a['end']!)! &&
          b['end'].isNotBetween(a['start']!, a['end']!)!) {
      } else {
        x = false;
      }

      return (b['start'])!.compareTo(a['start']!);
    });

    print('------------------------ $x ----------------------');

    return x;
  }

// get isDateSelected => selectedDate != null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getWebUi(), child: DialogView(width: 500, height: 500, child: getWebUi()));
  }

  Scaffold getWebUi() {
    return Scaffold(
        appBar: AppBar(title: const Text("Change Shifts Time")),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : !isFactorySelected
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
                                      getTimeSelector(e.startAtTime, (TimeOfDay t) => e.setStartTime(t)),
                                      getTimeSelector(e.endAtTime, (t) => e.setEndTime(t)),
                                      Padding(padding: const EdgeInsets.all(8.0), child: Text(dif(e.startAtTime, e.endAtTime)))
                                    ]))
                                .toList()
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (maxEndTime != null) Text("Maximum end time :${DateFormat('yyyy-MM-dd HH:mm').format(maxEndTime!)}", style: const TextStyle(color: Colors.red)),
                      Text("Minimum start time :${DateFormat('yyyy-MM-dd HH:mm').format(minStartTime)}", style: const TextStyle(color: Colors.red))
                    ],
                  ),
        bottomNavigationBar: (loading || !isFactorySelected)
            ? null
            : BottomAppBar(child: Padding(padding: const EdgeInsets.all(8.0), child: ElevatedButton(onPressed: (timeValidateOk) ? save : null, child: const Text("Save")))));
  }

  String dif(TimeOfDay t1, TimeOfDay t2) {
    int min = ((t2.hour * 60 + t2.minute)) - ((t1.hour * 60 + t1.minute));

    return '${(Duration(minutes: min > 0 ? min : (24 * 60) - min.abs()))}'.split('.')[0].padLeft(8, '0');
  }

  double getDuration(TimeOfDay t1, TimeOfDay t2) {
    int min = ((t2.hour * 60 + t2.minute)) - ((t1.hour * 60 + t1.minute));
    return (min > 0 ? min : (24 * 60) - min.abs()) / 60;
  }

  MediaQuery getTimeSelector(TimeOfDay time, f) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: ActionChip(
        backgroundColor: getPrimaryColor(context),
        label: Text(time.format(context), style: const TextStyle(color: Colors.white)),
        // label: Text("${time.hour}:${time.minute}", style: const TextStyle(color: Colors.white)),
        onPressed: () async {
          final TimeOfDay? newTime = await showTimePicker(
              context: context,
              initialTime: time,
              initialEntryMode: TimePickerEntryMode.input,
              builder: (context, childWidget) {
                return MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: childWidget!);
              });
          print("${newTime?.hour}");
          if (newTime != null) {
            f(newTime);
            setState(() {});
          }
        },
      ),
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
                              if (args.value is DateTime) {
                                selectedDate = args.value;
                              }
                              Navigator.of(context).pop();
                              if (selectedFactory != null) {
                                getShiftsByDate();
                              } else {
                                setState(() {});
                              }
                            },
                            selectionMode: DateRangePickerSelectionMode.single)))
              ];
            }),
      ),
      const SizedBox(width: 16),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: PopupMenuButton<int>(
            enabled: selectedDate != null,
            offset: const Offset(0, 30),
            padding: const EdgeInsets.all(16.0),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Chip(label: Text(selectedFactory ?? 'Select Factory', style: const TextStyle(color: Colors.black))),
            onSelected: (result) {},
            itemBuilder: (BuildContext context) {
              return Production.values
                  .without([Production.None, Production.All])
                  .map((e) => PopupMenuItem(
                      onTap: () {
                        selectedFactory = e.getValue();
                        // loadData();
                        getShiftsByDate();
                      },
                      value: 0,
                      enabled: true,
                      child: Text(e.getValue())))
                  .toList();
            }),
      )
    ];

    return loading
        ? const Center(child: CircularProgressIndicator())
        : isFactorySelected
            ? Row(children: x)
            : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: x));
  }

  getShiftsByDate() {
    setState(() {
      loading = true;
    });

    Api.get(EndPoints.dashboard_settings_getShiftsByDate, {'date': selectedDate, 'factory': selectedFactory}).then((res) {
      Map data = res.data;

      _shiftsList = Shift.fromJsonArray(data["shifts"]);
      minStartTime = data["minStartTime"] == null ? DateTime.now() : Shift.stringToDateTime(data["minStartTime"]);
      maxEndTime = data["maxEndTime"] == null ? null : Shift.stringToDateTime(data["maxEndTime"]);

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

      return e;
    }).toList();

    Api.post(EndPoints.dashboard_settings_saveShifts, {"shifts": shifts, 'factory': selectedFactory}).then((res) {}).whenComplete(() {
      Navigator.pop(context);
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: save)));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
