import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';

import '../../../C/Api.dart';
import '../../../M/NsUser.dart';
import '../../../M/TicketPrint.dart';
import '../../../V/Widgets/UserImage.dart';
import '../../Widgets/DialogView.dart';

part 'ticket_print_list.table.dart';

class TicketPrintList extends StatefulWidget {
  final Ticket ticket;

  const TicketPrintList(this.ticket, {Key? key}) : super(key: key);

  @override
  State<TicketPrintList> createState() => _TicketPrintListState();

  void show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _TicketPrintListState extends State<TicketPrintList> {
  late Ticket ticket;
  late TicketPrintDataSourceAsync _dataSource;

  @override
  void initState() {
    // TODO: implement initState
    ticket = widget.ticket;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? DialogView(child: editUserUi()) : editUserUi();
  }

  editUserUi() {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 100,
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close))],
            title: Column(
              children: [Text("${ticket.mo ?? ''}"), Text("${ticket.oe ?? ''}")],
            )),
        body: TicketPrintListTable(
            onInit: (TicketPrintDataSourceAsync dataSource) {
              _dataSource = dataSource;
            },
            onRequestData: (int page, int startingAt, int count, String sortedBy, bool sortedAsc) {
              return getData();
            },
            onTap: (TicketPrint ticketPrint) {}));
  }

  Future<DataResponse> getData() {
    return Api.get("tickets/print/getHistoryList",
            {'ticketId': widget.ticket.id, 'status': 'all', 'sortDirection': "asc", 'sortBy': 'doneOn', 'pageIndex': 0, 'pageSize': 1, 'searchText': '', 'production': 'all'})
        .then((res) {
          print(res.data);
          List ticketPrint = res.data["prints"];

          setState(() {});
          return DataResponse(ticketPrint.length, TicketPrint.fromJsonArray(ticketPrint));
        })
        .whenComplete(() {})
        .catchError((err) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(err.toString()),
              action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    getData();
                  })));
          setState(() {});
        });
  }
}
