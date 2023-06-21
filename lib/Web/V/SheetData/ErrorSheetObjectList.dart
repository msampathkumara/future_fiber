import 'package:data_table_2/data_table_2.dart';
import 'package:deebugee_plugin/IfWeb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:deebugee_plugin/DialogView.dart';

class ErrorSheetObjectList extends StatefulWidget {
  final List dataList;

  const ErrorSheetObjectList(this.dataList, {Key? key}) : super(key: key);

  @override
  State<ErrorSheetObjectList> createState() => _ErrorSheetObjectListState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _ErrorSheetObjectListState extends State<ErrorSheetObjectList> {
  List dataList = [];

  @override
  void initState() {
    // TODO: implement initState
    dataList = widget.dataList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 1000, child: getWebUi()));
  }

  getWebUi() {
    return Scaffold(
        appBar: AppBar(title: const Text('Error Data List')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              columns: ['production', 'item number', 'oper. no.', 'next', 'operation', 'pool', 'delivery', 'ship date'].map((e) => DataColumn2(label: Text(e))).toList(),
              rows: dataList.map((d) {
                List errorCols = [];
                if (d['errorCols'] != null) {
                  errorCols = d['errorCols'];
                }
                print(d['errorCols']);

                return DataRow(
                    cells: ['production', 'item number', 'oper. no.', 'next', 'operation', 'pool', 'delivery', 'ship date'].map((e) {
                  return DataCell(Text("${d[e]}", style: TextStyle(color: errorCols.contains(e) ? Colors.red : null)));
                }).toList());
              }).toList()),
        ));
  }

  getUi() {
    return getWebUi();
  }
}
