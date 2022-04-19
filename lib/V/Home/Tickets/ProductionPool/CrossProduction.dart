import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

import '../../../../C/OnlineDB.dart';

class CrossProduction extends StatefulWidget {
  final Ticket ticket;

  CrossProduction(this.ticket, {Key? key}) : super(key: key);

  @override
  _CrossProductionState createState() {
    return _CrossProductionState();
  }

  show(context) {
    print('ssssssss');
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _CrossProductionState extends State<CrossProduction> {
  Section selectedSection = new Section();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(height: 200, width: 300, child: getUi()));
  }

  getUi() {
    return Scaffold(
      appBar: AppBar(title: Text("Cross Production")),
      body: Center(
        child: Container(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.vertical,
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Text("Cross Production", textScaleFactor: 2.5),
              // ),
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
                  items: <String>['Upwind', 'OD', 'Nylon', 'OEM'].map<DropdownMenuItem<String>>((String value) {
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
                  OnlineDB.apiPost("tickets/crossProduction/setCrossProduction", {'ticketId': widget.ticket.id.toString(), "factory": selectedSection.factory})
                      .then((response) async {
                    print(response.data);
                    Navigator.of(context).pop();
                  });
                },
                child: Text("Send"),
              )
            ],
          ),
        ),
      ),
      // appBar: AppBar(),
    );
  }
}
