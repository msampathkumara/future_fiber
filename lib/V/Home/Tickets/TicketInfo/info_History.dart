import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/ServerResponce/TicketHistory.dart';
import 'package:smartwind/M/TicketFlag.dart';

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
                    Expanded(flex: 3, child: Text(ticketHistory.action ?? "")),
                    Expanded(flex: 3, child: Text(ticketHistory.uptime ?? "", style: TextStyle())),
                  ],
                ),
                trailing: CircleAvatar(
                    radius: 24.0,
                    backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"),
                    backgroundColor: Colors.transparent),
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

  getHistory(List<TicketFlag> ticketFlags) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          itemCount: ticketFlags.length,
          itemBuilder: (BuildContext context, int index) {
            TicketFlag ticketFlag = ticketFlags[index];
            return Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(flex: 3, child: Text(ticketFlag.flaged == 1 ? "Flag added" : "Flag Removed")),
                    Expanded(flex: 3, child: Text(ticketFlag.dnt, style: TextStyle())),
                  ],
                ),
                trailing: CircleAvatar(
                    radius: 24.0,
                    backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"),
                    backgroundColor: Colors.transparent),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              height: 1,
              endIndent: 0.5,
              color: Colors.grey,
            );
          },
        ),
      ),
    );
  }
}
