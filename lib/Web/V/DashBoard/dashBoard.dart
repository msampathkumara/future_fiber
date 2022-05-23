import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Wrap(
          direction: Axis.horizontal,
          children: [
            Expanded(child: SfCartesianChart()),
            SfCircularChart(title: ChartTitle(text: 'Sales by sales person'), legend: Legend(isVisible: true), series: <PieSeries<_PieData, String>>[
              PieSeries<_PieData, String>(
                  explode: true,
                  explodeIndex: 0,
                  dataSource: [
                    _PieData('1', 1, 'ddd'),
                    _PieData('1', 2, 'ddd'),
                    _PieData('1', 3, 'ddd'),
                    _PieData('1', 4, 'ddd'),
                    _PieData('1', 5, 'ddd'),
                    _PieData('1', 6, 'ddd'),
                  ],
                  xValueMapper: (_PieData data, _) => data.xData,
                  yValueMapper: (_PieData data, _) => data.yData,
                  dataLabelMapper: (_PieData data, _) => data.text,
                  dataLabelSettings: const DataLabelSettings(isVisible: true)),
            ]),
            SfSparkLineChart(
                trackball: const SparkChartTrackball(activationMode: SparkChartActivationMode.tap),
                marker: const SparkChartMarker(displayMode: SparkChartMarkerDisplayMode.all),
                labelDisplayMode: SparkChartLabelDisplayMode.all,
                data: const <double>[1, 5, -6, 0, 1, -2, 7, -7, -4, -10, 13, -6, 7, 5, 11, 5, 3])
          ].map((e) => Card(child: e)).toList(),
        ),
      ),
    );
  }
}

class _PieData {
  _PieData(this.xData, this.yData, this.text);

  final String xData;
  final num yData;
  final String text;
}
