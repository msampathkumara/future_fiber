import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind/V/Home/Tickets/TicketInfo/info_History.dart';
import 'package:smartwind/V/Widgets/NoResultFoundMsg.dart';
import 'package:smartwind/Web/V/DashBoard/M/ShiftFactorySummery.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../C/Api.dart';
import '../../../M/Enums.dart';
import 'LineChart.dart';
import 'M/MonthPicker.dart';
import 'M/ProgressSummery.dart';

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
    var _shifts = getCommens(['morning', 'evening', 'night'], progressSummeryByShiftName.keys);
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
          const SizedBox(width: 24),
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
                        }),
                  ))
              .toList(),
        ]),
        const SizedBox(height: 24),
        ListTile(
            title: Text(_title, textScaleFactor: 2, style: const TextStyle(color: Colors.black)),
            subtitle: Text("${formatDate(rangeStartDate, dateOnly: rangeEndDate == null)} ${rangeEndDate == null ? "" : " to ${formatDate(rangeEndDate!)}"}")),
        (loading)
            ? const Center(child: CircularProgressIndicator())
            : _allShiftSummery == null
                ? const Center(child: NoResultFoundMsg())
                : Wrap(
                    children: [
                      if (_allShiftSummery != null) getShiftsTotal(_allShiftSummery!),
                      if (_selectedFilter != DaysFilters.Today && _selectedFilter != DaysFilters.Yesterday) ...[
                        const SizedBox(height: 24),
                        const SizedBox(height: 200, child: LineChart()),
                        const SizedBox(height: 24)
                      ],
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
                                          const Text("employee Count"),
                                          const Text("Production Capacity"),
                                          const Text("Takt Time"),
                                          const Text("Cycle time"),
                                          const Text("Efficiency"),
                                          const Text("Number of Defects"),
                                          const Text("Defects Rate"),
                                          const Text("Scheduled backlog"),
                                          const Text("WIP")
                                        ].map((e) => Padding(padding: const EdgeInsets.all(8.0), child: e)).toList()),
                                        ...progressSummeryByShiftName[shiftName]
                                            .map((e) => TableRow(
                                                    children: [
                                                  Container(alignment: Alignment.centerLeft, child: Text("${e.sectionTitle}")),
                                                  Container(alignment: Alignment.centerRight, child: Text("${e.volume ?? 0}")),
                                                  Container(alignment: Alignment.centerRight, child: Text("${e.employeeCount ?? 0}")),
                                                  Container(alignment: Alignment.centerRight, child: Text("${(e.capacity ?? 0).toStringAsFixed(1)}")),
                                                  Container(alignment: Alignment.centerRight, child: Text(ProgressSummery.durationToString(((e.taktTime ?? 0) * 60).round()))),
                                                  Container(
                                                      alignment: Alignment.centerRight, child: Text("${ProgressSummery.durationToString(((e.cycleTime ?? 0) * 60).round())}")),
                                                  Container(alignment: Alignment.centerRight, child: Text("${(e.efficiency ?? 0).toStringAsFixed(1)}%")),
                                                  Container(alignment: Alignment.centerRight, child: Text("${e.defects ?? 0}")),
                                                  Container(alignment: Alignment.centerRight, child: Text("${(e.defectsRate ?? 0).toStringAsFixed(2)}%")),
                                                  Container(alignment: Alignment.centerRight, child: const Text("")),
                                                  Container(alignment: Alignment.centerRight, child: Text("${e.wip ?? 0}"))
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
                                  leading: Padding(
                                      padding: const EdgeInsets.only(top: 8.0), child: shiftName.icon(shiftFactorySummery.isCurrentShift ? Colors.deepOrange : Colors.grey)),
                                  title:
                                      Padding(padding: const EdgeInsets.only(top: 16.0), child: Text(shiftName.capitalizeFirstofEach, style: const TextStyle(color: Colors.black))),
                                  subtitle: Table(
                                    children: [
                                      TableRow(children: [
                                        ListTile(
                                            title: Text("Volume", style: nameSt, textScaleFactor: 0.8),
                                            subtitle: Text("${shiftFactorySummery.volume ?? 0}", style: valSt, textScaleFactor: 1.2)),
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
                                            subtitle: Text("${shiftFactorySummery.defectsRate ?? 0}%", style: valSt, textScaleFactor: 1.2)),
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
    );
  }

  List<ProgressSummery> progressSummery = [];
  Map progressSummeryByShiftName = {};
  bool loading = true;

  void loadData() {
    DateTime today = DateTime(now.year, now.month, now.day);

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
        rangeStartDate = DateTime.now().subtract(const Duration(days: 7));
        rangeEndDate = DateTime.now();
        break;
      case DaysFilters.Month:
        rangeEndDate = DateTime(rangeStartDate.year, rangeStartDate.month + 1, 0);
        _title = DateFormat("yyyy MMMM").format(rangeStartDate);
        break;
      case DaysFilters.Year:
        rangeEndDate = DateTime(rangeStartDate.year + 1, rangeStartDate.month, 0);
        _title = DateFormat("yyyy").format(rangeStartDate);
        break;
      case DaysFilters.Custom:
        rangeEndDate = rangeEndDate == rangeStartDate ? null : rangeEndDate;
        _title = (rangeEndDate == null)
            ? DateFormat("yyyy MMMM dd").format(rangeStartDate)
            : "${DateFormat("yyyy/MM/dd").format(rangeStartDate)} to ${DateFormat("yyyy/MM/dd").format(rangeEndDate!)}";

        rangeEndDate ??= rangeStartDate.add(const Duration(hours: 24));
        break;
    }
    print("$rangeStartDate to $rangeEndDate");
    setState(() {
      loading = true;
    });
    // ServerApi.dashboard_x({"rangeStartDate": rangeStartDate, 'rangeEndDate': rangeEndDate ?? rangeStartDate, 'production': selectedProduction.getValue()}).then((res) {
    Api.get("dashboard/x", {"rangeStartDate": rangeStartDate, 'rangeEndDate': rangeEndDate ?? rangeStartDate, 'production': selectedProduction.getValue()}).then((res) {
      Map data = res.data;
      progressSummeryByShiftName = {};
      progressSummery = ProgressSummery.fromJsonArray(data['shiftSectionSummary']);
      shiftFactorySummeryList = ShiftFactorySummery.fromJsonArray(data['shiftSummary']);
      _allShiftSummery = ShiftFactorySummery.fromJsonArray(data['factorySummary']).firstOrNull;
      progressSummeryByShiftName = groupBy(progressSummery, (ProgressSummery obj) => obj.shiftName);
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
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

  getCommens(List<String> list, Iterable<dynamic> keys) {
    List k = keys.toList();
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
                    subtitle: Text("${allShiftSummery.defectsRate ?? 0}%", style: valSt1, textScaleFactor: 1.3, textAlign: TextAlign.center)),
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
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    print(args.value);

                    rangeEndDate = null;
                    selectedDate = null;
                    if (args.value is PickerDateRange) {
                      rangeStartDate = args.value.startDate;
                      rangeEndDate = args.value.endDate;
                    } else if (args.value is DateTime) {
                      selectedDate = args.value;
                    } else if (args.value is List<DateTime>) {
                    } else {}
                    setState(() {});
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
      ]
    ];
  }
}
