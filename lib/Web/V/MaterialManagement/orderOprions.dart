import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../C/Api.dart';
import '../../../M/CPR/CPR.dart';
import '../../../M/EndPoints.dart';
import '../../../M/Ticket.dart';
import '../../../Mobile/V/Widgets/UserButton.dart';
import '../../Widgets/ShowMessage.dart';

class OrderTypeSelector extends StatefulWidget {
  final CPR? cpr;
  final Ticket? ticket;
  final Function reload;
  final CprType type;

  const OrderTypeSelector(this.type, this.cpr, this.ticket, this.reload, {Key? key}) : super(key: key);

  @override
  State<OrderTypeSelector> createState() => _OrderTypeSelectorState();
}

class _OrderTypeSelectorState extends State<OrderTypeSelector> {
  CPR? cpr;
  Ticket? ticket;
  late Function reload;
  bool loading = true;

  get textColors => {'Urgent': Colors.red, 'Normal': Colors.green};

  @override
  void initState() {
    cpr = widget.cpr;
    ticket = widget.ticket;
    reload = widget.reload;

    loadDate();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isUrgent = cprStatus?['status'] == 'Urgent';
    bool isNormal = cprStatus?['status'] == 'Normal';
    bool isRemoved = cprStatus?['status'] == null;

    return Container(
      decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
      height: 400,
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ListTile(title: Text(ticket?.mo ?? ticket?.oe ?? ''), subtitle: Text(ticket?.oe ?? '')),
          const Divider(),
          if (cprStatus != null) ...[
            ListTile(
                title: UserButton(nsUserId: cprStatus?['userId']),
                trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  isRemoved
                      ? const Text('Order Status Reset', style: TextStyle(color: Colors.grey))
                      : Text('${cprStatus?['status']}', style: TextStyle(color: textColors['${cprStatus?['status']}'])),
                  Text('${cprStatus?['insertAt']}', style: const TextStyle(fontSize: 12, color: Colors.grey))
                ])),
            const Divider(),
          ],
          loading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                  ListTile(
                      title: const Text("Urgent", style: TextStyle(color: Colors.red)),
                      leading: const Icon(Icons.do_not_disturb_on_total_silence, color: Colors.red),
                      trailing: isUrgent ? const Icon(Icons.check, color: Colors.red) : null,
                      onTap: () async {
                        Navigator.of(context).pop();

                        cpr == null ? orderByTicket(context, ticket, isUrgent ? -1 : 1, reload) : order(context, cpr, isUrgent ? -1 : 1, reload);
                      }),
                  ListTile(
                      title: const Text("Normal", style: TextStyle(color: Colors.green)),
                      leading: const Icon(Icons.do_not_disturb_on_total_silence, color: Colors.green),
                      trailing: isNormal ? const Icon(Icons.check, color: Colors.green) : null,
                      onTap: () async {
                        Navigator.of(context).pop();
                        cpr == null ? orderByTicket(context, ticket, isNormal ? -1 : 0, reload) : order(context, cpr, isNormal ? -1 : 0, reload);
                      })
                ])))
        ],
      ),
    );
  }

  Map? cprStatus;

  void loadDate() {
    Api.get(EndPoints.materialManagement_getOrderStatus, {'ticketId': cpr?.ticket?.id ?? ticket?.id, 'type': widget.type.getValue()}).then((res) {
      Map data = res.data;
      cprStatus = data['status'];
      print(data);
    }).whenComplete(() {
      setState(() => {loading = false});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {loadDate()})));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}

Future<void> showOrderOptions(CprType type, CPR? cpr, Ticket? ticket, BuildContext context1, BuildContext context, reload) async {
  await showModalBottomSheet<void>(
    constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
    context: context,
    builder: (BuildContext context) {
      return OrderTypeSelector(type, cpr, ticket, reload);
    },
  );
}

enum CprType { kit, cpr }

extension CprTypeExt on CprType {
  String getValue() {
    return (this).toString().split('.').last.replaceAll('_', " ").trim();
  }
}

void orderByTicket(context, Ticket? ticket, int i, reload) {
  ShowMessage('Saving', messageType: MessageTypes.message, icon: Icons.save);

  Api.post(EndPoints.materialManagement_orderKitByTicketId, {'ticketId': ticket?.id, 'type': i})
      .then((res) {
        Map data = res.data;
        ShowMessage('Saved', messageType: MessageTypes.success, icon: Icons.save);
        reload();
      })
      .whenComplete(() {})
      .catchError((err) {
        ShowMessage('Something went wrong',
            duration: const Duration(seconds: 30),
            messageType: MessageTypes.error,
            icon: Icons.error,
            closeButton: true,
            action: SnackBarAction(
                label: "Retry",
                textColor: Colors.white,
                onPressed: () {
                  orderByTicket(context, ticket, i, reload);
                }));
      });
}

void order(context, CPR? cpr, int i, reload) {
  ShowMessage('Saving', messageType: MessageTypes.message, icon: Icons.save);

  Api.post(EndPoints.materialManagement_order, {'cprId': cpr?.id, 'type': i})
      .then((res) {
        ShowMessage('Saved', messageType: MessageTypes.success, icon: Icons.save);
        reload();
      })
      .whenComplete(() {})
      .catchError((err) {
        ShowMessage('Something went wrong',
            duration: const Duration(seconds: 30),
            messageType: MessageTypes.error,
            icon: Icons.error,
            closeButton: true,
            action: SnackBarAction(
                label: "Retry",
                textColor: Colors.white,
                onPressed: () {
                  order(context, cpr, i, reload);
                }));
      });
}
