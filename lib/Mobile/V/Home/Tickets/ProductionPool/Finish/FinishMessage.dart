import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';

class FinishMessage extends StatefulWidget {
  final Ticket ticket;

  const FinishMessage(this.ticket, {Key? key}) : super(key: key);

  @override
  State<FinishMessage> createState() => _FinishMessageState();

  Future show(context) {
    // await showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return FinishCheckList(widget.ticket);
    //     });

    return showDialog(context: context, builder: (_) => this);
  }
}

class _FinishMessageState extends State<FinishMessage> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 300, child: Text("ddddd"));
  }
}
