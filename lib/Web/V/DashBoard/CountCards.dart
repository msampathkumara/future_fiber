import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/Mobile/V/Home/Tickets/TicketInfo/info_History.dart';
import 'package:smartwind_future_fibers/Web/V/DashBoard/M/ShiftFactorySummery.dart';
import 'package:smartwind_future_fibers/Web/V/DashBoard/M/WeekPicker.dart';
import 'package:smartwind_future_fibers/Web/V/DashBoard/WipTicketList.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../C/Api.dart';
import '../../../M/AppUser.dart';
import '../../../M/Enums.dart';
import '../../../M/PermissionsEnum.dart';
import '../../../Mobile/V/Widgets/NoResultFoundMsg.dart';
import '../../../globals.dart';
import 'LineChart.dart';
import 'M/MonthPicker.dart';
import 'M/ProgressSummery.dart';
import 'Settings/AddAvarageSailTimes.dart';
import 'Settings/AddDefaultEmployeeCounts.dart';
import 'Settings/AddDefaultShifts.dart';
import 'Settings/AddEmployeeCounts.dart';
import 'Settings/ChangeShift.dart';

enum DaysFilters { Today, Yesterday, Week, Month, Year, Custom }

extension DaysFiltersex on DaysFilters {
  String getValue() {
    return (this).toString().split('.').last;
  }

  String getText() {
    return (this).toString().split('.').last.split("_").join(" ");
  }
}

class CountCards extends StatefulWidget {
  const CountCards({Key? key}) : super(key: key);

  @override
  State<CountCards> createState() => _CountCardsState();
}

class _CountCardsState extends State<CountCards> {
  var selectedProduction = Production.Upwind;
  var now = DateTime.now();
  DateTime rangeStartDate = DateTime.now();

  DateTime? rangeEndDate = DateTime.now();

  DateTime? selectedDate = DateTime.now();

  Map<String?, bool> shiftsExpanded = {};

  var valSt = const TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
  var nameSt = const TextStyle(color: Colors.grey);

  List<ShiftFactorySummery> shiftFactorySummeryList = [];

  DaysFilters _selectedFilter = DaysFilters.Today;

  ShiftFactorySummery? _allShiftSummery;

  String _title = DaysFilters.Today.getText();

  LineChartController lineChartController = LineChartController();

  bool singleDate = false;

  get isSingleDay => singleDate || (_selectedFilter == DaysFilters.Today || _selectedFilter == DaysFilters.Yesterday);

  String formatDate(DateTime date, {bool dateOnly = false}) => dateOnly ? DateFormat("yyyy MMMM d").format(date) : DateFormat("yyyy MMMM d HH:mm ").format(date);

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
    List _shifts = getCommens(progressSummeryByShiftName.keys.toList(), ['morning', 'evening', 'night']);
    print(progressSummeryByShiftName.keys);
    print(_shifts);
    print("-------------------------------------------------------shifts");
    return Stack(
      children: [
        loading
            ? const Center(child: CircularProgressIndicator())
            : _allShiftSummery == null
                ? const Center(child: NoResultFoundMsg())
                : Container(),
        if (_allShiftSummery == null) const Center(child: NoResultFoundMsg()),
        ListView(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(children: [
                  SizedBox(
                    width: 400,
                    child: ListTile(
                        title: Text(_title, textScaleFactor: 1.2, style: const TextStyle(color: Colors.black)),
                        subtitle: Text(
                            "${formatDate(rangeStartDate, dateOnly: rangeEndDate == null)} ${rangeEndDate == null ? "" : " to ${formatDate(rangeEndDate!.subtract(const Duration(seconds: 1)))}"}")),
                  ),
                  const Spacer(),
                  // ElevatedButton(
                  //   child: const Text("Request permission"),
                  //   onPressed: () async {
                  //     final perm = await html.window.navigator.permissions?.query({"name": "pop-ups"});
                  //     if (perm?.state == "denied") {
                  //       snackBarKey.currentState?.showSnackBar(const SnackBar(
                  //         content: Text("Oops! Camera access denied!"),
                  //         backgroundColor: Colors.orangeAccent,
                  //       ));
                  //       return;
                  //     }
                  //     // final stream = await html.window.navigator.getUserMedia(video: true);
                  //   },
                  // ),
                  Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: PopupMenuButton<Production>(
                          offset: const Offset(0, 30),
                          padding: const EdgeInsets.all(16.0),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          child: Chip(avatar: const Icon(Icons.factory), label: Row(children: [Text(selectedProduction.getValue()), const Icon(Icons.arrow_drop_down_rounded)])),
                          onSelected: (result) {},
                          itemBuilder: (BuildContext context) {
                            return productionList.map((Production value) {
                              return PopupMenuItem<Production>(
                                  value: value,
                                  onTap: () {
                                    selectedProduction = value;
                                    setState(() {});
                                    loadData();
                                  },
                                  child: Text(value.getValue()));
                            }).toList();
                          })),
                  const SizedBox(width: 8),
                  Container(width: 1, color: Colors.red, height: 24),
                  const SizedBox(width: 8),
                  ...[DaysFilters.Today, DaysFilters.Yesterday].map((e) => Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: FilterChip(
                        labelStyle: TextStyle(
                          color: _selectedFilter == e ? Colors.white : Colors.black,
                        ),
                        checkmarkColor: _selectedFilter == e ? Colors.white : Colors.black,
                        label: Text(e.getText()),
                        selected: _selectedFilter == e,
                        selectedColor: Colors.red,
                        onSelected: (x) {
                          setState(() {
                            _selectedFilter = e;
                          });
                          loadData();
                        },
                      ))),
                  ...DaysFilters.values
                      .without([DaysFilters.Today, DaysFilters.Yesterday])
                      .map((e) => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: PopupMenuButton<int>(
                              offset: const Offset(0, 30),
                              padding: const EdgeInsets.all(16.0),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                              child: Chip(
                                  backgroundColor: _selectedFilter == e ? Colors.red : null,
                                  avatar: _selectedFilter == e ? const Icon(Icons.check, color: Colors.white) : null,
                                  label: Text(e.getText(), style: TextStyle(color: _selectedFilter == e ? Colors.white : Colors.black))),
                              onSelected: (result) {},
                              itemBuilder: (BuildContext context) {
                                return getFilterValues(e);
                              })))
                      .toList(),
                  ...getSettingsMenu()
                ]),
              ),
            ),
            const SizedBox(height: 16),
            if (!loading && _allShiftSummery != null)
              Wrap(
                children: [
                  if (_allShiftSummery != null) getShiftsTotal(_allShiftSummery!),
                  if (!isSingleDay) ...[const SizedBox(height: 24), SizedBox(height: 450, child: LineChart(controller: lineChartController)), const SizedBox(height: 24)],
                  ExpansionPanelList(
                    expandedHeaderPadding: const EdgeInsets.all(16),
                    dividerColor: Colors.blue,
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        shiftsExpanded[_shifts[index]] = !isExpanded;
                      });
                    },
                    children: [
                      for (String shiftName in _shifts)
                        ExpansionPanel(
                          isExpanded: shiftsExpanded[shiftName] ?? false,
                          body: Card(
                            elevation: 0,
                            child: Wrap(children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Table(
                                  border: TableBorder.symmetric(
                                    // outside: BorderSide.none,
                                    inside: BorderSide(width: 1, color: Colors.grey.shade300, style: BorderStyle.solid),
                                  ),
                                  children: [
                                    TableRow(
                                        children: [
                                      const Text("Section"),
                                      const Text("Volume (Output)"),
                                      const Text("Started Ticket Count"),
                                      const Text("employee Count"),
                                      const Text("Production Capacity"),
                                      const Text("Takt Time"),
                                      const Text("Cycle time"),
                                      const Text("Efficiency"),
                                      const Text("Number of Defects"),
                                      const Text("Defects Rate"),
                                      // const Text("Scheduled backlog"),
                                      const Text("WIP")
                                    ].map((e) => Padding(padding: const EdgeInsets.all(8.0), child: e)).toList()),
                                    ...(progressSummeryByShiftName[shiftName] ?? [ProgressSummery()])
                                        .map((ProgressSummery e) => TableRow(
                                                children: [
                                              Container(alignment: Alignment.centerLeft, child: Text("${e.sectionTitle}")),
                                              Container(alignment: Alignment.centerRight, child: Text("${e.volume ?? 0}")),
                                              Container(alignment: Alignment.centerRight, child: Text("${e.startedTicketCount ?? 0}")),
                                              Container(alignment: Alignment.centerRight, child: Text("${e.employeeCount ?? 0}")),
                                              Container(alignment: Alignment.centerRight, child: Text((e.capacity ?? 0).toStringAsFixed(1))),
                                              Container(alignment: Alignment.centerRight, child: Text(ProgressSummery.durationToString(((e.taktTime ?? 0) * 60).round()))),
                                              Container(alignment: Alignment.centerRight, child: Text(ProgressSummery.durationToString(((e.cycleTime ?? 0) * 60).round()))),
                                              Container(alignment: Alignment.centerRight, child: Text("${(e.efficiency ?? 0).toStringAsFixed(1)}%")),
                                              Container(alignment: Alignment.centerRight, child: Text("${e.defects ?? 0}")),
                                              Container(alignment: Alignment.centerRight, child: Text("${(e.defectsRate ?? 0).toStringAsFixed(2)}%")),
                                              Container(
                                                  alignment: Alignment.centerRight,
                                                  child: InkWell(onTap: () => WipTicketList(e.sectionId).show(context), child: Text("${e.wip ?? 0}")))
                                            ].map((e) => Padding(padding: const EdgeInsets.all(8.0), child: e)).toList()))
                                        .toList()
                                  ],
                                ),
                              )
                            ]),
                          ),
                          headerBuilder: (BuildContext context, bool isExpanded) {
                            ShiftFactorySummery? shiftFactorySummery = shiftFactorySummeryList.singleWhere((element) => element.shiftName == shiftName);

                            return ListTile(
                              leading:
                                  Padding(padding: const EdgeInsets.only(top: 8.0), child: shiftName.icon(shiftFactorySummery.isCurrentShift ? Colors.deepOrange : Colors.grey)),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(padding: const EdgeInsets.only(top: 16.0), child: Text(shiftName.capitalizeFirstofEach, style: const TextStyle(color: Colors.black))),
                                  if (isSingleDay)
                                    Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child:
                                            Text("${shiftFactorySummery.startAtTime} - ${shiftFactorySummery.endAtTime}", style: const TextStyle(fontSize: 12, color: Colors.red))),
                                ],
                              ),
                              subtitle: Table(
                                children: [
                                  TableRow(children: [
                                    ListTile(
                                        title: Text("Volume", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text("${shiftFactorySummery.volume ?? 0}", style: valSt, textScaleFactor: 1.2)),
                                    ListTile(
                                        title: Text("Start Count", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text("${shiftFactorySummery.startedTicketCount ?? 0}", style: valSt, textScaleFactor: 1.2)),
                                    ListTile(
                                        title: Text("Employees", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text("${shiftFactorySummery.employeeCount ?? 0}", style: valSt, textScaleFactor: 1.2)),
                                    ListTile(
                                        title: Text("Production Capacity", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text((shiftFactorySummery.capacity ?? 0).toStringAsFixed(2), style: valSt, textScaleFactor: 1.2)),
                                    ListTile(
                                        title: Text("Takt Time", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text((shiftFactorySummery.taktTime ?? 0).timeFromHours(), style: valSt, textScaleFactor: 1.2)),
                                    ListTile(
                                        title: Text("Cycle Time", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text((shiftFactorySummery.cycleTime ?? 0).timeFromHours(), style: valSt, textScaleFactor: 1.2)),
                                    ListTile(
                                        title: Text("Efficiency", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text("${(shiftFactorySummery.efficiency ?? 0).toStringAsFixed(2)}%", style: valSt, textScaleFactor: 1.2)),
                                    ListTile(
                                        title: Text("Defects", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text("${shiftFactorySummery.defects ?? 0}", style: valSt, textScaleFactor: 1.2)),
                                    ListTile(
                                        title: Text("Defects Rate", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text("${(shiftFactorySummery.defectsRate ?? 0).toStringAsFixed(2)}%", style: valSt, textScaleFactor: 1.2)),
                                    ListTile(
                                        title: Text("Backlog", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text("${shiftFactorySummery.backLog ?? 0}", style: valSt, textScaleFactor: 1.2)),
                                    ListTile(
                                        title: Text("WIP", style: nameSt, textScaleFactor: 0.8),
                                        subtitle: Text("${shiftFactorySummery.wip ?? 0}", style: valSt, textScaleFactor: 1.2)),
                                  ])
                                ],
                              ),
                              // subtitle: Text(progressSummeryByShiftName[shiftName][0]['startAt'] + "-" + progressSummeryByShiftName[shiftName][0]['endAt'])
                            );
                          },
                        ),
                    ],
                  ),
                ],
              )
          ],
        ),
      ],
    );
  }

  List<ProgressSummery> progressSummery = [];
  Map progressSummeryByShiftName = {};
  bool loading = true;

  void loadData() {
    now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    // singleDate = false;

    switch (_selectedFilter) {
      case DaysFilters.Today:
        rangeStartDate = today;
        rangeEndDate = DateTime(now.year, now.month, now.day, 24);
        _title = DaysFilters.Today.getText();
        break;
      case DaysFilters.Yesterday:
        rangeStartDate = today.subtract(const Duration(days: 1));
        rangeEndDate = rangeStartDate.add(const Duration(hours: 24));
        _title = DaysFilters.Yesterday.getText();
        break;
      case DaysFilters.Week:
        // if(rangeEndDate?.second==0) {
        //   rangeEndDate = rangeEndDate?.add(const Duration(hours:24));
        // }
        singleDate = false;
        break;
      case DaysFilters.Month:
        rangeEndDate = DateTime(rangeStartDate.year, rangeStartDate.month + 1, 0).add(const Duration(days: 1));
        _title = DateFormat("yyyy MMMM").format(rangeStartDate);
        singleDate = false;
        break;
      case DaysFilters.Year:
        rangeEndDate = DateTime(rangeStartDate.year + 1, rangeStartDate.month, 0).add(const Duration(days: 1));
        _title = DateFormat("yyyy").format(rangeStartDate);
        singleDate = false;
        break;
      case DaysFilters.Custom:
        rangeEndDate ??= rangeStartDate.add(const Duration(hours: 24));
        break;
    }

    print("$rangeStartDate to $rangeEndDate");
    setState(() {
      loading = true;
    });

    Api.get(EndPoints.dashboard_x, {"rangeStartDate": rangeStartDate, 'rangeEndDate': rangeEndDate ?? rangeStartDate, 'production': selectedProduction.getValue()}).then((res) {
      Map data = res.data;
      progressSummeryByShiftName = {};
      progressSummery = ProgressSummery.fromJsonArray(data['shiftSectionSummary']);
      shiftFactorySummeryList = ShiftFactorySummery.fromJsonArray(data['shiftSummary']);
      _allShiftSummery = ShiftFactorySummery.fromJsonArray(data['factorySummary']).firstOrNull;
      progressSummeryByShiftName = groupBy(progressSummery, (ProgressSummery obj) => obj.shiftName ?? '');

      if (_selectedFilter != DaysFilters.Today && _selectedFilter != DaysFilters.Yesterday && !singleDate) {
        lineChartController.updateData(rangeStartDate, rangeEndDate, selectedProduction, _selectedFilter, ProgressSummery.fromJsonArray(data['graphData']));
      }

      // print(data);
    }).whenComplete(() {
      if (mounted) {
        setState(() => {loading = false});
      }
    }).catchError((err) {
      print(err);
      snackBarKey.currentState?.showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: loadData)));
      if (mounted) {
        setState(() => {
              // _dataLoadingError = true;
            });
      }
    });
  }

  getCommens(List list, Iterable<dynamic> keys) {
    List k = keys.map((e) => e.toString().toLowerCase()).toList();
    list.removeWhere((item) => !k.contains(item.toLowerCase()));
    return list;
  }

  var valSt1 = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  var nameSt1 = const TextStyle(color: Colors.white);

  Widget getShiftsTotal(ShiftFactorySummery allShiftSummery) {
    return Card(
        elevation: 4,
        color: Colors.green,
        child: ListTile(
          // leading: Padding(padding: const EdgeInsets.only(top: 8.0), child: shiftName.icon),
          // title: Padding(padding: const EdgeInsets.only(top: 16.0), child: Text(shiftName.capitalizeFirstofEach, style: const TextStyle(color: Colors.black))),
          subtitle: Table(
            children: [
              TableRow(children: [
                ListTile(
                    title: Text("Volume", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text("${allShiftSummery.volume ?? 0}", style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
                ListTile(
                    title: Text("Employees", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text("${allShiftSummery.employeeCount ?? 0}", style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
                ListTile(
                    title: Text("Started Count", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text("${allShiftSummery.startedTicketCount ?? 0}", style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
                ListTile(
                    title: Text("Production Capacity", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text((allShiftSummery.capacity ?? 0).toStringAsFixed(2), style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
                ListTile(
                    title: Text("Takt Time", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text((allShiftSummery.taktTime ?? 0).timeFromHours(), style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
                ListTile(
                    title: Text("Cycle Time", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text((allShiftSummery.cycleTime ?? 0).timeFromHours(), style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
                ListTile(
                    title: Text("Efficiency", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text("${(allShiftSummery.efficiency ?? 0).toStringAsFixed(2)}%", style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
                ListTile(
                    title: Text("Defects", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text("${allShiftSummery.defects ?? 0}", style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
                ListTile(
                    title: Text("Defects Rate", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text("${(allShiftSummery.defectsRate ?? 0).toStringAsFixed(2)}%", style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
                ListTile(
                    title: Text("Backlog", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text("${allShiftSummery.backLog ?? 0}", style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
                ListTile(
                    title: Text("WIP", style: nameSt1, textScaleFactor: 0.8, textAlign: TextAlign.center),
                    subtitle: Text("${allShiftSummery.wip ?? 0}", style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
              ])
            ],
          ),
          // subtitle: Text(progressSummeryByShiftName[shiftName][0]['startAt'] + "-" + progressSummeryByShiftName[shiftName][0]['endAt'])
        ));
  }

  List<PopupMenuEntry<int>> getFilterValues(DaysFilters e) {
    return <PopupMenuEntry<int>>[
      if (e == DaysFilters.Year)
        PopupMenuItem(
            child: SizedBox(
                width: 350,
                height: 300,
                child: YearPicker(
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 390)),
                    selectedDate: DateTime(DateTime.now().year),
                    onChanged: (DateTime d) {
                      rangeStartDate = d;
                      _selectedFilter = DaysFilters.Year;
                      loadData();
                      Navigator.of(context).pop();
                    }))),
      if (e == DaysFilters.Month)
        PopupMenuItem(
            child: SizedBox(
                width: 350,
                height: 320,
                child: MonthPicker(
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 390)),
                    selectedDate: DateTime.now(),
                    onSelect: (DateTime month) {
                      rangeStartDate = month;
                      _selectedFilter = DaysFilters.Month;
                      loadData();
                      Navigator.of(context).pop();
                    }))),
      if (e == DaysFilters.Custom) ...[
        PopupMenuItem(
          value: 0,
          enabled: false,
          child: SizedBox(
              width: 500,
              height: 300,
              child: SfDateRangePicker(
                  initialSelectedRange: PickerDateRange(rangeStartDate, rangeEndDate),
                  maxDate: DateTime.now(),
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    print(args.value);

                    rangeEndDate = null;
                    selectedDate = null;
                    if (args.value is PickerDateRange) {
                      rangeStartDate = args.value.startDate;
                      rangeEndDate = args.value.endDate;
                      if (rangeStartDate == rangeEndDate) {
                        rangeEndDate = null;
                      }
                    } else if (args.value is DateTime) {
                      selectedDate = args.value;
                    } else if (args.value is List<DateTime>) {
                    } else {}
                    rangeEndDate = rangeEndDate == rangeStartDate ? null : rangeEndDate;
                    if (rangeEndDate == null || rangeStartDate.isSameDate(rangeEndDate!)) {
                      singleDate = true;
                    } else {
                      singleDate = false;
                    }
                    _title = singleDate
                        ? DateFormat("yyyy MMMM dd").format(rangeStartDate)
                        : "${DateFormat("yyyy/MM/dd").format(rangeStartDate)} to ${DateFormat("yyyy/MM/dd").format(rangeEndDate!)}";
                    // setState(() {});
                  },
                  selectionMode: DateRangePickerSelectionMode.range)),
        ),
        PopupMenuItem(
          value: 1,
          enabled: false,
          child: ElevatedButton(
              onPressed: () {
                _selectedFilter = DaysFilters.Custom;
                Navigator.of(context).pop();
                loadData();
              },
              child: const Text('Done')),
        )
      ],
      if (e == DaysFilters.Week)
        PopupMenuItem(
            child: SizedBox(
                width: 350,
                height: 320,
                child: WeekPicker(
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 390)),
                    selectedDate: DateTime.now(),
                    onSelect: (DateTime start, DateTime end, year, week) {
                      rangeStartDate = start;
                      rangeEndDate = end;
                      rangeEndDate = rangeEndDate?.add(const Duration(hours: 24));
                      _selectedFilter = DaysFilters.Week;
                      _title = "$week ${getNumberSuffix(week)} week $year ";
                      loadData();
                      Navigator.of(context).pop();
                    }))),
    ];
  }

  String getNumberSuffix(int dayNum) {
    if (dayNum >= 11 && dayNum <= 13) {
      return 'th';
    }

    switch (dayNum % 10) {
      case 1:
        return 'th';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  List<Widget> getSettingsMenu() {
    return [
      const SizedBox(width: 24),
      Container(width: 1, color: Colors.red, height: 24),
      const SizedBox(width: 24),
      PopupMenuButton<int>(
          tooltip: 'Settings',
          offset: const Offset(0, 0),
          padding: const EdgeInsets.all(16.0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: const Icon(Icons.settings, color: Colors.redAccent),
          onSelected: (result) async {
            print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ${result}');
            if (result == 0) {
              await const AddEmployeeCounts().show(context);
            } else if (result == 1) {
              await const AddDefaultEmployeeCounts().show(context);
            } else if (result == 2) {
              await const AddDefaultShifts().show(context);
            } else if (result == 3) {
              await const ChangeShifts().show(context);
            } else if (result == 4) {
              await const AddAverageSailTimes().show(context);
            }
          },
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<int>>[
              if (AppUser.havePermissionFor(NsPermissions.DASHBOARD_ADD_EMPLOYEE_COUNT)) const PopupMenuItem(value: 0, enabled: true, child: Text("Add Employee Counts")),
              if (AppUser.havePermissionFor(NsPermissions.DASHBOARD_SET_DEFAULT_EMPLOYEE_COUNT))
                const PopupMenuItem(value: 1, enabled: true, child: Text("Set default Employee Counts")),
              if (AppUser.havePermissionFor(NsPermissions.DASHBOARD_SET_DEFAULT_SHIFTS)) const PopupMenuItem(value: 2, enabled: true, child: Text("Set Default shifts")),
              if (AppUser.havePermissionFor(NsPermissions.DASHBOARD_CHANGE_SHIFT_TIME)) const PopupMenuItem(value: 3, enabled: true, child: Text("Change Shift Time")),
              if (AppUser.havePermissionFor(NsPermissions.DASHBOARD_SET_AVERAGE_SAIL_TIME)) const PopupMenuItem(value: 4, enabled: true, child: Text("Set Average Sail Times"))
            ];
          }),
      const SizedBox(width: 36)
    ];
  }
}
