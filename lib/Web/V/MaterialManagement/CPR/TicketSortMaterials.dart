import 'package:deebugee_plugin/DialogView.dart';
import 'package:deebugee_plugin/IfWeb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../M/NsUser.dart';
import '../../../../M/Ticket.dart';
import '../../../../Mobile/V/Widgets/UserImage.dart';

class TicketSortMaterials extends StatefulWidget {
  final Ticket ticket;

  const TicketSortMaterials(this.ticket, {Key? key}) : super(key: key);

  @override
  State<TicketSortMaterials> createState() => _TicketSortMaterialsState();

  void show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _TicketSortMaterialsState extends State<TicketSortMaterials> {
  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 1000, child: getWebUi()));
  }

  getWebUi() {
    return Scaffold(
        appBar: AppBar(title: const Text("Short Materials")),
        body: Row(
          children: [
            SizedBox(
                width: 300,
                child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, i) {
                      NsUser? nsUser = NsUser.fromId(1);

                      return ListTile(
                        leading: UserImage(nsUser: nsUser, radius: 16, padding: 0),
                        title: Text("${nsUser?.name}"),
                        subtitle: const Text("2022/04/18"),
                        onTap: () {},
                      );
                    })),
            Expanded(child: Text("${widget.ticket.id}"))
          ],
        ));
  }

  getUi() {
    return const Scaffold();
  }
}
