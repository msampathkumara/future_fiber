import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/Web/V/DashBoard/M/ProgressSummery.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'CountCards.dart';

class LineChartController {
  _LineChartState? lineChartState;
  List<ProgressSummery> chartData = [];
  late DateTime rangeStartDate;
  DateTime? rangeEndDate;

  DaysFilters filter = DaysFilters.Month;

  void setParent(_LineChartState lineChartState) {
    this.lineChartState = lineChartState;
  }

  void updateData(DateTime _rangeStartDate, DateTime? _rangeEndDate, Production selectedProduction, DaysFilters filter, List<ProgressSummery> _chartData) {
    print('__UPDATE DATA');
    this.filter = filter;
    rangeStartDate = _rangeStartDate;
    rangeEndDate = _rangeEndDate;

    // Api.get(EndPoints.dashboard_getGraphData, {"startDate": rangeStartDate, "endDate": rangeEndDate, 'production': selectedProduction.getValue()}).then((res) {
    //   Map data = res.data;

    // chartData = ProgressSummery.fromJsonArray(data["shiftsData"]);
    chartData = _chartData;

    Map<String, ProgressSummery> dataMap = {};
    getDaysInBetween(_rangeStartDate, _rangeEndDate ?? _rangeStartDate).forEach((element) {
      var p = ProgressSummery();
      p.date = element;
      p.startAt = element.toString();
      p.shiftName = 'morning';
      dataMap["$element morning"] = p;
      var p1 = ProgressSummery();
      p1.date = element;
      p1.startAt = element.toString();
      p1.shiftName = 'evening';
      dataMap["$element evening"] = p1;
    });
    for (var element in chartData) {
      dataMap["${element.date} ${element.shiftName?.toLowerCase()}"] = element;
    }

    chartData = dataMap.values.toList();
    // }).whenComplete(() {
    //   lineChartState?.refresh();
    // }).catchError((err) {
    //   print(err);

    lineChartState?.refresh();
    // });
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays - 1; i++) {
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

  var sc = ScrollController();

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
    // _values = SfRangeValues(controller.rangeStartDate, controller.rangeStartDate?.add(const Duration(days: 1)));
    _values = SfRangeValues(0, controller.chartData.length - 1);
    super.initState();
  }

  late SfRangeValues _values;

  @override
  Widget build(BuildContext context) {
    List<FastLineSeries> series = [];

    series = names
        .map((e) => FastLineSeries(
            name: e.caption,
            isVisible: e.selected,
            enableTooltip: true,
            color: e.color,
            dataSource: controller.chartData,
            xValueMapper: (ProgressSummery s, _) => "${getDate(s)} ${s.shiftName?.toLowerCase() == "morning" ? "🌞" : "🌑"}",
            // xValueMapper: (ProgressSummery s, _) => stringToDateTime(s.startAt),
            yValueMapper: (ProgressSummery s, _) => e.getValue(s) ?? 0,
            markerSettings: const MarkerSettings(isVisible: true, shape: DataMarkerType.circle)))
        .toList();

    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
            child: SfCartesianChart(
                enableAxisAnimation: true,
                // zoomPanBehavior: _zoomPanBehavior,
                tooltipBehavior: _tooltipBehavior,
                zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: false,
                ),
                primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Shift'), maximum: _values.start, minimum: _values.end, isVisible: true),
                // primaryXAxis: DateTimeAxis(title: AxisTitle(text: 'Shift'),   visibleMaximum: _values.start, visibleMinimum: _values.end ),
                // primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Shift') ),
                series: series,
                legend: Legend(isVisible: true, position: LegendPosition.left)),
          ),
        ),
        SfRangeSlider(
          // min: controller.rangeStartDate,
          // max: controller.rangeEndDate,
          min: 0,
          max: controller.chartData.length - 1,
          dateFormat: DateFormat.MMMMd(),
          dateIntervalType: DateIntervalType.days,
          values: _values,
          dragMode: SliderDragMode.both,
          interval: 1,
          showTicks: false,
          showLabels: false,
          enableTooltip: false,
          minorTicksPerInterval: 1,
          onChanged: (SfRangeValues values) {
            setState(() {
              _values = values;
            });
          },
        )
      ],
    ));
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  getDate(ProgressSummery s) {
    switch (controller.filter) {
      case DaysFilters.Today:
        break;
      case DaysFilters.Yesterday:
        break;
      case DaysFilters.Week:
        return DateFormat("MM/dd").format((s.date) ?? DateTime.now());
      case DaysFilters.Month:
        return DateFormat("dd").format((s.date) ?? DateTime.now());
      case DaysFilters.Year:
        return DateFormat("MM/dd").format(s.date ?? DateTime.now());
      case DaysFilters.Custom:
        return DateFormat("MM/dd").format(s.date ?? DateTime.now());
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
