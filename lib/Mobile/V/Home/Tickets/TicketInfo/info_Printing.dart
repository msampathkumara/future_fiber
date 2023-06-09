import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../../C/DB/hive.dart';
import '../../../../../M/NsUser.dart';
import '../../../../../M/TicketPrint.dart';
import '../../../Widgets/UserImage.dart';

class info_Printing extends StatefulWidget {
  final List<TicketPrint> printList;

  const info_Printing(this.printList, {super.key});

  @override
  _info_PrintingState createState() => _info_PrintingState();
}

class _info_PrintingState extends State<info_Printing> {
  List<TicketPrint> printList = [];

  @override
  void initState() {
    super.initState();
  }

  Map<String, String> titles = {"red": "Red Flag", "rush": "Rush", "gr": "Graphics"};

  @override
  Widget build(BuildContext context) {
    printList = widget.printList;

    TextStyle defaultStyle = const TextStyle(color: Colors.black);
    TextStyle linkStyle = const TextStyle(color: Colors.blue);
    TextStyle timeStyle = const TextStyle(color: Colors.grey);

    return printList.isEmpty
        ? const Center(child: Text("No Print Details"))
        : ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: printList.length,
            itemBuilder: (BuildContext context, int index) {
              TicketPrint ticketPrint = printList[index];
              NsUser? user = HiveBox.usersBox.get(ticketPrint.doneBy);

              var action = ticketPrint.action == 'sent' ? " send to print" : " cancel printing";

              return TimelineTile(
                  isLast: printList.length == index + 1,
                  beforeLineStyle: LineStyle(color: Colors.lightBlue.shade100),
                  lineXY: 0.2,
                  alignment: TimelineAlign.start,
                  endChild: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(getAgoTime(ticketPrint.doneOn), textAlign: TextAlign.start, style: TextStyle(color: Colors.grey)),
                        RichText(text: TextSpan(style: defaultStyle, children: [TextSpan(text: user?.name ?? "", style: linkStyle), TextSpan(text: " $action")])),
                        Align(alignment: Alignment.bottomRight, child: Text(ticketPrint.doneOn, textAlign: TextAlign.end, style: timeStyle)),
                        const Divider(thickness: 1.5)
                      ],
                    ),
                  ),
                  indicatorStyle:
                      IndicatorStyle(indicatorXY: 0.1, width: 40, height: 40, drawGap: true, padding: const EdgeInsets.all(8), indicator: UserImage(nsUser: user, radius: 24)));
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Padding(
                padding: EdgeInsets.all(4.0),
                child: Divider(
                  height: 1,
                  endIndent: 0.5,
                  color: Colors.white38,
                ),
              );
            },
          );
  }
}
