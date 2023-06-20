import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';
import 'package:smartwind_future_fibers/M/TicketFlag.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:smartwind_future_fibers/ns_icons_icons.dart';

import '../../../C/Api.dart';
import '../../../M/EndPoints.dart';
import 'UserButton.dart';

class FlagDialog extends StatefulWidget {
  FlagDialog({Key? key}) : super(key: key);

  @override
  State<FlagDialog> createState() => _FlagDialogState();

  late Ticket ticket;
  late TicketFlagTypes ticketFlagTypes;

  void showFlagView(context, Ticket _ticket, TicketFlagTypes _ticketFlagTypes) {
    ticket = _ticket;
    ticketFlagTypes = _ticketFlagTypes;

    showDialog(context: context, builder: (_) => this);
  }
}

class _FlagDialogState extends State<FlagDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogView(child: _getUi(widget.ticketFlagTypes), width: 500, height: 500);
  }

  _getUi(flagType) {
    String titleText = "";
    switch (flagType) {
      case TicketFlagTypes.HOLD:
        titleText = "Hold";
        break;
      case TicketFlagTypes.RED:
        titleText = "Red Flag";
        break;
      case TicketFlagTypes.GR:
        titleText = "Graphics";
        break;

      case TicketFlagTypes.RUSH:
        titleText = "Rush";
        break;
      case TicketFlagTypes.SK:
        titleText = "SK";
        break;
    }

    TicketFlag? ticketFlag;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Wrap(children: [const Icon(NsIcons.sk, size: 24), const SizedBox(width: 16), Text(titleText)])),
      body: SizedBox(
        width: w,
        child: ListTile(
          title: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                    child: Text(ticketFlag?.flaged == 1 ? "Flag Added" : "Flag Removed", style: const TextStyle(fontWeight: FontWeight.bold)))),
            Text(ticketFlag?.comment ?? ''),
            const Divider(),
          ]),
          subtitle: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Padding(padding: const EdgeInsets.only(bottom: 4.0), child: UserButton(nsUserId: ticketFlag?.user, imageRadius: 16)),
                const Spacer(),
                Text(ticketFlag?.getDateTime(), style: const TextStyle(color: Colors.blue)),
              ],
            ),
          ),
          // leading: UserImage(nsUserId: ticketFlag.user, radius: 24),
        ),
      ),
    );
  }
}

class FlagDialog1 {
  static int FLAG_TYPE_RED = 1;

  static showRedFlagDialog(BuildContext context, Ticket ticket) async {
    flagType = TicketFlagTypes.RED;
    addTitle = "Set Red Flag";
    removeTitle = "Remove Red Flag";
    icon = const Icon(Icons.flag_rounded, color: Colors.red);
    _commentPlaceHolder = "Red Flag Comment";

    _showDialog(context, ticket);
  }

  static showLoadingDialog(context, String text) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(child: ListBody(children: [Text(text, textScaleFactor: 1.2)])),
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
    return Api.post(EndPoints.tickets_flags_setFlag, {"comment": comment, "type": type, "ticket": ticket.id.toString()});
  }

  static removeFlag(String type, Ticket ticket) {
    return Api.post(EndPoints.tickets_flags_removeFlag, {"type": type, "ticket": ticket.id.toString()});
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
    icon = const Icon(NsIcons.gr, color: Colors.blue);
    // icon = CircleAvatar(backgroundColor: Colors.blue, child: Center(child: Text("GR", style: TextStyle(color: Colors.white))));
    _commentPlaceHolder = "GR Comment";

    _showDialog(context, ticket);
  }

  // static showSKDialog(BuildContext context1, Ticket ticket) {}

  static showRushDialog(BuildContext context, Ticket ticket) {
    flagType = TicketFlagTypes.RUSH;
    addTitle = "Set Rush";
    removeTitle = "Remove Rush";
    icon = const Icon(Icons.offline_bolt_rounded, color: Colors.orangeAccent);
    _commentPlaceHolder = "Rush Comment";

    _showDialog(context, ticket);
  }

  static _showDialog(context, ticket) {
    TextEditingController commentController = TextEditingController();
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
              content: SizedBox(
                height: 500,
                width: 500,
                child: Column(
                  children: [
                    SizedBox(
                      height: 400,
                      child: ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, i) {
                            TicketFlag ticketFlag = list[i];
                            return Card(
                              child: ListTile(
                                title: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                                          child: Text(ticketFlag.flaged == 1 ? "Flag Added" : "Flag Removed", style: const TextStyle(fontWeight: FontWeight.bold)))),
                                  Text(ticketFlag.comment),
                                  const Divider(),
                                ]),
                                subtitle: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: UserButton(nsUserId: ticketFlag.user, imageRadius: 16),
                                      ),
                                      const Spacer(),
                                      Text(ticketFlag.getDateTime(), style: const TextStyle(color: Colors.blue)),
                                    ],
                                  ),
                                ),
                                // leading: UserImage(nsUserId: ticketFlag.user, radius: 24),
                              ),
                            );
                          }),
                    ),
                    if (!isFlaged)
                      SizedBox(
                        width: 500,
                        child: TextFormField(
                          controller: commentController,
                          decoration: InputDecoration(hintText: _commentPlaceHolder),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        ),
                      ),
                    if (isFlaged) const Text(""),
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
                          setFlag(flagType.getValue(), commentController.value.text, ticket).then((value) {
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
    Center title;
    String titleText;
    Icon? titleIcon;
    switch (flagType) {
      case TicketFlagTypes.HOLD:
        titleText = "Hold";
        titleIcon = const Icon(Icons.pan_tool_rounded);
        break;
      case TicketFlagTypes.RED:
        titleText = "Red Flag";
        titleIcon = const Icon(Icons.tour_rounded);
        break;
      case TicketFlagTypes.GR:
        titleText = "Graphics";
        // titleIcon = CircleAvatar(backgroundColor: Colors.blue, child: Center(child: Text("GR", style: TextStyle(color: Colors.white))));
        titleIcon = const Icon(NsIcons.gr);
        break;

      case TicketFlagTypes.RUSH:
        titleText = "Rush";
        titleIcon = const Icon(Icons.flash_on_rounded);
        break;
      case TicketFlagTypes.SK:
        titleText = "SK";
        // titleIcon = CircleAvatar(backgroundColor: Colors.pink, child: Center(child: Text("SK", style: TextStyle(color: Colors.white))));
        titleIcon = const Icon(NsIcons.sk);
        break;
      case TicketFlagTypes.YELLOW:
        titleIcon = const Icon(Icons.tour_rounded, color: Colors.yellow);
        titleText = "Yellow";
        break;
    }

    title = Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [(titleIcon), Text(titleText)]));

    TicketFlag ticketFlag = TicketFlag.fromJson({});

    double w = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: title,
              content: SizedBox(
                width: w,
                child: ListTile(
                  title: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                            child: Text(ticketFlag.flaged == 1 ? "Flag Added" : "Flag Removed", style: const TextStyle(fontWeight: FontWeight.bold)))),
                    Text(ticketFlag.comment),
                    const Divider(),
                  ]),
                  subtitle: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: UserButton(nsUserId: ticketFlag.user, imageRadius: 16),
                        ),
                        const Spacer(),
                        Text(ticketFlag.getDateTime(), style: const TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                  // leading: UserImage(nsUserId: ticketFlag.user, radius: 24),
                ),
              ),

              // content: ListTile(
              //   // title: Text(tf.isFlaged ? "Flag Added" : "Flag Removed"),
              //   title: Column(mainAxisSize: MainAxisSize.min,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Padding(padding: const EdgeInsets.all(8.0), child: Text(tf.comment, textScaleFactor: 1.2, style: TextStyle(color: Colors.black))),
              //       Align(alignment: Alignment.bottomRight, child: Text(tf.getDateTime(), style: TextStyle(color: Colors.blue)))
              //     ],
              //   ),
              //   leading: UserImage(nsUserId: tf.user),
              //   // leading: CircleAvatar(
              //   //     radius: 24.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
              // )
            ));
  }

// static showStopProductionFlagDialog(BuildContext context, Ticket ticket) {
//   flagType = TicketFlagTypes.HOLD;
//   addTitle = "Stop Production";
//   removeTitle = "Restart Production";
//   icon = const Icon(Icons.pan_tool_rounded, color: Colors.red);
//   _commentPlaceHolder = "Comment";
//
//   _showDialog(context, ticket);
// }
}
