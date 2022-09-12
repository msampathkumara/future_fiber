import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/Web/V/DashBoard/DateChooser.dart';
import 'package:smartwind/Web/V/DashBoard/M/Shift.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../C/Api.dart';

class DailyInputs extends StatefulWidget {
  const DailyInputs({Key? key}) : super(key: key);

  @override
  State<DailyInputs> createState() => _DailyInputsState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _DailyInputsState extends State<DailyInputs> {
  late String selectedDate;

  String getDateNow(hour) => DateFormat("yyyy-MM-dd hh:mm").format(DateTime(now.year, now.month, now.day, hour));

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getWebUi(), child: DialogView(child: getWebUi()));
  }

  @override
  initState() {
    selectedDate = DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, now.day));
    loadShift(selectedDate);
    super.initState();
  }

  List<Shift> defaultShift = [];
  List<Shift> dayShifts = [];

  DateTime now = DateTime.now();

  getWebUi() {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Inputs")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          ListTile(
              title: Wrap(
                children: [
                  const Text("Shift"),
                  DateChooser(
                    selectionMode: DateRangePickerSelectionMode.single,
                    onChose: (rangeStartDate, rangeEndDate) {
                      selectedDate = DateFormat("yyyy-MM-dd").format(rangeStartDate);
                      loadShift(selectedDate);
                    },
                  ),
                  TextButton(
                      onPressed: () {
                        loadShift(selectedDate);
                      },
                      child: const Text("Reset"))
                ],
              ),
              subtitle: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ...dayShifts
                          .map((e) => CheckboxListTile(
                                value: e.deleted == 0,
                                title: Row(children: [
                                  ElevatedButton(onPressed: null, child: Text(DateFormat("yyyy-MM-dd").format((e.startAt ?? DateTime.now())))),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                      onPressed: () async {
                                        // _selectTime(context, DateTime.parse(e.startAt ?? ''));
                                        final TimeOfDay? newTime = await showTimePicker(
                                            context: context, initialTime: TimeOfDay(hour: int.parse(DateFormat("hh").format((e.startAt ?? DateTime.now()))), minute: 00));
                                        DateTime d = (e.startAt ?? DateTime.now());
                                        e.startAt = DateTime(d.year, d.month, d.day, newTime?.hour ?? 0, 0);
                                        setState(() {});
                                      },
                                      child: Text(DateFormat("hh:mm").format((e.startAt ?? DateTime.now())))),
                                  const SizedBox(width: 20),
                                  ElevatedButton(onPressed: null, child: Text(DateFormat("yyyy-MM-dd").format((e.endAt ?? DateTime.now())))),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                      onPressed: () async {
                                        // _selectTime(context, DateTime.parse(e.startAt ?? ''));
                                        final TimeOfDay? newTime = await showTimePicker(
                                            context: context, initialTime: TimeOfDay(hour: int.parse(DateFormat("hh").format((e.endAt ?? DateTime.now()))), minute: 00));
                                        DateTime d = (e.endAt ?? DateTime.now());
                                        e.endAt = (DateTime(d.year, d.month, d.day, newTime?.hour ?? 0, 0));
                                        setState(() {});
                                      },
                                      child: Text(DateFormat("hh:mm").format((e.endAt ?? DateTime.now())))),
                                  const SizedBox(width: 20),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black38, width: 1),
                                      borderRadius: BorderRadius.circular(4), //border raiuds of dropdown button
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 60,
                                        child: DropdownButton<String>(
                                          underline: Container(),
                                          isDense: true,
                                          value: e.shiftName,
                                          icon: const Icon(Icons.arrow_downward, size: 12),
                                          elevation: 16,
                                          style: const TextStyle(color: Colors.deepPurple),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              e.shiftName = newValue!;
                                            });
                                          },
                                          items: <String>['morning', 'evening', 'night'].map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                                onChanged: (bool? value) {
                                  e.deleted = value == true ? 0 : 1;
                                  setState(() {});
                                },
                              ))
                          .toList(),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                            onPressed: () {
                              saveShifts();
                            },
                            child: const Text("Save")),
                      )
                    ],
                  ),
                ),
              )),
          ListTile(
              title: const Text("Employee Count"),
              subtitle: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ...defaultShift
                          .map((e) => Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [Text(getDateNow(e).toString())]),
                                  ...Production.values.map((e) => Padding(padding: const EdgeInsets.only(left: 16.0), child: Text(e.getValue())))
                                ],
                              ))
                          .toList()
                    ],
                  ),
                ),
              )),
        ]),
      ),
    );
  }

  getUi() {}

  void loadShift(date) {
    Api.get("dashboard/getShift", {'date': date}).then((res) {
      Map data = res.data;

      setState(() {
        dayShifts = Shift.fromJsonArray(data["dayShifts"]);
      });
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                loadShift(date);
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  DateTime selectedTime = DateTime.now();

  void saveShifts() {
    print('-------------${selectedDate}');
    Api.post("dashboard/saveShifts", {'dayShifts': dayShifts, 'date': selectedDate}).then((res) {
      Map data = res.data;
      setState(() {
        dayShifts = Shift.fromJsonArray(data["dayShifts"]);
      });
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                saveShifts();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
