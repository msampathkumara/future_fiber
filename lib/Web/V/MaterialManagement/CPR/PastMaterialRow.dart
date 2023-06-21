import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../M/CPR/CprItem.dart';

class PastMaterialRow extends StatefulWidget {
  const PastMaterialRow({Key? key}) : super(key: key);

  @override
  State<PastMaterialRow> createState() => _PastMaterialRowState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _PastMaterialRowState extends State<PastMaterialRow> {
  @override
  Widget build(BuildContext context) {
    return DialogView(child: getWebUi());
  }

  List<CprItem> items = [];

  getWebUi() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, items);
          },
          child: const Icon(Icons.done_rounded)),
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                hintText: 'Excel Rows',
                contentPadding: const EdgeInsets.only(left: 16.0, bottom: 16.0, top: 16.0),
                border: OutlineInputBorder(borderSide: const BorderSide(color: Colors.orange), borderRadius: BorderRadius.circular(4)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.orange), borderRadius: BorderRadius.circular(4)),
                enabledBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.orange), borderRadius: BorderRadius.circular(4)),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 10,
              onChanged: (t) {
                items = [];
                // List<String> c = t.split("	 ");
                // List<String> c = t.split("\n");

                LineSplitter ls = const LineSplitter();
                List<String> c = ls.convert(t);

                for (var element in c) {
                  CprItem ci = CprItem();
                  ci.item = element.split("	")[0];
                  ci.qty = "${element.split("	")[1]} ${element.split("	")[2]}";
                  items.add(ci);
                }
                setState(() {});
              }),
          Expanded(
              child: DataTable2(
            columns: const [
              DataColumn(label: Text('Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Qty', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
            ],
            rows: items.map<DataRow>((item) => DataRow(cells: [DataCell(Text(item.item)), DataCell(Text(item.qty))])).toList(),
          ))
        ]),
      ),
    );
  }

  getUi() {}
}
