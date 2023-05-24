import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';

import '../../../../C/Api.dart';
import '../../../../M/Ticket.dart';

class AddTicket extends StatefulWidget {
  final String name;

  const AddTicket(this.name, {Key? key}) : super(key: key);

  @override
  State<AddTicket> createState() => _AddTicketState();

  Future<Ticket?> show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddTicketState extends State<AddTicket> {
  TextEditingController searchController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  get isMo => searchController.value.text.trim().toLowerCase().startsWith("mo");

  @override
  void initState() {
    super.initState();
    searchController.text = (widget.name).toUpperCase();
  }

  @override
  Widget build(BuildContext _context) {
    return IfWeb(elseIf: getUi(_context), child: DialogView(child: getWebUi(_context), width: 400, height: 200));
  }

  var focusNode = FocusNode();

  getWebUi(_context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Add Ticket')),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
                inputFormatters: [UpperCaseTextFormatter()],
                textCapitalization: TextCapitalization.characters,
                focusNode: focusNode,
                autofocus: true,
                controller: searchController,
                onChanged: (text) {},
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    // suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: searchController.clear),
                    // border: InputBorder.none,
                    // focusedBorder: InputBorder.none,
                    // enabledBorder: InputBorder.none,
                    // errorBorder: InputBorder.none,
                    // disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 10, right: 15),
                    hintText: "Ticket")),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                    onPressed: () {
                      saveTicket(_context);
                    },
                    child: const Text("Add")),
              ),
            )
          ],
        ),
      )),
    );
  }

  getUi(_context) {
    return getWebUi(_context);
  }

  void saveTicket(_context) {
    ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
        content: Text("Add new ticket with  ${isMo ? "MO" : 'Item Number'}"),
        action: SnackBarAction(
            label: 'Save',
            onPressed: () {
              Api.post(EndPoints.tickets_addTicket, {'name': searchController.value.text}).then((res) {
                Map data = res.data;
                print(data);
                if (data['ticket'] != null) {
                  Navigator.pop(context, Ticket.fromJson(data['ticket']));
                }
              }).whenComplete(() {
                setState(() {});
              }).catchError((err) {
                ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
                    content: Text(err.toString()),
                    action: SnackBarAction(
                        label: 'Retry',
                        onPressed: () {
                          saveTicket(_context);
                        })));
                setState(() {
                  // _dataLoadingError = true;
                });
              });
            })));
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
