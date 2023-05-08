import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/Section.dart';
import 'package:smartwind_future_fibers/M/StandardTicket.dart';

import '../../../../../C/Api.dart';

class ChangeFactory extends StatefulWidget {
  final StandardTicket ticket;

  const ChangeFactory(this.ticket, {super.key});

  @override
  _ChangeFactoryState createState() => _ChangeFactoryState();
}

class _ChangeFactoryState extends State<ChangeFactory> {
  Section selectedSection = Section();

  List<String> factoryList = ["EC-SIX", "AERO-SIX", "FIBRE LIGHT", "Machine Shop", "PULTRUSION", "TACO"];

  @override
  void initState() {
    factoryList.removeWhere((item) => item.toLowerCase() == (widget.ticket.production ?? "").toLowerCase());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Change Factory", textScaleFactor: 2.5),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: DropdownButton<String>(
                isDense: true,
                hint: const Text("Factory", textScaleFactor: 1.5),
                value: selectedSection.factory == "" ? null : selectedSection.factory,
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(height: 2, color: Colors.deepPurpleAccent),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSection.factory = newValue!;
                  });
                },
                items: factoryList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: SizedBox(width: 150, child: Text(value, textScaleFactor: 1.5)),
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
              child: const Text("Change"),
            )
          ],
        ),
      ),
      // appBar: AppBar(),
    );
  }
}
