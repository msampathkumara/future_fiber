import 'package:flutter/material.dart';

import '../../../../../M/CPR/CPR.dart';

class info_short_items extends StatefulWidget {
  final List<CPR> cprs;

  const info_short_items(this.cprs, {Key? key}) : super(key: key);

  @override
  State<info_short_items> createState() => _info_short_itemsState();
}

class _info_short_itemsState extends State<info_short_items> {
  final _value = const TextStyle(fontSize: 14, color: Colors.black);
  final _title = const TextStyle(fontSize: 12, color: Colors.grey);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CPR> cprs = widget.cprs;
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: ListView.builder(
            itemCount: cprs.length,
            itemBuilder: (BuildContext context, int index) {
              CPR cpr = cprs[index];

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.all(8),
                elevation: 1,
                child: Column(children: [
                  Table(
                    children: [
                      TableRow(children: [
                        ListTile(dense: true, title: Text("Form Type", style: _title), subtitle: Text(cpr.formType, style: _value)),
                        ListTile(dense: true, title: Text("Status", style: _title), subtitle: Text(cpr.status, style: _value)),
                        ListTile(dense: true, title: Text("CPR Type", style: _title), subtitle: Text("${cpr.cprType}", style: _value))
                      ]),
                      TableRow(children: [
                        ListTile(dense: true, title: Text("Shortage Type", style: _title), subtitle: Text("${cpr.shortageType}", style: _value)),
                        ListTile(
                            dense: true,
                            title: Text("Date & Time", style: _title),
                            subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [Text("${cpr.date}", style: _value), Text("${cpr.time}", style: _value.copyWith(fontSize: 12))])),
                        Container()
                      ])
                    ],
                  ),
                  ListTile(dense: true, title: Text("Comment", style: _title), subtitle: Text(cpr.comment, style: _value.copyWith(fontStyle: FontStyle.italic))),
                  if (cpr.items.isNotEmpty) const Divider(),
                  ...cpr.items
                      .map((e) => ListTile(
                            title: Text(e.item),
                            subtitle: Text(e.qty, style: const TextStyle(color: Colors.redAccent)),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(e.supplier ?? '', textScaleFactor: 1)),
                                Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(e.dnt, style: const TextStyle(fontSize: 12, color: Colors.grey)))
                              ],
                            ),
                          ))
                      .toList()
                ]),
              );
            }));
  }
}
