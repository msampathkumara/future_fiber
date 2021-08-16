import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/CPR.dart';
import 'package:smartwind/M/CprMaterial.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/CPR/SetClientsToCPR.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';

class AddCPR extends StatefulWidget {
  Ticket ticket;

  AddCPR(this.ticket);

  @override
  _AddCPRState createState() => _AddCPRState();
}

class _AddCPRState extends State<AddCPR> {
  var _sailTypes = ["Standard", "Custom"];
  var _shortageTypes = ["Short", "Damage", "Unreceived"];
  var _sailType;
  var _cPRType = "--Select--";

  CPR _cpr = new CPR();
  bool saving = false;

  List<CprMaterial> materials = [];

  @override
  void initState() {
    super.initState();
    _cpr.ticket = widget.ticket;
  }

  @override
  Widget build(BuildContext context) {
    print(_cpr.toJson());
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            saving = true;
            OnlineDB.apiPost("cpr/saveCpr", _cpr.toJson()).then((value) {
              saving = false;
            }).catchError((onError) {
              ErrorMessageView(errorMessage: onError.toString()).show(context);
            });
          },
          child: const Icon(Icons.save),
          backgroundColor: Colors.lightBlue,
        ),
        appBar: AppBar(
          title: Text("Add CPR"),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(64.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    if (_cpr.ticket!.mo != null)
                      Text(
                        "${_cpr.ticket!.mo}  ",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    if (_cpr.ticket!.oe != null)
                      Text(
                        "${_cpr.ticket!.oe}",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                  ],
                ),
              )),
        ),
        body: Container(
            child: Column(children: [
          ListTile(
            title: Text("Sail Type"),
            isThreeLine: true,
            subtitle: Card(
              margin: EdgeInsets.all(8.0),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  for (final _sailT in _sailTypes)
                    SizedBox(
                      width: 200,
                      child: RadioListTile(
                          selected: false,
                          toggleable: true,
                          title: Text(_sailT),
                          value: _sailT,
                          groupValue: _sailType,
                          onChanged: (value) {
                            setState(() {
                              _sailType = value;
                              _cpr.sailType = value as String?;
                            });
                          }),
                    ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text("Shortage Type"),
            isThreeLine: true,
            subtitle: Card(
              margin: EdgeInsets.all(8.0),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  for (final _shortageT in _shortageTypes)
                    SizedBox(
                      width: 200,
                      child: RadioListTile(
                          selected: false,
                          toggleable: true,
                          title: Text(_shortageT),
                          value: _shortageT,
                          groupValue: _sailType,
                          onChanged: (value) {
                            setState(() {
                              _sailType = value;
                              _cpr.shortageType = value as String?;
                            });
                          }),
                    ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text("CPR Type"),
            subtitle: SizedBox(
              width: 200,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<String>(
                    hint: Text(_cPRType),
                    items: <String>['Pocket', 'Rope Luff', 'C', 'D'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _cPRType = value!;
                      _cpr.cprType = value;
                      setState(() {});
                    }),
              ),
            ),
          ),
          ListTile(title: Text("Suppliers"), subtitle: Card(child: SetClientToCPR(_cpr))),
          ListTile(
              title: Text("Comment"),
              subtitle: Card(
                  child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextField(
                          onChanged: (value) {
                            _cpr.comment = value;
                          },
                          maxLines: 8,
                          decoration: InputDecoration.collapsed(hintText: "Enter your comment here"))))),
          ListTile(
            title: Text("Image URL"),
            subtitle: Card(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
                        onChanged: (value) {
                          _cpr.image = value;
                        },
                        maxLines: 3,
                        decoration: InputDecoration.collapsed(hintText: "Enter your url here")))),
          ),
          ListTile(
            title: Text("Materials"),
            subtitle: Card(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        for (final material in materials)
                          ListTile(
                            title: Text(material.name),
                            trailing: Text("${material.qty}"),
                          ),
                        ListTile(
                          title: TextField(
                              onChanged: (value) {
                                _cpr.image = value;
                              },
                              maxLines: 3,
                              decoration: InputDecoration.collapsed(hintText: "Enter your url here")),
                        ),
                      ],
                    ))),
          ),
        ])));
  }
}
