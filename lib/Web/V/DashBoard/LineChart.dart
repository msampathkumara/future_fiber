import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/Web/V/DashBoard/M/ProgressSummery.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../C/Api.dart';
import '../../../M/EndPoints.dart';
import 'CountCards.dart';

class LineChartController {
  _LineChartState? lineChartState;
  List<ProgressSummery> chartData = [];

  DaysFilters filter = DaysFilters.Month;

  void setParent(_LineChartState lineChartState) {
    this.lineChartState = lineChartState;
  }

  void updateData(DateTime rangeStartDate, DateTime? rangeEndDate, Production selectedProduction, DaysFilters filter) {
    print('__UPDATE DATA');
    this.filter = filter;

    Api.get(EndPoints.dashboard_getGraphData, {"startDate": rangeStartDate, "endDate": rangeEndDate, 'production': selectedProduction.getValue()}).then((res) {
      Map data = res.data;

      chartData = ProgressSummery.fromJsonArray(data["shiftsData"]);

      Map<String, ProgressSummery> dataMap = {};
      getDaysInBetween(rangeStartDate, rangeEndDate ?? rangeStartDate).forEach((element) {
        var p = ProgressSummery();
        p.date = element;
        p.shiftName = 'morning';
        dataMap["$element morning"] = p;
        var p1 = ProgressSummery();
        p1.date = element;
        p1.shiftName = 'evening';
        dataMap["$element evening"] = p1;
      });
      for (var element in chartData) {
        dataMap["${element.date} ${element.shiftName?.toLowerCase()}"] = element;
      }

      chartData = dataMap.values.toList();
    }).whenComplete(() {
      lineChartState?.refresh();
    }).catchError((err) {
      print(err);

      lineChartState?.refresh();
    });
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }
}

class LineChart extends StatefulWidget {
  final LineChartController controller;

  const LineChart({Key? key, required this.controller}) : super(key: key);

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  late LineChartController controller;
  late TooltipBehavior _tooltipBehavior;

  List<SeriesInfo> names = [
    SeriesInfo("Volume", Colors.red, (ProgressSummery s) => s.volume)..setSelected(true),
    SeriesInfo("Employee Count", Colors.lightBlue, (ProgressSummery s) => s.employeeCount),
    SeriesInfo("Production Capacity", Colors.grey, (ProgressSummery s) => s.capacity, setText: (s) => (s.capacity ?? 0).toStringAsFixed(1)),
    SeriesInfo("Takt Time", Colors.brown, (ProgressSummery s) => s.taktTime, setText: (ProgressSummery s) => ProgressSummery.durationToString(((s.taktTime ?? 0) * 60).round())),
    SeriesInfo("Cycle Time", Colors.deepPurple, (ProgressSummery s) => s.cycleTime, setText: (s) => ProgressSummery.durationToString(((s.cycleTime ?? 0) * 60).round())),
    SeriesInfo("Efficiency", Colors.green, (ProgressSummery s) => s.efficiency, setText: (x) => "${(x.efficiency ?? 0).toStringAsFixed(1)}%"),
    SeriesInfo("Defects", Colors.orange, (ProgressSummery s) => s.defects),
    SeriesInfo("Defects Rate", Colors.orange, (ProgressSummery s) => s.defectsRate, setText: (x) => "${(x.defectsRate ?? 0).toStringAsFixed(2)}%"),
    SeriesInfo("WIP", Colors.brown, (ProgressSummery s) => s.wip)
  ];

  @override
  void initState() {
    controller = widget.controller;
    widget.controller.setParent(this);
    _tooltipBehavior = TooltipBehavior(
        enable: true,
        duration: 1,
        builder: (data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
          ProgressSummery progressSummery = data;
          SeriesInfo seriesInfo = names[seriesIndex];
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 180,
                child: Table(
                  border: const TableBorder(horizontalInside: BorderSide(color: Colors.white, width: 0.1)),
                  columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1.5)},
                  children: [
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text('Date', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(DateFormat("yyyy/MM/dd").format(progressSummery.date ?? DateTime.now()), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(padding: EdgeInsets.all(4.0), child: Text('Shift', style: TextStyle(color: Colors.white, fontSize: 12))),
                      Padding(
                          padding: const EdgeInsets.all(4.0), child: Text('${progressSummery.shiftName}'.capitalize(), style: const TextStyle(color: Colors.white, fontSize: 12))),
                    ]),
                    TableRow(children: [
                      Padding(padding: const EdgeInsets.all(4.0), child: Text(seriesInfo.caption, style: const TextStyle(color: Colors.white, fontSize: 12))),
                      Padding(padding: const EdgeInsets.all(4.0), child: Text('${seriesInfo.getText(progressSummery)}', style: const TextStyle(color: Colors.white, fontSize: 12)))
                    ])
                  ],
                ),
              ));
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<FastLineSeries> series = [];

    series = names
        .map((e) => FastLineSeries<ProgressSummery, String>(
            name: e.caption,
            isVisible: e.selected,
            enableTooltip: true,
            color: e.color,
            dataSource: controller.chartData,
            xValueMapper: (ProgressSummery s, _) => "${getDate(s)} ${s.shiftName?.toLowerCase() == "morning" ? "🌞" : "🌑"}",
            yValueMapper: (ProgressSummery s, _) => e.getValue(s) ?? 0))
        .toList();

    return Scaffold(
        body: Column(
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(left: 24.0),
        //   child: Row(
        //       children: names
        //           .map((e) => Padding(
        //                 padding: const EdgeInsets.all(4.0),
        //                 child: FilterChip(
        //                   showCheckmark: false,
        //                   elevation: 1,
        //                   avatar: Icon(Icons.fiber_manual_record_rounded, color: e.color),
        //                   label: Text(e.caption ?? '', style: TextStyle(color: e.selected ? Colors.white : Colors.black)),
        //                   backgroundColor: Colors.white,
        //                   selected: e.selected,
        //                   selectedColor: getPrimaryColor(context),
        //                   onSelected: (bool value) {
        //                     e.selected = value;
        //                     setState(() {});
        //                   },
        //                 ),
        //               ))
        //           .toList()),
        // ),
        Expanded(
          child: Center(
              child: SizedBox(
                  width: double.infinity,
                  height: 500,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                    child: SfCartesianChart(
                        tooltipBehavior: _tooltipBehavior, primaryXAxis: CategoryAxis(), series: series, legend: Legend(isVisible: true, position: LegendPosition.left)),
                  ))),
        ),
      ],
    ));
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  getDate(s) {
    switch (controller.filter) {
      case DaysFilters.Today:
        break;
      case DaysFilters.Yesterday:
        break;
      case DaysFilters.Week:
        return DateFormat("MM/dd").format(s.date ?? DateTime.now());
        break;
      case DaysFilters.Month:
        return DateFormat("dd").format(s.date ?? DateTime.now());
        break;
      case DaysFilters.Year:
        return DateFormat("MM/dd").format(s.date ?? DateTime.now());
        break;
      case DaysFilters.Custom:
        return DateFormat("MM/dd").format(s.date ?? DateTime.now());
        break;
    }
  }
}

class SeriesInfo {
  late String caption;
  late MaterialColor color;
  bool selected = false;

  Function(ProgressSummery) getValue;
  Function(ProgressSummery)? setText;

  SeriesInfo(this.caption, this.color, this.getValue, {this.setText});

  setSelected(bool bool) {
    selected = bool;
  }

  getText(ProgressSummery progressSummery) {
    return setText != null ? setText!(progressSummery) : getValue(progressSummery);
  }
}
