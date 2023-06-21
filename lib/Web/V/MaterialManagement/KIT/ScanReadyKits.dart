import 'package:deebugee_plugin/DialogView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../C/Api.dart';
import '../../../../C/form_input_decoration.dart';
import '../../../../M/EndPoints.dart';
import '../../../../M/Ticket.dart';

class ScanReadyKits extends StatefulWidget {
  const ScanReadyKits({Key? key}) : super(key: key);

  @override
  State<ScanReadyKits> createState() => _ScanReadyKitsState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _ScanReadyKitsState extends State<ScanReadyKits> {
  final _controller = TextEditingController();

  var moNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return DialogView(width: 400, height: 550, child: getWebUi());
  }

  List<Ticket> ticketList = [];

  Scaffold getWebUi() {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Ready Kits')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                focusNode: moNode,
                controller: _controller,
                decoration: FormInputDecoration.getDeco(hintText: "MO"),
                onFieldSubmitted: (mo) {
                  setState(() {
                    Ticket t = Ticket();
                    t.mo = mo;
                    _controller.clear();
                    FocusScope.of(context).requestFocus(moNode);
                    t.loading = true;
                    ticketList.add(t);
                    send(t);
                  });
                }),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                Ticket t = ticketList[index];
                return ListTile(
                    title: Text("${t.mo}"),
                    subtitle: alreadyDoneList.contains(t) ? const Text("Already Done ", style: TextStyle(color: Colors.red, fontSize: 12)) : null,
                    trailing: t.loading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 1))
                        : errorList.contains(t)
                            ? InkWell(
                                onTap: () {
                                  send(t);
                                },
                                child: const Tooltip(message: 'something went wrong. Tap to retry', child: Icon(Icons.error, color: Colors.red, size: 16)))
                            : const Icon(Icons.done, color: Colors.green, size: 16));
              },
              itemCount: ticketList.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  height: 0,
                );
              },
            ),
          )
        ]),
      ),
    );
  }

  List<Ticket> alreadyDoneList = [];
  List<Ticket> errorList = [];

  void send(Ticket t) {
    setState(() => t.loading = true);
    Api.post(EndPoints.materialManagement_kit_readyKit, {'mo': t.mo}).then((res) {
      Map data = res.data;
      if (data["alreadyDone"] != null) {
        alreadyDoneList.add(t);
      }
      errorList.remove(t);
      setState(() {
        t.loading = false;
        print('xxxxxxxxx');
      });
    }).whenComplete(() {
      t.loading = false;
      setState(() {});
    }).catchError((err) {
      errorList.remove(t);
      errorList.add(t);
      print(err.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
