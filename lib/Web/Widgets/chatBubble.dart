import 'package:flutter/material.dart';
import 'package:smartwind/M/Chat/message.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final isSelf;

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

    return (widget.isSelf)
        ? ListTile(
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 32,
            horizontalTitleGap: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Material(
                  elevation: 4,
                  borderRadius: selfBorderRadius,
                  color: Colors.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.message.text, style: const TextStyle(color: Colors.white)),
                  )),
            ),
            subtitle: const Align(
              child: Text("Nov 7, 2020 at 14:13", style: TextStyle(fontSize: 8)),
              alignment: Alignment.bottomRight,
            ))
        : ListTile(
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 24,
            horizontalTitleGap: 8,
            minVerticalPadding: 4,
            leading: UserImage(nsUser: user, radius: 12, padding: 0),
            title: Material(
                elevation: 4,
                borderRadius: borderRadius,
                color: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.message.text, style: const TextStyle(color: Colors.white)),
                )),
            subtitle: Align(
              child: Text(widget.message.dnt, style: const TextStyle(fontSize: 8)),
              alignment: Alignment.bottomRight,
            ));
  }
}
