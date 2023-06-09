import 'package:data_table_2/data_table_2.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:deebugee_plugin/IfWeb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../C/Api.dart';
import '../../../../M/CPR/CPR.dart';
import '../../../../M/EndPoints.dart';
import '../../../../M/Ticket.dart';
import '../../../../Mobile/V/Widgets/UserImage.dart';
import '../orderOprions.dart';

class TicketCprList extends StatefulWidget {
  final Ticket ticket;

  const TicketCprList(this.ticket, {Key? key}) : super(key: key);

  @override
  State<TicketCprList> createState() => _TicketCprListState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _TicketCprListState extends State<TicketCprList> {
  late Ticket ticket;

  int? dataCount;

  bool loading = true;

  List<CPR> cprList = [];

  @override
  void initState() {
    ticket = widget.ticket;
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 1000, child: getWebUi()));
  }

  Scaffold getWebUi() {
    return Scaffold(
        appBar: AppBar(
            title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('${ticket.mo}'), Text('${ticket.oe}', textScaleFactor: 0.8)])),
        body: DataTable2(
          headingRowHeight: 0,
          columns: const [
            // DataColumn2(label: Text('', style: TextStyle(fontStyle: FontStyle.italic))),
            DataColumn2(label: Text('', style: TextStyle(fontStyle: FontStyle.italic))),
            DataColumn2(label: Text('', style: TextStyle(fontStyle: FontStyle.italic))),
            DataColumn2(label: Text('', style: TextStyle(fontStyle: FontStyle.italic))),
            DataColumn2(label: Text('', style: TextStyle(fontStyle: FontStyle.italic))),
            DataColumn2(label: Text('', style: TextStyle(fontStyle: FontStyle.italic))),
          ],
          rows: cprList
              .map((cpr) => DataRow2(
                      specificRowHeight: 60,
                      onTap: () {
                        showOrderOptions(CprType.cpr, cpr, cpr.ticket, context, context, () {
                          Navigator.of(context).pop();
                        });
                      },
                      cells: [
                        // DataCell(Padding(padding: const EdgeInsets.all(16.0), child: Text('${index + 1}'))),
                        DataCell(ListTile(title: Text(cpr.client ?? ''), subtitle: Text(cpr.suppliers.join(',')))),
                        DataCell(ListTile(title: Text(cpr.shortageType ?? ''), subtitle: Text(cpr.cprType ?? ''))),
                        DataCell(ListTile(title: Text(cpr.shipDate))),
                        DataCell(ListTile(title: Text(cpr.status), subtitle: Text(cpr.orderType ?? ''))),
                        DataCell(ListTile(title: Text(cpr.user?.name ?? ''), subtitle: Text(cpr.addedOn))),
                      ]))
              .toList(),
        ));
  }

  getUi() {
    return Scaffold(
        appBar: AppBar(
            title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('${ticket.mo}'), Text('${ticket.oe}', textScaleFactor: 0.8)])),
        body: ListView.builder(
          itemCount: cprList.length,
          itemBuilder: (BuildContext context, int index) {
            CPR cpr = cprList[index];
            return Card(
                margin: const EdgeInsets.all(4.0),
                child: InkWell(
                  onTap: () {
                    showOrderOptions(CprType.cpr, cpr, cpr.ticket, context, context, () {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Table(
                    children: [
                      TableRow(children: [
                        ListTile(title: Text(cpr.client ?? ''), subtitle: Text(cpr.suppliers.join(','))),
                        ListTile(title: Text(cpr.shortageType ?? ''), subtitle: Text(cpr.cprType ?? '')),
                        ListTile(title: Text(cpr.shipDate)),
                      ]),
                      TableRow(children: [
                        ListTile(title: Text(cpr.status), subtitle: Text(cpr.orderType ?? '')),
                        ListTile(leading: UserImage(nsUser: cpr.user, radius: 16), title: Text(cpr.user?.name ?? ''), subtitle: Text(cpr.addedOn)),
                        Container()
                      ])
                    ],
                  ),
                ));
          },
        ));
  }

  Future getData() {
    return Api.get(EndPoints.materialManagement_cpr_getCprsByTicketId, {'ticketId': ticket.id}).then((res) {
      print('--------------------------------------------------------------------------------------------------xxxxxxxx-');
      dataCount = res.data["count"];

      cprList = CPR.fromJsonArray(res.data["cprs"]);
      print('---------------------------------------------------------------------------------------------------');
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                getData();
              })));
      setState(() {});
    });
  }
}
