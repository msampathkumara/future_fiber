import 'dart:math';

import 'package:deebugee_plugin/IfWeb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:deebugee_plugin/DialogView.dart';

import '../../../../../C/Api.dart';
import '../../../../../M/EndPoints.dart';

class TimeCardView extends StatefulWidget {
  final int qcId;

  const TimeCardView(this.qcId, {Key? key}) : super(key: key);

  @override
  State<TimeCardView> createState() => _TimeCardViewState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _TimeCardViewState extends State<TimeCardView> {
  var loading = true;
  List times = [];

  @override
  void initState() {
    loadTimeCardData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  Scaffold getWebUi() {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Card')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (context, index) {
                var t = times[index];
                return ListTile(
                  title: Text('${t['subOperation']}'),
                  trailing: Text('${t['time']} min', style: const TextStyle(color: Colors.red)),
                  subtitle: Text("${t['peopleCount']} People"),
                );
              },
              itemCount: times.length),
    );
  }

  Scaffold getUi() {
    return getWebUi();
  }

  void loadTimeCardData() {
    Api.get(EndPoints.tickets_qc_getTimeCard, {"qcId": widget.qcId}).then((res) {
      Map data = res.data;
      times = data["subOperations"].map((m) => m as Map<String, dynamic>).toList();
      print(data);
      print(times);
      loading = false;
      setState(() {});
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {loadTimeCardData()})));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
