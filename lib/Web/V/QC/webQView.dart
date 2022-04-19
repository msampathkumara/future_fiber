import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';

import '../../Widgets/DialogView.dart';

class webQView extends StatefulWidget {
  final Ticket ticket;
  final bool isQc;

  const webQView(this.ticket, this.isQc, {Key? key}) : super(key: key);

  @override
  State<webQView> createState() => _webQViewState();

  void show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _webQViewState extends State<webQView> {
  @override
  Widget build(BuildContext context) {
    return kIsWeb ? DialogView(child: editUserUi()) : editUserUi();
  }

  editUserUi() {
    return Scaffold(appBar: AppBar(),body: Row(children: []));
  }
}
