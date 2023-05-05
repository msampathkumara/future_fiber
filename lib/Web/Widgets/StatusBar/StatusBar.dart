import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind_future_fibers/Web/Widgets/StatusBar/StatusBarProgressIndicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'StatusBarItem.dart';

class StatusBar extends StatefulWidget {
  static final StatusBarController statusBarController = StatusBarController();

  const StatusBar({Key? key}) : super(key: key);

  @override
  State<StatusBar> createState() => _StatusBarState();

  setProgress(String p) {}

  static StatusBarController getController() {
    return statusBarController;
  }
}

class _StatusBarState extends State<StatusBar> with TickerProviderStateMixin {
  late StatusBarController statusBarController;

  @override
  void initState() {
    super.initState();

    /// Instantiate the PageController in initState.
    statusBarController = StatusBarController();
    statusBarController.onAdd(() {
      print('ADD');
      setState(() {});
    });
    statusBarController.onRemove(() {
      print('REMOVE');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: StatusBarController.statusBarItemList.isNotEmpty ? 20 : 0,
      color: Colors.transparent,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.end, children: StatusBarController.statusBarItemList),
    );
  }

  setProgress(String p) {}
}

class StatusBarController {
  static List<Widget> statusBarItemList = [];
  static final List<Function> _statusBarItemOnAdd = [];
  static final List<Function> _statusBarItemOnRemove = [];

  void addWidget(Widget _statusBarItem) {
    statusBarItemList.add(_statusBarItem);
    for (var element in _statusBarItemOnAdd) {
      try {
        print('element call${element.hashCode}');
        element();
        print('element call');
      } catch (e) {
        print('xxxxxxxxxxxxxaaa');
        _statusBarItemOnAdd.remove(element);
      }
    }
  }

  void removeWidget(Widget _statusBarItem) {
    print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr${statusBarItemList.length}');
    statusBarItemList.remove(_statusBarItem);
    print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr${statusBarItemList.length}');

    for (var element in _statusBarItemOnRemove) {
      try {
        print('element call${element.hashCode}');
        element();
      } catch (e) {
        print('xxxxxxxxxxxxxrrr');
        _statusBarItemOnRemove.remove(element);
      }
    }
  }

  void onAdd(Null Function() param0) {
    _statusBarItemOnAdd.add(param0);
  }

  void onRemove(Null Function() param0) {
    _statusBarItemOnRemove.add(param0);
  }
}
