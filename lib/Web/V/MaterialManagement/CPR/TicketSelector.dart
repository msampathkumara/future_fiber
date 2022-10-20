import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/Mobile/V/Widgets/SearchBar.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

import '../../../../M/Ticket.dart';

class TicketSelector extends StatefulWidget {
  const TicketSelector({Key? key}) : super(key: key);

  @override
  State<TicketSelector> createState() => _TicketSelectorState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _TicketSelectorState extends State<TicketSelector> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // ticketList = HiveBox.ticketBox.values.toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 500, child: getWebUi()));
  }

  List<Ticket> ticketList = [];

  getWebUi() {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: SearchBar(
                  delay: 300,
                  onSearchTextChanged: (text) {
                    setState(() {
                      if (text.trim().isEmpty) {
                        ticketList = [];
                      } else {
                        ticketList = HiveBox.ticketBox.values.where((element) => (text.containsInArrayIgnoreCase([(element.mo ?? ""), (element.oe ?? "")]))).toList();
                      }
                    });
                  },
                  searchController: searchController),
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  var ticket = ticketList[index];
                  return ListTile(
                      onTap: () {
                        Navigator.pop(context, ticket);
                      },
                      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                      title: Text((ticket.mo ?? ticket.oe) ?? ""),
                      subtitle: Text((ticket.oe) ?? "", style: const TextStyle(color: Colors.red, fontSize: 12)),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        direction: Axis.vertical,
                        children: [Text((ticket.production) ?? ""), Text((ticket.atSection), style: const TextStyle(color: Colors.red, fontSize: 12))],
                      ));
                },
                itemCount: ticketList.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(height: 0);
                },
              ),
            )
          ],
        ));
  }

  getUi() {}
}
