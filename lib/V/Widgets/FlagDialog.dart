import 'package:flutter/material.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

class FlagDialog {
  static int FLAG_TYPE_RED = 1;

  static showRedFlagDialog(BuildContext context, Ticket ticket) async {
    flagType = TicketFlagTypes.RED;
    addTitle = "Set Red Flag";
    removeTitle = "Remove Red Flag";
    icon = Icon(Icons.flag_rounded, color: Colors.red);
    _commentPlaceHolder = "Red Flag Comment";

    _showDialog(context, ticket);

    //
    // TextEditingController redCommentController = TextEditingController();
    // showLoadingDialog(context);
    // bool dataLoaded = false;
    // ticket.getFlagList(TicketFlag.flagTypeRED).then((list) {
    //   dataLoaded = true;
    //   Navigator.of(context).pop(false);
    //   TicketFlag lastFlag;
    //   bool isRed;
    //   if (list.isEmpty) {
    //     isRed = false;
    //   } else {
    //     lastFlag = list[0];
    //     isRed = lastFlag.isFlaged;
    //   }
    //   showDialog<void>(
    //     context: context,
    //     barrierDismissible: false, // user must tap button!
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //           title: ListTile(title: Text(isRed ? 'Remove Red Flag' : "Add Red Flag",textScaleFactor: 1.2), leading: Icon(Icons.flag)),
    //           content: Container(
    //             height: 500,
    //             width: 500,
    //             child: Column(
    //               children: [
    //                 Container(
    //                   height: 400,
    //                   child: ListView.builder(
    //                       itemCount: list.length,
    //                       itemBuilder: (context, i) {
    //                         TicketFlag tf = list[i];
    //                         return Card(
    //                           child: ListTile(
    //                             title: Text(tf.isFlaged ? "Flag Added" : "Flag Removed"),
    //                             subtitle: Column(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 Padding(padding: const EdgeInsets.all(8.0), child: Text(tf.comment, textScaleFactor: 1.2, style: TextStyle(color: Colors.black))),
    //                                 Align(alignment: Alignment.bottomRight, child: Text(tf.getDateTime()))
    //                               ],
    //                             ),
    //                             leading: CircleAvatar(
    //                                 radius: 24.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
    //                           ),
    //                         );
    //                       }),
    //                 ),
    //                 if (!isRed)
    //                   Container(
    //                     width: 500,
    //                     child: TextFormField(
    //                       controller: redCommentController,
    //                       decoration: InputDecoration(hintText: 'Red Flag Comment'),
    //                       keyboardType: TextInputType.multiline,
    //                       maxLines: null,
    //                     ),
    //                   ),
    //                 if (isRed)
    //                   Container(
    //                     child: Text(""),
    //                   ),
    //               ],
    //             ),
    //           ),
    //           actions: <Widget>[
    //             TextButton(
    //               child: const Text('Cancel'),
    //               onPressed: () {
    //                 Navigator.of(context).pop(false);
    //               },
    //             ),
    //             (!isRed && dataLoaded)
    //                 ? ElevatedButton(
    //                     child: const Text('Add Red Flag'),
    //                     onPressed: () {
    //                       setFlag(TicketFlag.flagTypeRED, redCommentController.value.text, ticket).then((value) {
    //                         print(value);
    //                         Navigator.of(context).pop(true);
    //                       });
    //                     })
    //                 : ElevatedButton(
    //                     child: const Text('Remove Red Flag'),
    //                     onPressed: () {
    //                       removeFlag(TicketFlag.flagTypeRED, ticket).then((value) {
    //                         print(value);
    //                         Navigator.of(context).pop(false);
    //                       });
    //                     })
    //           ]);
    //     },
    //   );
    // });
  }

  static showLoadingDialog(context, String text) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(children: [Text(text, textScaleFactor: 1.2)]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  static Future setFlag(String type, String comment, Ticket ticket) {
    return OnlineDB.apiPost("tickets/flags/setFlag", {"comment": comment, "type": type, "ticket": ticket.id.toString()});
  }

  static removeFlag(String type, Ticket ticket) {
    return OnlineDB.apiPost("tickets/flags/removeFlag", {"type": type, "ticket": ticket.id.toString()});
  }

  static late TicketFlagTypes flagType;
  static late String addTitle;
  static late String removeTitle;
  static late String _commentPlaceHolder;
  static late Widget icon;

  static showGRDialog(BuildContext context, Ticket ticket) {
    flagType = TicketFlagTypes.GR;
    addTitle = "Set GR";
    removeTitle = "Remove GR";
    icon = CircleAvatar(backgroundColor: Colors.blue, child: Center(child: Text("GR", style: TextStyle(color: Colors.white))));
    _commentPlaceHolder = "GR Comment";

    _showDialog(context, ticket);
  }

  // static showSKDialog(BuildContext context1, Ticket ticket) {}

  static showRushDialog(BuildContext context, Ticket ticket) {
    flagType = TicketFlagTypes.RUSH;
    addTitle = "Set Rush";
    removeTitle = "Remove Rush";
    icon = Icon(Icons.offline_bolt_rounded, color: Colors.orangeAccent);
    _commentPlaceHolder = "Rush Comment";

    _showDialog(context, ticket);
  }

  static _showDialog(context, ticket) {
    TextEditingController _commentController = TextEditingController();
    showLoadingDialog(context, "Loading Data");
    bool dataLoaded = false;
    ticket.getFlagList(flagType.getValue()).then((list) {
      dataLoaded = true;
      Navigator.of(context).pop(false);
      TicketFlag lastFlag;
      bool isFlaged;
      if (list.isEmpty) {
        isFlaged = false;
      } else {
        lastFlag = list[0];
        isFlaged = lastFlag.isFlaged;
      }
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              title: ListTile(title: Text(isFlaged ? addTitle : removeTitle, textScaleFactor: 1.2), leading: icon),
              content: Container(
                height: 500,
                width: 500,
                child: Column(
                  children: [
                    Container(
                      height: 400,
                      child: ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, i) {
                            TicketFlag tf = list[i];
                            return Card(
                              child: ListTile(
                                title: Text(tf.isFlaged ? "Flag Added" : "Flag Removed"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(padding: const EdgeInsets.all(8.0), child: Text(tf.comment, textScaleFactor: 1.2, style: TextStyle(color: Colors.black))),
                                    Align(alignment: Alignment.bottomRight, child: Text(tf.getDateTime()))
                                  ],
                                ),
                                leading: UserImage(nsUserId: tf.user),
                                // leading: CircleAvatar(
                                //     radius: 24.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
                              ),
                            );
                          }),
                    ),
                    if (!isFlaged)
                      Container(
                        width: 500,
                        child: TextFormField(
                          controller: _commentController,
                          decoration: InputDecoration(hintText: _commentPlaceHolder),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        ),
                      ),
                    if (isFlaged)
                      Container(
                        child: Text(""),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                (!isFlaged && dataLoaded)
                    ? ElevatedButton(
                        child: const Text('Add Flag'),
                        onPressed: () {
                          showLoadingDialog(context, "Updating Data");
                          setFlag(flagType.getValue(), _commentController.value.text, ticket).then((value) {
                            print(value);
                            Navigator.of(context).pop(true);
                            Navigator.of(context).pop(true);
                          });
                        })
                    : ElevatedButton(
                        child: const Text('Remove Flag'),
                        onPressed: () {
                          showLoadingDialog(context, "Updating Data");
                          removeFlag(flagType.getValue(), ticket).then((value) {
                            print(value);
                            Navigator.of(context).pop(false);
                            Navigator.of(context).pop(false);
                          });
                        })
              ]);
        },
      );
    });
  }

  static Future<void> showFlagView(BuildContext context, Ticket ticket, TicketFlagTypes flagType) async {
    var db = await DB.getDB();
    var data = await db!.rawQuery("select * from flags where ticket='${ticket.id}' and type='${flagType.getValue()}' ");
    print(data);

    TicketFlag tf = TicketFlag.fromJson(data[0]);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: Text(' '),
            content: ListTile(
              // title: Text(tf.isFlaged ? "Flag Added" : "Flag Removed"),
              title: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: Text(tf.comment, textScaleFactor: 1.2, style: TextStyle(color: Colors.black))),
                  Align(alignment: Alignment.bottomRight, child: Text(tf.getDateTime(), style: TextStyle(color: Colors.blue)))
                ],
              ),
              leading: UserImage(nsUserId: tf.user),
              // leading: CircleAvatar(
              //     radius: 24.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
            )));
  }
}
