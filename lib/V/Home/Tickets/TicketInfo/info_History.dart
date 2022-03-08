import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/TicketHistory.dart';
import 'package:smartwind/V/Widgets/UserButton.dart';

class InfoHistory extends StatefulWidget {
  List<TicketHistory> ticketHistoryList;

  InfoHistory(this.ticketHistoryList);

  @override
  _InfoHistoryState createState() => _InfoHistoryState();
}

class _InfoHistoryState extends State<InfoHistory> {
  List<TicketHistory> ticketHistoryList = [];

  @override
  void initState() {}

  Map<String, String> titles = {"red": "Red Flag", "rush": "Rush", "gr": "Graphics"};

  @override
  Widget build(BuildContext context) {
    ticketHistoryList = widget.ticketHistoryList;

    return Container(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: ticketHistoryList.length,
        itemBuilder: (BuildContext context, int index) {
          TicketHistory ticketHistory = ticketHistoryList[index];

          return ListTile(
            title: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[100]),
              child: ListTile(
                  title: Row(
                    children: [
                      Expanded(flex: 3, child: Text((ticketHistory.action ?? "").toLowerCase().replaceUnderscore.capitalizeFirstofEach)),
                      Expanded(flex: 3, child: Text(ticketHistory.uptime ?? "", style: TextStyle())),
                    ],
                  ),
                  // trailing: UserImage(nsUserId: ticketHistory.doneBy, radius: 24),
                  trailing: SizedBox(width: 30, child: UserButton(nsUserId: ticketHistory.doneBy, imageRadius: 16, hideName: true))),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Divider(
              height: 1,
              endIndent: 0.5,
              color: Colors.white38,
            ),
          );
        },
      ),
    );
  }
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';

  String get allInCaps => this.toUpperCase();

  String get replaceUnderscore => this.replaceAll(RegExp('_'), ' ');

  String get capitalizeFirstofEach => this.split(" ").map((str) => str.inCaps).join(" ");
}
