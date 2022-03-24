import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../M/NsUser.dart';
import '../../../../M/TicketPrint.dart';
import '../../../../M/hive.dart';

class info_Printing extends StatefulWidget {
  List<TicketPrint> printList;

  info_Printing(this.printList);

  @override
  _info_PrintingState createState() => _info_PrintingState();
}

class _info_PrintingState extends State<info_Printing> {
  List<TicketPrint> printList = [];

  @override
  void initState() {}

  Map<String, String> titles = {"red": "Red Flag", "rush": "Rush", "gr": "Graphics"};

  @override
  Widget build(BuildContext context) {
    printList = widget.printList;

    TextStyle defaultStyle = TextStyle(color: Colors.black);
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    TextStyle timeStyle = TextStyle(color: Colors.grey);

    return printList.length <= 0
        ? Center(child: Text("No Print Details"))
        : Container(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: printList.length,
              itemBuilder: (BuildContext context, int index) {
                TicketPrint ticketPrint = printList[index];
                NsUser? user = HiveBox.usersBox.get(ticketPrint.doneBy);

                var action = ticketPrint.action == 'sent' ? " send to print" : " cancel printing";

                return TimelineTile(
                    beforeLineStyle: LineStyle(color: Colors.lightBlue.shade100),
                    lineXY: 0.2,
                    alignment: TimelineAlign.start,
                    endChild: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(getAgoTime(ticketPrint.doneOn), textAlign: TextAlign.start, style: TextStyle(color: Colors.grey)),
                          RichText(text: TextSpan(style: defaultStyle, children: [TextSpan(text: user?.name ?? "", style: linkStyle), TextSpan(text: " ${action}")])),
                          Align(child: Text("${ticketPrint.doneOn}", textAlign: TextAlign.end, style: timeStyle), alignment: Alignment.bottomRight),
                          Divider(thickness: 1.5)
                        ],
                      ),
                    ),
                    indicatorStyle:
                        IndicatorStyle(indicatorXY: 0.1, width: 40, height: 40, drawGap: true, padding: const EdgeInsets.all(8), indicator: UserImage(nsUser: user, radius: 24)));

                // return ListTile(
                //   title: Container(
                //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[100]),
                //     child: ListTile(
                //       title: Row(
                //         children: [
                //           Expanded(flex: 3, child: Text(ticketPrint.action ?? "")),
                //           Expanded(flex: 3, child: Text("${ticketPrint.doneOn}", style: TextStyle())),
                //         ],
                //       ),
                //       trailing: UserImage(nsUserId: ticketPrint.doneBy, radius: 24),
                //     ),
                //   ),
                // );
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

// String getAgoTime(String doneOn) {
//   final date = DateTime.parse(doneOn);
//
//   final date2 = DateTime.now();
//   final differenceInMin = date2.difference(date).inMinutes;
//
//   if(differenceInMin>0){
//
//   }
//
//
//   final difference = date2.difference(date).inDays;
//   return difference.toString();
// }
}
