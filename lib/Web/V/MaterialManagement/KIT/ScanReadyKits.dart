import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';

import '../../../../C/Api.dart';
import '../../../../C/form_input_decoration.dart';
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
    return IfWeb(elseIf: getUi(), child: DialogView(width: 300, height: 500, child: getWebUi()));
  }

  List<Ticket> ticketList = [];

  getWebUi() {
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
                    trailing: t.loading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 1))
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

  getUi() {}

  void send(Ticket t) {
    Api.post(EndPoints.materialManagement_kit_readyKit, {'mo': t.mo}).then((res) {
      Map data = res.data;
      setState(() {
        t.loading = false;
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
