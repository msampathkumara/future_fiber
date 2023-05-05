import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/CPR/CPR.dart';

class SetClientToCPR extends StatefulWidget {
  final CPR cpr;

  const SetClientToCPR(this.cpr, {super.key});

  @override
  _SetClientToCPRState createState() => _SetClientToCPRState();
}

class _SetClientToCPRState extends State<SetClientToCPR> {
  final _suppliers = ["Cutting", "SA", "Printing"];
  String? _supplier1;
  String? _supplier2;
  String? _supplier3;

  @override
  Widget build(BuildContext context) {
    widget.cpr.suppliers = [_supplier1, _supplier2, _supplier3].whereType<String>().toList();
    return Column(
      children: [
        ListTile(
          title: const Text("First Supplier"),
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
            title: const Text("Second Supplier"),
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
            title: const Text("Third Supplier"),
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
                          setState(() {
                            _supplier3 = value;
                          });
                        }),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
