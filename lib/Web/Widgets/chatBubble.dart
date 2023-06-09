import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/Chat/message.dart';
import 'package:smartwind_future_fibers/M/NsUser.dart';

import '../../Mobile/V/Widgets/UserImage.dart';
import '../V/ProductionPool/copy.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final bool isSelf;

  const ChatBubble(this.message, {this.isSelf = true, Key? key}) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  var selfBorderRadius = const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(0), bottomLeft: Radius.circular(8), topLeft: Radius.circular(8));
  var borderRadius = const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8), bottomLeft: Radius.circular(8), topLeft: Radius.circular(0));

  late NsUser? user;

  @override
  void initState() {
    user = NsUser.fromId(widget.message.userId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var userWidget = Row(
    //   children: [
    //     UserImage(nsUser: user, radius: 12),
    //     Column(
    //       children: [Text("${user?.name}",style: const TextStyle(fontSize: 15,color: Colors.white)),Text("${user?.uname}",style: const TextStyle(fontSize: 12,color: Colors.white))],
    //     )
    //   ],
    // );

    if ((widget.isSelf)) {
      return ListTile(
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 32,
          horizontalTitleGap: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Material(
                elevation: 4,
                borderRadius: selfBorderRadius,
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextMenu(child: Text(widget.message.text, style: const TextStyle(color: Colors.white))),
                )),
          ),
          trailing: UserImage(nsUser: user, radius: 12, padding: 0),
          subtitle: Row(
            children: [
              Text("${user?.name}", style: const TextStyle(fontSize: 8)),
              const Spacer(),
              Align(alignment: Alignment.bottomRight, child: Text(widget.message.dnt, style: const TextStyle(fontSize: 8))),
            ],
          ));
    } else {
      return ListTile(
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 24,
          horizontalTitleGap: 8,
          minVerticalPadding: 4,
          leading: UserImage(nsUser: user, radius: 12, padding: 0),
          title: Material(
              elevation: 4,
              borderRadius: borderRadius,
              color: Colors.grey,
              child: Padding(padding: const EdgeInsets.all(8.0), child: TextMenu(child: Text(widget.message.text, style: const TextStyle(color: Colors.white))))),
          subtitle: Align(alignment: Alignment.bottomRight, child: Text(widget.message.dnt, style: const TextStyle(fontSize: 8))));
    }
  }
}
