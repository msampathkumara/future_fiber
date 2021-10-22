import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/ServerResponce/Progress.dart';
import 'package:smartwind/V/Widgets/UserButton.dart';

class info_Progress extends StatefulWidget {
  List<Progress> progressList;

  info_Progress(this.progressList);

  @override
  _info_ProgressState createState() => _info_ProgressState();
}

class _info_ProgressState extends State<info_Progress> {
  List<Progress> progressList = [];

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    progressList = widget.progressList;
    return Container(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: progressList.length,
        itemBuilder: (BuildContext context, int index) {
          Progress progress = progressList[index];

          return Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: progress.status == 1 ? Colors.green : Colors.grey[100]),
              child: ListTile(
                  title: Row(
                    children: [
                      Expanded(flex: 3, child: Text((progress.operation ?? "").splitFromCaps, style: TextStyle(color: progress.status == 1 ? Colors.white : Colors.black))),
                      Expanded(flex: 3, child: Container(child: Chip(label: Text((progress.section!.sectionTitle) + " @ " + progress.section!.factory)))),
                      Expanded(
                          flex: 3,
                          child: Text((progress.finishedOn != "0" ? (progress.finishedOn!.replaceAll(RegExp(' '), '\n')) : ""),
                              style: TextStyle(color: progress.status == 1 ? Colors.white : Colors.black)))
                    ],
                  ),
                  trailing: progress.finishedBy != null ? SizedBox(width: 30, child: UserButton(nsUserId: progress.finishedBy, imageRadius: 16, hideName: true)) : Text("")));
        },
        separatorBuilder: (BuildContext context, int index) {
          return Padding(padding: const EdgeInsets.all(4.0), child: Divider(height: 1, endIndent: 0.5, color: Colors.white38));
        },
      ),
    );
  }
}

extension CapExtension on String {
  String get splitFromCaps => this.split(RegExp(r"(?=[A-Z])")).join(" ");
}
