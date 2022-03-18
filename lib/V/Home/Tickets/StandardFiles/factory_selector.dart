import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/hive.dart';

class FactorySelector extends StatefulWidget {
  String selectedFactory = "";
  Function onSelect;

  FactorySelector(this.selectedFactory, this.onSelect, {Key? key}) : super(key: key);

  @override
  State<FactorySelector> createState() => _FactorySelectorState();
}

List<String> factoryList = ['Upwind', 'OD', 'Nylon', 'OEM'];

class _FactorySelectorState extends State<FactorySelector> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Container(child: Center(child: CircularProgressIndicator()))
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(title: Text("Select Factory")),
              Divider(),
              Expanded(
                  child: Container(
                child: SingleChildScrollView(
                    child: Column(children: [
                  for (var x in factoryList)
                    RadioListTile(
                        value: x,
                        selected: widget.selectedFactory == x,
                        groupValue: widget.selectedFactory,
                        onChanged: (v) async {
                          setLoading(true);
                          await HiveBox.getDataFromServer();
                          widget.onSelect(v);
                          Navigator.of(context).pop(x);
                        },
                        title: Text(x)),
                ])),
              ))
            ],
          );
  }

  void setLoading(bool bool) {
    setState(() {
      _loading = bool;
    });
  }
}
