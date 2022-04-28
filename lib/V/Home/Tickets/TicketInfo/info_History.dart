import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/TicketHistory.dart';
import 'package:smartwind/M/hive.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../M/NsUser.dart';
import '../../../Widgets/UserImage.dart';

class InfoHistory extends StatefulWidget {
  final List<TicketHistory> ticketHistoryList;

  const InfoHistory(this.ticketHistoryList);

  @override
  _InfoHistoryState createState() => _InfoHistoryState();
}

class _InfoHistoryState extends State<InfoHistory> {
  List<TicketHistory> ticketHistoryList = [];
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) => _controller.jumpTo(_controller.position.maxScrollExtent));

    super.initState();
  }

  Map<String, String> titles = {"red": "Red Flag", "rush": "Rush", "gr": "Graphics"};

  TextStyle defaultStyle = const TextStyle(color: Colors.black);
  TextStyle linkStyle = const TextStyle(color: Colors.blue);
  TextStyle timeStyle = const TextStyle(color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    ticketHistoryList = widget.ticketHistoryList;

    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsets.all(8),
      itemCount: ticketHistoryList.length,
      itemBuilder: (BuildContext context, int index) {
        TicketHistory ticketHistory = ticketHistoryList[index];
        NsUser? user = HiveBox.usersBox.get(ticketHistory.doneBy);

        return TimelineTile(
            isLast: ticketHistoryList.length == index + 1,
            beforeLineStyle: LineStyle(color: Colors.lightBlue.shade100),
            lineXY: 0.2,
            alignment: TimelineAlign.start,
            endChild: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text("1 MIN AGO", textAlign: TextAlign.start, style: TextStyle(color: Colors.grey)),
                  RichText(
                      text: TextSpan(style: defaultStyle, children: [
                    TextSpan(text: user?.name ?? "", style: linkStyle),
                    TextSpan(text: " ${(ticketHistory.action ?? "").toLowerCase().replaceUnderscore.capitalizeFirstofEach}")
                  ])),
                  Align(child: Text("${ticketHistory.uptime}", textAlign: TextAlign.end, style: timeStyle), alignment: Alignment.bottomRight),
                  const Divider(thickness: 1.5)
                ],
              ),
            ),
            indicatorStyle:
                IndicatorStyle(indicatorXY: 0.0, width: 40, height: 40, drawGap: true, padding: const EdgeInsets.all(8), indicator: UserImage(nsUser: user, radius: 24)));

        // return ListTile(
        //   title: Container(
        //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[100]),
        //     child: ListTile(
        //         title: Row(
        //           children: [
        //             Expanded(flex: 3, child: Text((ticketHistory.action ?? "").toLowerCase().replaceUnderscore.capitalizeFirstofEach)),
        //             Expanded(flex: 3, child: Text(ticketHistory.uptime ?? "", style: TextStyle())),
        //           ],
        //         ),
        //         // trailing: UserImage(nsUserId: ticketHistory.doneBy, radius: 24),
        //         trailing: SizedBox(width: 30, child: UserButton(nsUserId: ticketHistory.doneBy, imageRadius: 16, hideName: true))),
        //   ),
        // );
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

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';

  String get allInCaps => this.toUpperCase();

  String get replaceUnderscore => this.replaceAll(RegExp('_'), ' ');

  String get capitalizeFirstofEach => this.split(" ").map((str) => str.inCaps).join(" ");
}
