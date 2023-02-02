import 'package:flutter/material.dart';

class StatusBar extends StatefulWidget {
  const StatusBar({Key? key}) : super(key: key);

  @override
  State<StatusBar> createState() => _StatusBarState();

  setProgress(String p) {}
}

class _StatusBarState extends State<StatusBar> {
  StatusBarController? statusBarController;

  @override
  void initState() {
    super.initState();

    /// Instantiate the PageController in initState.
    statusBarController = StatusBarController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      color: Colors.white,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.end, children: const [Text("ddddddddddddd")]),
    );
  }

  setProgress(String p) {}
}

class StatusBarController {}
