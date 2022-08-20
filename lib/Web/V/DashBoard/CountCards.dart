import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind/V/Home/Tickets/TicketInfo/info_History.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../C/Api.dart';
import '../../../M/Enums.dart';
import 'M/ProgressSummery.dart';

class CountCards extends StatefulWidget {
  const CountCards({Key? key}) : super(key: key);

  @override
  State<CountCards> createState() => _CountCardsState();
}

class _CountCardsState extends State<CountCards> {
  var selectedProduction = Production.Upwind;
  var now = DateTime.now();
  DateTime? rangeStartDate = DateTime.now();

  DateTime? rangeEndDate = DateTime.now();

  DateTime? selectedDate = DateTime.now();

  String formatDate(DateTime date, {bool dateOnly = false}) => dateOnly ? DateFormat("yyyy MMMM d").format(date) : DateFormat("yyyy MMMM d HH:mm").format(date);

  List<Production> productionList = List.from(Production.values);

  @override
  void initState() {
    // TODO: implement initState
    rangeStartDate = DateTime(now.year, now.month, now.day, 0, 0);
    rangeEndDate = DateTime(now.year, now.month, now.day, 24);
    selectedDate = DateTime(now.year, now.month, now.day);

    productionList.removeWhere((element) => [Production.All, Production.None].contains(element));

    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(children: [
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 40,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Production>(
                  value: selectedProduction,
                  selectedItemBuilder: (_) {
                    return productionList.map<Widget>((Production item) {
                      return Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(item.getValue())));
                    }).toList();
                  },
                  items: productionList.map((Production value) {
                    return DropdownMenuItem<Production>(value: value, child: Text(value.getValue()));
                  }).toList(),
                  onChanged: (_) {
                    selectedProduction = _ ?? Production.Upwind;
                    setState(() {});
                    loadData();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 24,
          ),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: PopupMenuButton<int>(
                  offset: const Offset(0, 30),
                  padding: const EdgeInsets.all(16.0),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: Text("${formatDate(rangeStartDate!, dateOnly: rangeEndDate == null)} ${rangeEndDate == null ? "" : " - ${formatDate(rangeEndDate!)}"}"),
                  onSelected: (result) {},
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                    PopupMenuItem(
                      value: 0,
                      enabled: false,
                      child: SizedBox(
                          width: 500,
                          height: 300,
                          child: SfDateRangePicker(
                              initialSelectedRange: PickerDateRange(rangeStartDate, rangeEndDate),
                              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                                print(args.value);
                                rangeStartDate = null;
                                rangeEndDate = null;
                                selectedDate = null;
                                if (args.value is PickerDateRange) {
                                  rangeStartDate = args.value.startDate;
                                  rangeEndDate = args.value.endDate;
                                } else if (args.value is DateTime) {
                                  selectedDate = args.value;
                                } else if (args.value is List<DateTime>) {
                                  final List<DateTime> selectedDates = args.value;
                                } else {
                                  final List<PickerDateRange> selectedRanges = args.value;
                                }
                                setState(() {});
                              },
                              selectionMode: DateRangePickerSelectionMode.range)),
                    ),
                    PopupMenuItem(
                      value: 1,
                      enabled: false,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            loadData();
                          },
                          child: const Text('Done')),
                    )
                  ],
                ),
              ),
            ),
          )
        ]),
        for (var shiftName in progressSummeryByShiftName.keys)
          Wrap(children: [
            ListTile(
              title: Text(
                "$shiftName".capitalizeFirstofEach,
                style: const TextStyle(color: Colors.red),
              ),
              // subtitle: Text(progressSummeryByShiftName[shiftName][0]['startAt'] + "-" + progressSummeryByShiftName[shiftName][0]['endAt'])
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Table(
                border: TableBorder.symmetric(
                  // outside: BorderSide.none,
                  inside: BorderSide(width: 1, color: Colors.grey.shade200, style: BorderStyle.solid),
                ),
                children: [
                  const TableRow(children: [
                    Text("Section"),
                    Text("Volume(Output)"),
                    Text("employee Count"),
                    Text("Production Capacity"),
                    Text("Takt Time"),
                    Text("Cycle time"),
                    Text("Efficiency"),
                    Text("Number of Defects"),
                    Text("Defects Rate"),
                    Text("Scheduled baglock"),
                    Text("WIP")
                  ]),
                  ...progressSummeryByShiftName[shiftName]
                      .map((e) => TableRow(
                              children: [
                            Text("${e.sectionTitle}"),
                            Text("${e.volume ?? 0}"),
                            Text("${e.employeeCount ?? 0}"),
                            Text("${(e.capacity ?? 0).toStringAsFixed(1)}"),
                            Text(ProgressSummery.durationToString(((e.taktTime ?? 0) * 60).round())),
                            Text("${e.cycleTime ?? 0}"),
                            Text("${(e.efficiency ?? 0).toStringAsFixed(1)}%"),
                            Text("${e.defects ?? 0}"),
                            Text("${e.defectsRate ?? 0}%"),
                            Text(""),
                            Text("${e.wip ?? 0}")
                          ].map((e) => Padding(padding: const EdgeInsets.all(8.0), child: Container(alignment: Alignment.centerRight, child: e))).toList()))
                      .toList()
                ],
              ),
            )
          ]),
      ],
    );
  }

  List<ProgressSummery> progressSummery = [];
  Map progressSummeryByShiftName = {};

  void loadData() {
    Api.get("dashboard/x", {"rangeStartDate": rangeStartDate, 'rangeEndDate': rangeEndDate ?? rangeStartDate, 'production': selectedProduction.getValue()}).then((res) {
      Map data = res.data;
      progressSummeryByShiftName = {};
      progressSummery = ProgressSummery.fromJsonArray(data['x']);
      progressSummeryByShiftName = groupBy(progressSummery, (ProgressSummery obj) => obj.shiftName);
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      print(err);
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
