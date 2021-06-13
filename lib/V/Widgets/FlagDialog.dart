import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';

class FlagDialog extends StatefulWidget {
  Ticket ticket;

  FlagDialog(this.ticket, {Key? key}) : super(key: key);

  @override
  _FlagDialogState createState() {
    return _FlagDialogState();
  }

  static showRedFlagDialog(BuildContext context, Ticket ticket) async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FlagDialog(ticket)),
    );
  }
}

class _FlagDialogState extends State<FlagDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
