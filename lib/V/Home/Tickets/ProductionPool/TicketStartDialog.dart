import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';

import '../../../../M/Ticket.dart';
import '../TicketInfo/TicketInfo.dart';

class TicketStartDialog extends StatefulWidget {
  final Ticket ticket;

  const TicketStartDialog(this.ticket, {Key? key}) : super(key: key);

  @override
  State<TicketStartDialog> createState() => _TicketStartDialogState();

  Future show(context) {
    return showDialog(context: context, builder: (_) => this);
  }
}

class _TicketStartDialogState extends State<TicketStartDialog> {
  late Ticket ticket;

  bool loading = false;

  @override
  void initState() {
    ticket = widget.ticket;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return DialogView(child: getUi(), width: width > 500 ? 500 : width - 100, height: 200);
  }

  getUi() {
    return Scaffold(
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [const Text("Do you really want to start production ?", textScaleFactor: 1.5), Text("  ${ticket.mo}"), Text("  ${ticket.oe}")],
                ),
              ),
        bottomNavigationBar: loading
            ? null
            : BottomAppBar(
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.end, children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"))),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            loading = true;
                          });
                          await ticket.start(context);
                          ticket.isStarted = true;
                          ticket.save();
                          Navigator.of(context).pop();
                          TicketInfo(ticket).show(context);
                        },
                        child: const Text("Start")))
              ])));
  }
}
