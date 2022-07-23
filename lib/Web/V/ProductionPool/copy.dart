import 'package:flutter/material.dart';

class TextCopy extends StatefulWidget {
  final Widget child;

  const TextCopy({Key? key, required this.child}) : super(key: key);

  @override
  State<TextCopy> createState() => _TextCopyState();
}

class _TextCopyState extends State<TextCopy> {
  @override
  Widget build(BuildContext context) {
    return Container(key: menuKey, child: MouseRegion(onHover: (event) => showMenus(context), child: widget.child));
  }

  GlobalKey menuKey = GlobalKey();

  showMenus(BuildContext context) async {
    final render = menuKey.currentContext!.findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
      position: RelativeRect.fromLTRB(render.localToGlobal(Offset.zero).dx + render.size.width, render.localToGlobal(Offset.zero).dy, double.infinity, double.infinity),
      items: [
        const PopupMenuItem(
          child: Text("copy"),
        )
      ],
    );
  }
}
