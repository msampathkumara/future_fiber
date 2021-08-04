import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

class info_Flags extends StatefulWidget {
  List<TicketFlag> ticketFlag;
  List<TicketFlag> flagsHistory;

  info_Flags(this.ticketFlag, this.flagsHistory);

  @override
  _info_FlagsState createState() => _info_FlagsState();
}

class _info_FlagsState extends State<info_Flags> {
  List<TicketFlag> ticketFlags = [];
  List<TicketFlag> flagsHistory = [];

  @override
  void initState() {}

  Map<String, String> titles = {"red": "Red Flag", "rush": "Rush", "gr": "GR"};

  @override
  Widget build(BuildContext context) {
    ticketFlags = widget.ticketFlag;
    flagsHistory = widget.flagsHistory;

    return Container(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: ticketFlags.length,
        itemBuilder: (BuildContext context, int index) {
          TicketFlag ticketFlag = ticketFlags[index];
          var list = flagsHistory.where((i) => i.type == ticketFlag.type).toList();

          return Column(
            children: [
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      child: Text(
                    titles[ticketFlag.type] ?? "",
                    style: TextStyle(fontSize: 23),
                  )),
                ),
                subtitle: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[400]),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(flex: 3, child: Text(ticketFlag.flaged == 1 ? "Flag added" : "Flag Removed")),
                        Expanded(flex: 3, child: Text(ticketFlag.dnt, style: TextStyle())),
                      ],
                    ),
                    trailing: UserImage(nsUserId: ticketFlag.user, radius: 24),
                  ),
                ),
              ),
              Container(child: getHistory(list))
            ],
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
                  // trailing: CircleAvatar(radius: 24.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
                  trailing: UserImage(nsUserId: ticketFlag.user, radius: 24)),
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
