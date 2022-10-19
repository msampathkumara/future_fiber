import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/CPR/CprItem.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

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
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
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
          TextFormField(onChanged: (t) {
            items = [];
            List<String> c = t.split("	 ");

            for (var element in c) {
              CprItem ci = CprItem();
              ci.item = element.split("	")[1];
              ci.qty = "${element.split("	")[2]} ${element.split("	")[3]}";
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
