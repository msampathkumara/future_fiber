import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

import '../../../M/hive.dart';
import '../../../V/Home/Tickets/TicketInfo/TicketInfo.dart';

class WipTicketList extends StatefulWidget {
  final int? sectionId;

  const WipTicketList(this.sectionId, {Key? key}) : super(key: key);

  @override
  State<WipTicketList> createState() => _WipTicketListState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _WipTicketListState extends State<WipTicketList> {
  List<Ticket> tickets = [];

  @override
  void initState() {
    tickets = HiveBox.ticketBox.values.where((ticket) {
      return ticket.nowAt == widget.sectionId && ticket.isStarted;
    }).toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 300, height: 500, child: getWebUi()));
  }

  getWebUi() {
    return Scaffold(
      appBar: AppBar(title: const Text('WIP list ')),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (BuildContext context, int index) {
          var ticket = tickets[index];
          return ListTile(onTap: () => TicketInfo(ticket).show(context), leading: Text('${index + 1}'), title: Text(ticket.mo ?? ''));
        },
      ),
    );
  }

  getUi() {
    return getWebUi();
  }
}
