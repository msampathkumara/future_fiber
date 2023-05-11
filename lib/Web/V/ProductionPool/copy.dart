import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../globals.dart';

class TextCopy extends StatefulWidget {
  final Widget child;

  const TextCopy({Key? key, required this.child}) : super(key: key);

  @override
  State<TextCopy> createState() => _TextCopyState();
}

class _TextCopyState extends State<TextCopy> {
  @override
  Widget build(BuildContext context) {
    return Container(key: menuKey, child: MouseRegion(onExit: (event) => {}, onHover: (event) => showMenus(context), child: widget.child));
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

class TextMenu extends StatelessWidget {
  final Text child;

  const TextMenu({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContextMenuArea(
        builder: (context) => [
              ListTile(
                dense: true,
                leading: const Icon(Icons.copy),
                title: Wrap(children: [const Text('Copy '), Text('  ${child.data}', style: const TextStyle(color: Colors.redAccent))]),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: child.data ?? ''));
                  Navigator.of(context).pop();
                  snackBarKey.currentState?.showSnackBar(const SnackBar(behavior: SnackBarBehavior.floating, width: 200, content: Text('Copied')));
                },
              )
            ],
        child: child);
  }
}
