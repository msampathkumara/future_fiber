import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/CPR/CPR.dart';

class SetClientToCPR extends StatefulWidget {
  CPR cpr;
  var _supplier1;
  var _supplier2;
  var _supplier3;

  SetClientToCPR(this.cpr);

  @override
  _SetClientToCPRState createState() => _SetClientToCPRState();
}

class _SetClientToCPRState extends State<SetClientToCPR> {
  var _suppliers = ["Cutting", "SA", "Printing"];

  @override
  Widget build(BuildContext context) {
    widget.cpr.suppliers = [widget._supplier1, widget._supplier2, widget._supplier3];
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
                        groupValue: widget._supplier1,
                        onChanged: (value) {
                          setState(() {
                            widget._supplier1 = value;
                          });
                        }),
                  ),
              ],
            ),
          ),
          if (widget._supplier1 != null)
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
                          groupValue: widget._supplier2,
                          onChanged: (value) {
                            setState(() {
                              widget._supplier2 = value;
                            });
                          }),
                    ),
                ],
              ),
            ),
          if (widget._supplier1 != null && widget._supplier2 != null)
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
                          groupValue: widget._supplier3,
                          onChanged: (value) {
                            setState(() {
                              widget._supplier3 = value;
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
