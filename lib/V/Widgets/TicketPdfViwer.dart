import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
// import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/BlueBook/BlueBook.dart';

import '../../M/AppUser.dart';
import '../Home/Tickets/ProductionPool/Finish/FinishCheckList.dart';

class TicketPdfViewer extends StatefulWidget {
  final Ticket ticket;
  final onClickEdit;

  const TicketPdfViewer(this.ticket, {Key? key, required this.onClickEdit}) : super(key: key);

  @override
  TicketPdfViewerState createState() {
    return TicketPdfViewerState();
  }

  Future show(context) {
    return Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class TicketPdfViewerState extends State<TicketPdfViewer> {
  var pdfPath;
  late PdfController pdfController;

  late PdfControllerPinch pdfPinchController;

  bool _loading = false;

  Widget pdfView() => PdfViewPinch(controller: pdfPinchController, padding: 10, scrollDirection: Axis.vertical);

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void dispose() {
    print('dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd');
    pdfPinchController.dispose();
    super.dispose();
  }

  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.ticket.mo ?? widget.ticket.oe ?? ""} ${widget.ticket.mo != null ? "(${widget.ticket.oe})" : ""}  ", style: const TextStyle(color: Colors.white)),
          actions: <Widget>[
            if (!widget.ticket.isStandard)
              PopupMenuButton<ActionMenuItems>(
                onSelected: (ActionMenuItems s) async {
                  if (s == ActionMenuItems.CS) {
                    widget.ticket.openInCS(context);
                  } else if (s == ActionMenuItems.ShippingSystem) {
                    widget.ticket.openInShippingSystem(context);
                  } else if (s == ActionMenuItems.BlueBook) {
                    var data = await Navigator.push(context, MaterialPageRoute(builder: (context) => BlueBook(ticket: widget.ticket)));
                  } else if (s == ActionMenuItems.Share) {
                    await Ticket.sharePdf(context, widget.ticket);
                  } else if (s == ActionMenuItems.Finish) {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return FinishCheckList(widget.ticket);
                        });
                    if (mounted) {
                      int count = 0;
                      Navigator.popUntil(context, (route) {
                        return count++ == 2;
                      });
                      //   await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ProductionPool()), (Route<dynamic> route) => route.isFirst);
                    }
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {
                    {'action': ActionMenuItems.Share, 'icon': Icons.share, 'text': "Share", "color": Colors.redAccent},
                    {'action': ActionMenuItems.BlueBook, 'icon': Icons.menu_book_rounded, 'text': "Blue Book", "color": Colors.blueAccent},
                    {'action': ActionMenuItems.ShippingSystem, 'icon': Icons.directions_boat_rounded, 'text': "Shipping System", "color": Colors.brown},
                    {'action': ActionMenuItems.CS, 'icon': Icons.pivot_table_chart_rounded, 'text': "CS", "color": Colors.green},
                    if (widget.ticket.isStarted && (widget.ticket.nowAt == AppUser.getSelectedSection()?.id) && AppUser.havePermissionFor(Permissions.FINISH_TICKET) && (!kIsWeb))
                      {'action': ActionMenuItems.Finish, 'icon': Icons.check_circle_outline_outlined, 'text': "Finish", "color": Colors.green}
                  }.map((choice) {
                    return PopupMenuItem<ActionMenuItems>(
                      value: (choice["action"] as ActionMenuItems),
                      child: Wrap(
                        children: [
                          Icon(choice["icon"] as IconData, color: choice["color"] as Color),
                          Padding(padding: const EdgeInsets.only(top: 4.0, left: 8), child: Text(choice["text"].toString()))
                        ],
                      ),
                    );
                  }).toList();
                },
              )
          ],
        ),
        body: Stack(children: <Widget>[
          if (!_loading) pdfView(),
          if (_loading) const Center(child: CircularProgressIndicator()),
          errorMessage.isEmpty ? ((!isReady) ? Container() : Container()) : Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
        ]),
        floatingActionButton: (widget.ticket.isNotCompleted && (AppUser.havePermissionFor(Permissions.EDIT_ANY_PDF)) && (widget.ticket.isStarted))
            ? FloatingActionButton.extended(
                icon: const Icon(Icons.edit_outlined),
                label: Text("Edit ${widget.ticket.completed}"),
                onPressed: () async {
                  widget.onClickEdit();
                })
            : null);
  }

  void setLoading(bool bool) {
    setState(() {
      _loading = bool;
    });
  }

  void reload() {
    setLoading(true);
    pdfPath = widget.ticket.ticketFile!.path;
    pdfController = PdfController(document: PdfDocument.openFile(pdfPath));
    pdfPinchController = PdfControllerPinch(document: PdfDocument.openFile(pdfPath));
    setLoading(false);
  }

  void close() {
    Navigator.of(context).pop();
  }
}
