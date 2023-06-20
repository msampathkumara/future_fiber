import 'package:deebugee_plugin/DialogView.dart';
import 'package:dio/src/response.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';
import 'package:smartwind_future_fibers/M/TicketFlag.dart';

import '../../../../../C/Api.dart';
import '../../../../../M/EndPoints.dart';
import '../../../../../M/NsUser.dart';
import '../../../../../ns_icons_icons.dart';
import '../../../Widgets/UserImage.dart';

class FlagDialogNew extends StatefulWidget {
  final Ticket ticket;
  final TicketFlagTypes ticketFlagType;
  final bool editable;

  const FlagDialogNew(this.ticket, this.ticketFlagType, {Key? key, this.editable = true}) : super(key: key);

  @override
  State<FlagDialogNew> createState() => _FlagDialogNewState();

  Future show(context) {
    return showDialog(context: context, builder: (_) => this);
  }
}

class _FlagDialogNewState extends State<FlagDialogNew> {
  late TicketFlagTypes flagType;
  late String addTitle;
  late String removeTitle;
  late Widget icon;

  final TextEditingController _commentController = TextEditingController();
  late Ticket ticket;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    ticket = widget.ticket;
    setFlagInfo();

    loadData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogView(width: 500, child: getUi());
  }

  List<TicketFlag>? commentList;

  bool isFlaged = false;
  late TicketFlag lastFlag;

  Theme getUi() {
    return Theme(
        data: Theme.of(context).copyWith(
            scrollbarTheme:
                const ScrollbarThemeData().copyWith(thumbColor: MaterialStateProperty.all(Theme.of(context).primaryColor), thumbVisibility: MaterialStateProperty.all(true))),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: commentList == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Scaffold(
                        backgroundColor: Colors.transparent,
                        appBar: AppBar(
                            automaticallyImplyLeading: false,
                            actions: [
                              IconButton(onPressed: () => {Navigator.of(context).pop()}, icon: const Icon(Icons.close))
                            ],
                            title: ListTile(
                                leading: CircleAvatar(backgroundColor: Colors.white, child: icon),
                                title: Text(widget.editable ? (isFlaged ? removeTitle : addTitle) : addTitle.replaceAll("Set", ""),
                                    textScaleFactor: 1, style: const TextStyle(color: Colors.white)))),
                        body: ListView.separated(
                            controller: _scrollController,
                            padding: EdgeInsets.only(bottom: isFlaged ? 50 : 162.0),
                            reverse: true,
                            itemBuilder: (BuildContext context, int index) {
                              return const Divider(height: 0, color: Colors.transparent);
                            },
                            itemCount: (commentList?.length ?? 0) + 1,
                            separatorBuilder: (BuildContext context, int index) {
                              return getChatElement(commentList![index]);
                            })),
                    if (widget.editable)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: BottomAppBar(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8, bottom: 8, right: 8),
                            child: Container(
                                constraints: const BoxConstraints(minWidth: 100, maxWidth: 500),
                                child: Column(
                                  children: [
                                    if (!isFlaged)
                                      Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: SizedBox(
                                              child: Padding(
                                                  padding: const EdgeInsets.only(left: 0.0),
                                                  child: TextFormField(
                                                      keyboardType: TextInputType.multiline,
                                                      maxLines: null,
                                                      minLines: 4,
                                                      controller: _commentController,
                                                      onChanged: (c) {
                                                        setState(() {});
                                                      },
                                                      onFieldSubmitted: (x) {
                                                        if (x.isNotEmpty) {
                                                          saveComment(_commentController.value.text);
                                                          _commentController.clear();
                                                        }
                                                      },
                                                      decoration: InputDecoration(
                                                          focusedBorder:
                                                              OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(16)),
                                                          enabledBorder:
                                                              UnderlineInputBorder(borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(16)),
                                                          filled: true,
                                                          fillColor: Colors.grey.shade100,
                                                          focusColor: Colors.grey.shade100,
                                                          border: InputBorder.none,
                                                          hintText: 'Enter your Comment',
                                                          hintStyle: const TextStyle(color: Colors.grey)))))),
                                    (!isFlaged)
                                        ? SizedBox(
                                            width: double.infinity,
                                            height: 36,
                                            child: ElevatedButton(
                                                child: const Text('Add Flag'),
                                                onPressed: () {
                                                  showLoadingDialog(context, "Updating Data");
                                                  setFlag(flagType.getValue(), _commentController.value.text, ticket)
                                                      .then((value) => {Navigator.of(context).pop(true), Navigator.of(context).pop(true)});
                                                }),
                                          )
                                        : SizedBox(
                                            width: double.infinity,
                                            height: 36,
                                            child: ElevatedButton(
                                                child: const Text('Remove Flag'),
                                                onPressed: () {
                                                  showLoadingDialog(context, "Updating Data");
                                                  removeFlag(flagType.getValue(), ticket).then((value) => {Navigator.of(context).pop(false), Navigator.of(context).pop(false)});
                                                }),
                                          )
                                  ],
                                )),
                          ),
                        ),
                      )
                  ],
                ),
        ));
  }

  void saveComment(text) {}

  Card getChatElement(TicketFlag ticketFlag) {
    NsUser? nsUser = NsUser.fromId(ticketFlag.user);

    // if (chatEntry.chatEntryTypes == ChatEntryTypes.comment) {
    return Card(
        elevation: 0.5,
        margin: const EdgeInsets.all(8),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              minLeadingWidth: 1,
              minVerticalPadding: 0,
              leading: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [UserImage(nsUser: nsUser, radius: 24)]),
              title: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(children: [
                    Text("${nsUser?.name}", textScaleFactor: 1),
                    const Spacer(),
                    // const Padding(padding: EdgeInsets.only(top: 16.0), child: Text("20", style: TextStyle(color: Colors.grey)))
                  ])),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(ticketFlag.getDateTime()),
                      const Spacer(),
                      Text(ticketFlag.flaged == 1 ? "Flag Added" : "Flag Removed", style: const TextStyle(color: Colors.redAccent))
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(ticketFlag.comment, textScaleFactor: 1, style: const TextStyle(color: Colors.black)),
                  const SizedBox(height: 24)
                ],
              ),
              contentPadding: const EdgeInsets.only(right: 0.0, left: 16),
              visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
              // trailing: IconButton(padding: EdgeInsets.zero, onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded, color: Colors.grey))
            )));
  }

  void loadData() {
    Ticket.getFlagList(flagType.getValue(), ticket).then((list) {
      commentList = list;

      if (commentList!.isEmpty) {
        isFlaged = false;
      } else {
        lastFlag = commentList![0];
        isFlaged = lastFlag.isFlaged;
      }
      setState(() {});
    });
  }

  static Future<void> showLoadingDialog(context, String text) {
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
    return Api.post(EndPoints.tickets_flags_setFlag, {"comment": comment, "type": type, "ticket": ticket.id.toString()});
  }

  static Future<Response> removeFlag(String type, Ticket ticket) {
    return Api.post(EndPoints.tickets_flags_removeFlag, {"type": type, "ticket": ticket.id.toString()});
  }

  void setFlagInfo() {
    flagType = widget.ticketFlagType;
    switch (widget.ticketFlagType) {
      case TicketFlagTypes.RED:
        addTitle = "Set Red Flag";
        removeTitle = "Remove Red Flag";
        icon = const Icon(Icons.flag_rounded, color: Colors.red);
        break;

      case TicketFlagTypes.GR:
        flagType = TicketFlagTypes.GR;
        addTitle = "Set GR";
        removeTitle = "Remove GR";
        icon = const Icon(NsIcons.gr, color: Colors.blue);
        break;
      case TicketFlagTypes.RUSH:
        flagType = TicketFlagTypes.RUSH;
        addTitle = "Set Rush";
        removeTitle = "Remove Rush";
        icon = const Icon(NsIcons.rush, color: Colors.orange);
        break;
      case TicketFlagTypes.SK:
        // TODO: Handle this case.
        break;
      case TicketFlagTypes.HOLD:
        flagType = TicketFlagTypes.HOLD;
        addTitle = "Stop Production";
        removeTitle = "Restart Production";
        icon = const Icon(Icons.pan_tool_rounded, color: Colors.red);
        break;
      case TicketFlagTypes.YELLOW:
        addTitle = "Set Yellow Flag";
        removeTitle = "Remove Yellow Flag";
        icon = const Icon(Icons.flag_rounded, color: Colors.orange);
        break;
    }
  }
}
