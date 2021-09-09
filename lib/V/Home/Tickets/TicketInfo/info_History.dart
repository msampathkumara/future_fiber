import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/ServerResponce/TicketHistory.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

class info_History extends StatefulWidget {
  List<TicketHistory> ticketHistoryList;

  info_History(this.ticketHistoryList);

  @override
  _info_HistoryState createState() => _info_HistoryState();
}

class _info_HistoryState extends State<info_History> {
  List<TicketHistory> ticketHistoryList = [];

  @override
  void initState() {}

  Map<String, String> titles = {"red": "Red Flag", "rush": "Rush", "gr": "GR"};

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
                    Expanded(flex: 3, child: Text((ticketHistory.action ?? "").toLowerCase().replaceUnderscore.capitalizeFirstofEach )),
                    Expanded(flex: 3, child: Text(ticketHistory.uptime ?? "", style: TextStyle())),
                  ],
                ),
                trailing: UserImage(nsUserId: ticketHistory.doneBy, radius: 24),
              ),
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