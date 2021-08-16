import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/CPR.dart';

class SetClientToCPR extends StatefulWidget {
  CPR cpr;

  SetClientToCPR(this.cpr);

  @override
  _SetClientToCPRState createState() => _SetClientToCPRState();
}

class _SetClientToCPRState extends State<SetClientToCPR> {
  var _suppliers = ["Cutting", "SA", "Printing"];
  var _supplier1;

  var _supplier2;

  var _supplier3;

  @override
  Widget build(BuildContext context) {
    print('_supplier1 $_supplier1');

    return Container(
      child: Column(
        children: [
          ListTile(
            title: Text("First Supplier"),
            isThreeLine: true,
            subtitle: Row(
              children: [
                for (final _supplier in _suppliers)
                  SizedBox(
                    width: 200,
                    child: RadioListTile<String>(
                        selected: false,
                        toggleable: true,
                        title: Text(_supplier),
                        value: _supplier,
                        groupValue: _supplier1,
                        onChanged: (value) {
                          widget.cpr.supplier1 = value;
                          setState(() {
                            _supplier1 = value;
                          });
                        }),
                  ),
              ],
            ),
          ),
          if (_supplier1 != null)
            ListTile(
              title: Text("Second Supplier"),
              isThreeLine: true,
              subtitle: Row(
                children: [
                  for (final _supplier in _suppliers)
                    SizedBox(
                      width: 200,
                      child: RadioListTile<String>(
                          selected: false,
                          toggleable: true,
                          title: Text(_supplier),
                          value: _supplier,
                          groupValue: _supplier2,
                          onChanged: (value) {
                            widget.cpr.supplier2 = value;
                            setState(() {
                              _supplier2 = value;
                            });
                          }),
                    ),
                ],
              ),
            ),
          if (_supplier1 != null && _supplier2 != null)
            ListTile(
              title: Text("Third Supplier"),
              isThreeLine: true,
              subtitle: Row(
                children: [
                  for (final _supplier in _suppliers)
                    SizedBox(
                      width: 200,
                      child: RadioListTile<String>(
                          toggleable: true,
                          selected: false,
                          title: Text(_supplier),
                          value: _supplier,
                          groupValue: _supplier3,
                          onChanged: (value) {
                            widget.cpr.supplier3 = value;
                            setState(() {
                              _supplier3 = value;
                            });
                          }),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
