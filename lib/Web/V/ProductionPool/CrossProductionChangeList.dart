import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../C/Api.dart';
import '../../../M/NsUser.dart';
import '../../../M/Ticket.dart';
import '../../../V/Widgets/UserImage.dart';
import '../../Widgets/DialogView.dart';

class CrossProductionChangeList extends StatefulWidget {
  final Ticket ticket;

  const CrossProductionChangeList(this.ticket, {Key? key}) : super(key: key);

  @override
  State<CrossProductionChangeList> createState() => _CrossProductionChangeListState();

  void show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _CrossProductionChangeListState extends State<CrossProductionChangeList> {
  late Ticket ticket;

  List crossProList = [];
  bool _loading = false;

  @override
  void initState() {
    // TODO: implement initState
    ticket = widget.ticket;

    apiGetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogView(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Cross Production"),
            ),
            body: Center(
                child: Column(children: <Widget>[
              Container(
                  margin: const EdgeInsets.all(10),
                  child: Table(border: TableBorder.all(color: Colors.white), children: [
                    const TableRow(children: [Text("From"), Text("To"), Text("Date Time"), Text("By")]),
                    const TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text("")), Text(""), Text(""), Text("")]),
                    ...crossProList.map((crossPro) {
                      Map fromFactory = crossPro['fromFactory'];
                      Map toFactory = crossPro['toFactory'];
                      int upBy = crossPro['upBy'];
                      var upOn = crossPro['upOn'];
                      NsUser? nsUser = NsUser.fromId(upBy);
                      return TableRow(children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${fromFactory["factory"]}"), Text("${fromFactory["sectionTitle"]}")]),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${toFactory["factory"]}"), Text("${toFactory["sectionTitle"]}")]),
                        Text("$upOn"),
                        Wrap(children: [UserImage(nsUser: nsUser, radius: 12, padding: 2), Padding(padding: const EdgeInsets.all(8.0), child: Text("${nsUser?.name}"))])
                      ]);
                    }).toList()
                  ]))
            ]))),
        // body: ListView.separated(
        //     padding: const EdgeInsets.all(8),
        //     itemCount: crossProList.length,
        //     itemBuilder: (BuildContext context1, int index) {
        //       var crossPro = crossProList[index];
        //       Map fromFactory = crossPro['fromFactory'];
        //       Map toFactory = crossPro['toFactory'];
        //       int upBy = crossPro['upBy'];
        //       NsUser? nsUser = NsUser.fromId(upBy);
        //
        //       return ListTile(isThreeLine: true,subtitle: Text(""),
        //           leading: Column(
        //             children: [
        //               Text("${fromFactory["factory"]}"),
        //               Text("${fromFactory["sectionTitle"]}"),
        //               Wrap(
        //                 children: [
        //                   UserImage(nsUser: nsUser, radius: 12, padding: 2),
        //                   Text("${nsUser?.name}"),
        //                 ],
        //               ),
        //             ],
        //           ),
        //           trailing: Column(
        //             children: [
        //               Text("${toFactory["factory"]}"),
        //               Text("${toFactory["sectionTitle"]}"),
        //               Text("${toFactory["sectionTitle"]}"),
        //             ],
        //           ));
        //     },
        //     separatorBuilder: (BuildContext context, int index) {
        //       return const Divider();
        //     })),
        width: 700,
        height: 400);
  }

  Future apiGetData() {
    print('xxxxxxxxxxxxxxx');
    return Api.get("tickets/crossProduction/${ticket.id}/getList", {}).then((res) {
      Map data = res.data;

      crossProList = data["result"];

      print(data);
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                apiGetData();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
