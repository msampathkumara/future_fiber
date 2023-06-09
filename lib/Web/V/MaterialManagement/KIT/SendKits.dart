import 'package:deebugee_plugin/DialogView.dart';
import 'package:deebugee_plugin/IfWeb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../C/Api.dart';
import '../../../../C/form_input_decoration.dart';
import '../../../../M/CPR/KIT.dart';
import '../../../../M/EndPoints.dart';
import '../../../../M/Ticket.dart';

class SendKits extends StatefulWidget {
  final Map<int, KIT> selectedList;

  const SendKits(this.selectedList, {Key? key}) : super(key: key);

  @override
  State<SendKits> createState() => _SendKitsState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _SendKitsState extends State<SendKits> {
  String comment = "";

  var moNode = FocusNode();

  bool loading = false;
  List<String> ticketList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.selectedList.forEach((key, value) {
      ticketList.add(value.ticket!.mo ?? value.ticket!.oe!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 500, child: getWebUi()));
  }

  final TextEditingController _controller = TextEditingController();

  Scaffold getWebUi() {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Kits')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                return const Divider(
                  height: 0,
                );
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
                            sendKits();
                          },
                          icon: const Icon(Icons.send),
                          label: const Text("Send")))
              ]),
            ),
    );
  }

  getUi() {
    return Text("NOT WEB");
  }

  // void send(Ticket t) {
  //   Api.post(EndPoints.materialManagement_kit_sendKit, {'mo': t.mo}).then((res) {
  //     setState(() {
  //       t.loading = false;
  //       print('xxxxxxxxx');
  //     });
  //   }).whenComplete(() {
  //     setState(() {});
  //   }).catchError((err) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
  //     setState(() {
  //       // _dataLoadingError = true;
  //     });
  //   });
  // }

  void sendKits() {
    setState(() => {loading = true});
    Api.post(EndPoints.materialManagement_kit_sendKits, {'mos': ticketList, "comment": comment}).then((res) {
      Navigator.of(context).pop();
    }).whenComplete(() {
      setState(() => {loading = false});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
