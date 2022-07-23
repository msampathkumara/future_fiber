import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/Tickets/TicketInfo/M/TicketChat.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

import '../../../../C/Api.dart';
import '../../../../M/NsUser.dart';
import '../../../../M/TicketComment.dart';
import '../../../Widgets/UserImage.dart';

class TicketChatView extends StatefulWidget {
  final Ticket ticket;

  const TicketChatView(this.ticket, {Key? key}) : super(key: key);

  @override
  State<TicketChatView> createState() => _TicketChatViewState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _TicketChatViewState extends State<TicketChatView> {
  late TicketChat ticketChat = TicketChat();

  final TextEditingController _chatBoxController = TextEditingController();

  var sub;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    ticketChat.ticket = (widget.ticket);

    DatabaseReference ref = FirebaseDatabase.instance.ref("ticketComment/${ticketChat.ticket.id}");
    sub = ref.onValue.listen((event) {
      loadData(ticketChat.ticket.id);
    });

    super.initState();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 500, child: getUi()));
  }

  getWebUi() {}

  getUi() {
    return Theme(
      data: Theme.of(context).copyWith(
          scrollbarTheme:
              const ScrollbarThemeData().copyWith(thumbColor: MaterialStateProperty.all(Theme.of(context).primaryColor), thumbVisibility: MaterialStateProperty.all(true))),
      child: Scaffold(
          body: Stack(
        children: [
          Scaffold(
              appBar: AppBar(
                toolbarHeight: 100,
                title: Row(
                  children: [
                    Wrap(
                      direction: Axis.vertical,
                      children: [Text("${ticketChat.ticket.mo}", textScaleFactor: 1), Text("${ticketChat.ticket.oe}", style: const TextStyle(), textScaleFactor: 0.8)],
                    ),
                    const Spacer(),
                    // Stack(
                    //   children: [
                    //     Padding(padding: const EdgeInsets.only(left: 0.0), child: SizedBox(height: 36, width: 36, child: UserImage(nsUser: NsUser.fromId(1), radius: 16))),
                    //     Padding(padding: const EdgeInsets.only(left: 30.0), child: SizedBox(height: 36, width: 36, child: UserImage(nsUser: NsUser.fromId(1), radius: 16))),
                    //     Padding(padding: const EdgeInsets.only(left: 60.0), child: SizedBox(height: 36, width: 36, child: UserImage(nsUser: NsUser.fromId(1), radius: 16))),
                    //     Padding(padding: const EdgeInsets.only(left: 90.0), child: SizedBox(height: 36, width: 36, child: UserImage(nsUser: NsUser.fromId(1), radius: 16)))
                    //   ],
                    // )
                  ],
                ),
                // actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.info))]
              ),
              body: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 54.0),
                reverse: true,
                itemBuilder: (BuildContext context, int index) {
                  return const Divider(height: 0, color: Colors.transparent);
                },
                itemCount: (ticketChat.commentList?.length ?? 0) + 1,
                separatorBuilder: (BuildContext context, int index) {
                  print('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz $index');
                  return getChatElement(ticketChat.commentList![index]);
                },
              )),
          if (ticketChat.commentList == null) const Align(alignment: Alignment.center, child: CircularProgressIndicator()),
          Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8, bottom: 8, right: 8),
                  child: Container(
                      constraints: const BoxConstraints(minWidth: 100, maxWidth: 500),
                      child: Row(
                        children: [
                          // if (_chatBoxController.value.text.isEmpty) IconButton(onPressed: () {}, icon: const Icon(Icons.image)),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.grey.shade100),
                              child: SizedBox(
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: TextFormField(
                                    controller: _chatBoxController,
                                    onChanged: (c) {
                                      setState(() {});
                                    },
                                    onFieldSubmitted: (x) {
                                      if (x.isNotEmpty) {
                                        saveComment(_chatBoxController.value.text);
                                        _chatBoxController.clear();
                                      }
                                    },
                                    decoration: InputDecoration(
                                        fillColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        border: InputBorder.none,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24.0),
                                        ),
                                        enabledBorder: InputBorder.none,
                                        hintText: 'Enter your Comment',
                                        hintStyle: const TextStyle(color: Colors.grey)
                                        // prefixIcon: Icon(Icons.search, color: Colors.white)
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: _chatBoxController.value.text.isNotEmpty
                                  ? () {
                                      saveComment(_chatBoxController.value.text);
                                      _chatBoxController.clear();
                                    }
                                  : null,
                              icon: const Icon(Icons.send),
                              color: Theme.of(context).primaryColor)
                        ],
                      )),
                ),
              ))
        ],
      )),
    );
  }

  getChatElement(TicketComment ticketComment) {
    NsUser? nsUser = NsUser.fromId(ticketComment.userId);

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
                  Wrap(
                    children: [
                      Text(ticketComment.dateTime),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(ticketComment.comment, textScaleFactor: 1, style: const TextStyle(color: Colors.black)),
                  const SizedBox(height: 24)
                ],
              ),
              contentPadding: const EdgeInsets.only(right: 0.0, left: 16),
              visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
              // trailing: IconButton(padding: EdgeInsets.zero, onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded, color: Colors.grey))
            )));
  }

  void loadData(int id) {
    Api.get("tickets/comments/list", {'ticketId': id})
        .then((res) {
          Map data = res.data;

          ticketChat.commentList = TicketComment.fromJsonArray(data['comments']).reversed.toList();
          setState(() {});
        })
        .whenComplete(() {})
        .catchError((err) {
          print(err);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(err.toString()),
              action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    loadData(id);
                  })));
          setState(() {
            // _dataLoadingError = true;
          });
        });
  }

  void saveComment(String newComment) {
    print('xxxxxxxxxxxxxx');
    FocusScope.of(context).requestFocus(FocusNode());
    // setState(() {
    //   _newComment = TicketComment();
    //   _newComment.userId = AppUser.getUser()?.id ?? 0;
    //   _newComment.comment = newComment;
    //   ticketChat.commentList.add(_newComment);
    // });
    Api.post("tickets/comments/save", {'comment': newComment, 'ticketId': ticketChat.ticket.id}).then((res) {
      Map data = res.data;
      print(data['comment']);

      setState(() {
        ticketChat.commentList ??= [];
        ticketChat.commentList?.insert(0, TicketComment.fromJson(data['comment']));
      });
      print('saveeeeeeeeeeeee');
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                saveComment(newComment);
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
