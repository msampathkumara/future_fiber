import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';

class AddCPR extends StatefulWidget {
  Ticket ticket;

  AddCPR(this.ticket);

  @override
  _AddCPRState createState() => _AddCPRState();
}

class _AddCPRState extends State<AddCPR> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.ticket.mo ?? widget.ticket.oe ?? "")), body: Container());
  }
}
