import 'package:flutter/material.dart';
import 'package:smartwind/Web/V/DashBoard/M/ProgressSummery.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../C/Api.dart';
import '../../../M/EndPoints.dart';

class LineChart extends StatefulWidget {
  const LineChart({Key? key}) : super(key: key);

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  List<ProgressSummery> chartData = [];

  @override
  void initState() {
    // TODO: implement initState
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final List<SalesData> chartData = [
    //   SalesData(DateTime(2010), 35),
    //   SalesData(DateTime(2011), 28),
    //   SalesData(DateTime(2012), 34),
    //   SalesData(DateTime(2013), 32),
    //   SalesData(DateTime(2015), 40),
    //   SalesData(DateTime(2016), 45),
    //   SalesData(DateTime(2017), 49),
    //   SalesData(DateTime(2018), 30),
    //   SalesData(DateTime(2019), 60),
    //   SalesData(DateTime(2020), 10),
    // ];
    // List<ProgressSummery> chartData = [];

    return Scaffold(
        body: Center(
            child: SizedBox(
      width: 1000,
      height: 300,
      child: SfCartesianChart(primaryXAxis: DateTimeAxis(), series: <ChartSeries>[
        // Renders line chart
        LineSeries<ProgressSummery, DateTime>(
            dataSource: chartData,
            xValueMapper: (ProgressSummery sales, _) => DateTime.parse(sales.startAt ?? '2022-9-9'),
            yValueMapper: (ProgressSummery sales, _) => sales.volume)
      ]),
    )));
  }

  void loadData() {
    Api.get(EndPoints.dashboard_getGraphData, {}).then((res) {
      Map data = res.data;

      chartData = ProgressSummery.fromJsonArray(data["shiftsData"]);
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

class SalesData {
  SalesData(this.year, this.sales);

  final DateTime year;
  final double sales;
}
