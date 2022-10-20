import 'package:flutter/material.dart';
import 'package:smartwind/Web/V/DashBoard/CountCards.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent, body: Padding(padding: EdgeInsets.all(8.0), child: CountCards()));
  }
}
