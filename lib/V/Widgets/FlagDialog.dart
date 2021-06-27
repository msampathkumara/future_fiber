import 'package:flutter/material.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/TicketFlag.dart';

class FlagDialog {
  static int FLAG_TYPE_RED = 1;

  static showRedFlagDialog(BuildContext context, Ticket ticket) async {
    TextEditingController redCommentController = TextEditingController();
    showLoadingDialog(context);
    bool dataLoaded = false;
    ticket.getFlagList(TicketFlag.FlagType_RED).then((list) {
      dataLoaded = true;
      Navigator.of(context).pop();
      TicketFlag lastFlag;
      bool isRed;
      if (list.isEmpty) {
        isRed = false;
      } else {
        lastFlag = list[0];
        isRed = lastFlag.isFlaged;
      }
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: ListTile(title: Text(isRed ? 'Remove Red Flag' : "Add Red Flag"), leading: Icon(Icons.flag)),
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
                                  Align(alignment: Alignment.bottomRight, child: Text(tf.dnt))
                                ],
                              ),
                              leading: CircleAvatar(radius: 24.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
                            ),
                          );
                        }),
                  ),
                  if (!isRed)
                    Container(
                      width: 500,
                      child: TextFormField(
                        controller: redCommentController,
                        decoration: InputDecoration(hintText: 'Red Flag Comment'),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    ),
                  if (isRed)
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
                  Navigator.of(context).pop();
                },
              ),
              (!isRed && dataLoaded)
                  ? ElevatedButton(
                      child: const Text('Add Red Flag'),
                      onPressed: () {
                        setFlag(TicketFlag.FlagType_RED, redCommentController.value.text, ticket).then((value) {
                          print(value.body.toString());
                          Navigator.of(context).pop(true);
                        });
                      })
                  : ElevatedButton(
                      child: const Text('Remove Red Flag'),
                      onPressed: () {
                        removeFlag(TicketFlag.FlagType_RED, ticket).then((value) {
                          print(value.body.toString());
                          Navigator.of(context).pop(false);
                        });
                      }),
            ],
          );
        },
      );
    });
  }

  static void showLoadingDialog(context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Loading Red Flag Details'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
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

  static showGRDialog(BuildContext context1, Ticket ticket) {}

  static showSKDialog(BuildContext context1, Ticket ticket) {}

  static showRushDialog(BuildContext context1, Ticket ticket) {}
}
