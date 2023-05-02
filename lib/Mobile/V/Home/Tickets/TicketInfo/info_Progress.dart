import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/Mobile/V/Widgets/UserButton.dart';

import '../../../../../C/ServerResponse/Progress.dart';
import '../../../../../Web/V/QC/webTicketQView.dart';

class info_Progress extends StatefulWidget {
  final List<Progress> progressList;
  final Ticket ticket;

  const info_Progress(this.progressList, this.ticket, {Key? key}) : super(key: key);

  @override
  _info_ProgressState createState() => _info_ProgressState();
}

class _info_ProgressState extends State<info_Progress> {
  List<Progress> progressList = [];

  @override
  void initState() {
    progressList = widget.progressList;

    for (var i = 0; i < progressList.length; i++) {
      if (i == 0) {
        progressList[i].timeToFinish = "";
      } else {
        String? prevDate = progressList[i - 1].finishedOn;
        String? nDate = progressList[i].finishedOn;
        if (prevDate != null && prevDate.isNotEmpty) {
          if (nDate != null && nDate.isNotEmpty) {
            try {
              DateTime d = DateTime.parse(prevDate);
              DateTime d1 = DateTime.parse(nDate);
              var difference = d1.difference(d);
              int timeInMinutes = d1.difference(d).inMinutes;
              if (timeInMinutes == 0) {
                progressList[i].timeToFinish = "";
              } else {
                final minutes = (timeInMinutes % 60).toInt();
                final hours = (((timeInMinutes - minutes) / 60) % 24).toInt();
                final days = difference.inDays;
                progressList[i].timeToFinish = days > 0 ? "${days}d ${hours}h ${minutes}m" : "${hours}h ${minutes}m";
              }
            } catch (e) {
              progressList[i].timeToFinish = "";
            }
          }
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: progressList.length,
      itemBuilder: (BuildContext context, int index) {
        Progress progress = progressList[index];
        print(progress.toJson());
        return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: progress.status == 1 ? Colors.green : Colors.grey[100]),
            child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                        flex: 6,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text((progress.operation ?? "").splitFromCaps, textScaleFactor: 1, style: TextStyle(color: progress.status == 1 ? Colors.white : Colors.black)),
                          Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
                              padding: const EdgeInsets.all(2.0),
                              child: progress.section == null
                                  ? const Text("section not found", style: TextStyle(color: Colors.red))
                                  : Text("${progress.section!.sectionTitle} @ ${progress.section!.factory}", style: const TextStyle(color: Colors.redAccent)))
                        ])),
                    Expanded(
                        flex: 4,
                        child: Text((progress.finishedOn != null ? (progress.finishedOn!.replaceAll(RegExp(' '), '\n')) : ""),
                            style: TextStyle(color: progress.status == 1 ? Colors.white : Colors.black))),
                    Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            if (progress.isQc)
                              IconButton(
                                icon: const CircleAvatar(backgroundColor: Colors.red, radius: 8, child: Text('QC', style: TextStyle(fontSize: 8, color: Colors.white))),
                                onPressed: () {
                                  WebTicketQView(widget.ticket, true).show(context);
                                },
                              ),
                            if (progress.isQa)
                              IconButton(
                                  icon: const CircleAvatar(
                                      backgroundColor: Colors.deepOrangeAccent, radius: 8, child: Text('QA', style: TextStyle(fontSize: 8, color: Colors.white))),
                                  onPressed: () {
                                    WebTicketQView(widget.ticket, false).show(context);
                                  })
                          ],
                        )),
                    Expanded(flex: 4, child: Text("${progress.timeToFinish}", style: const TextStyle(color: Colors.white)))
                  ],
                ),
                trailing: progress.finishedBy != null ? SizedBox(width: 30, child: UserButton(nsUserId: progress.finishedBy, imageRadius: 16, hideName: true)) : const Text("")));
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Padding(padding: EdgeInsets.all(4.0), child: Divider(height: 1, endIndent: 0.5, color: Colors.white38));
      },
    );
  }
}

extension CapExtension on String {
  String get splitFromCaps => split(RegExp(r"(?=[A-Z])")).join(" ");
}
