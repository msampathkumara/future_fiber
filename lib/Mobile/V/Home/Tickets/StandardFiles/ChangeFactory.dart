import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/M/StandardTicket.dart';

import '../../../../../C/Api.dart';

class changeFactory extends StatefulWidget {
  StandardTicket ticket;

  changeFactory(this.ticket);

  @override
  _changeFactoryState createState() => _changeFactoryState();
}

class _changeFactoryState extends State<changeFactory> {
  Section selectedSection = new Section();

  List<String> factoryList = ['Upwind', 'OD', 'Nylon Standard', 'OEM'];

  @override
  void initState() {
    factoryList.removeWhere((item) => item.toLowerCase() == (widget.ticket.production ?? "").toLowerCase());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Change Factory",
                  textScaleFactor: 2.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: DropdownButton<String>(
                  isDense: true,
                  hint: Text(
                    "Factory",
                    textScaleFactor: 1.5,
                  ),
                  value: selectedSection.factory == "" ? null : selectedSection.factory,
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSection.factory = newValue!;
                    });
                  },
                  items: factoryList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                          width: 150,
                          child: Text(
                            value,
                            textScaleFactor: 1.5,
                          )),
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO add link
                  Api.post("tickets/", {'ticketId': widget.ticket.id.toString(), "factory": selectedSection.factory}).then((response) async {
                    print(response.data);
                    Navigator.of(context).pop();
                  });
                },
                child: Text("Change"),
              )
            ],
          ),
        ),
      ),
      // appBar: AppBar(),
    );
  }
}
