import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';

import '../../../../C/Api.dart';
import '../../../../C/form_input_decoration.dart';
import '../../../../M/Ticket.dart';

class ReceiveKits extends StatefulWidget {
  const ReceiveKits({Key? key}) : super(key: key);

  @override
  State<ReceiveKits> createState() => _ReceiveKitsState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _ReceiveKitsState extends State<ReceiveKits> {
  String comment = "";

  var moNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 500, child: getWebUi()));
  }

  List<String> ticketList = [];
  final TextEditingController _controller = TextEditingController();

  getWebUi() {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Kits')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                autofocus: true,
                focusNode: moNode,
                onChanged: (a) {
                  setState(() {});
                },
                controller: _controller,
                decoration: FormInputDecoration.getDeco(hintText: "MO"),
                onFieldSubmitted: (mo) {
                  _controller.clear();
                  FocusScope.of(context).requestFocus(moNode);
                  setState(() {
                    ticketList.add(mo);
                  });
                }),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                String t = ticketList[index];
                return ListTile(title: Text(t));
              },
              itemCount: ticketList.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 0);
              },
            ),
          ),
          TextFormField(
            decoration: FormInputDecoration.getDeco(hintText: "Comment"),
            keyboardType: TextInputType.multiline,
            maxLines: 8,
            onChanged: (c) {
              comment = c;
            },
          ),
          if (ticketList.isNotEmpty || _controller.text.isNotEmpty)
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        ticketList.add(_controller.text);
                      }
                      receiveKits();
                    },
                    icon: const Icon(Icons.call_received_outlined),
                    label: const Text("Receive")))
        ]),
      ),
    );
  }

  getUi() {}

  void receiveKits() {
    Api.post(EndPoints.materialManagement_kit_receiveKits, {'mos': ticketList, "comment": comment}).then((res) {
      setState(() {
        print('xxxxxxxxx');
      });
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
