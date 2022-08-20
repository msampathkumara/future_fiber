import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({Key? key}) : super(key: key);

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(height: 350, width: 400, child: getWebUi()));
  }

  getWebUi() {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Icon(Icons.delete_forever, color: Colors.red, size: 96)),
        ),
        const Padding(padding: EdgeInsets.all(8.0), child: Text("Are You Sure ?", textScaleFactor: 1.5)),
        const Text("Do you really want to remove this recode ?"),
        const SizedBox(height: 16),
        Wrap(children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"))),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Delete")))
        ])
      ]),
    );
  }

  getUi() {
    getWebUi();
  }
}
