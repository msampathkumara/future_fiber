import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/ServerResponce/TicketPrint.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

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

  Map<String, String> titles = {"red": "Red Flag", "rush": "Rush", "gr": "GR"};

  @override
  Widget build(BuildContext context) {
    printList = widget.printList;

    return Container(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: printList.length,
        itemBuilder: (BuildContext context, int index) {
          TicketPrint ticketPrint = printList[index];

          return ListTile(
            title: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[100]),
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(flex: 3, child: Text(ticketPrint.action ?? "")),
                    Expanded(flex: 3, child: Text(ticketPrint.doneOn ?? "", style: TextStyle())),
                  ],
                ),
                trailing: UserImage(nsUserId: ticketPrint.doneBy, radius: 24),
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
