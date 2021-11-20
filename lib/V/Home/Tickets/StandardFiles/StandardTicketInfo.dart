import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/StandardTicket.dart';

class StandardTicketInfo extends StatefulWidget {
  StandardTicket standardTicket;

  StandardTicketInfo(this.standardTicket);

  void show(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => this),
    );
  }

  @override
  _StandardTicketInfoState createState() => _StandardTicketInfoState();
}

class _StandardTicketInfoState extends State<StandardTicketInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.import_contacts),
        onPressed: () {
          widget.standardTicket.open(context);
        },
      ),
    );
  }
}
