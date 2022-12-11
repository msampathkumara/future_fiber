import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

// import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/Mobile/V/Home/BlueBook/BlueBook.dart';

import '../../../M/AppUser.dart';
import '../../../M/PermissionsEnum.dart';
import '../Home/Tickets/ProductionPool/Finish/FinishCheckList.dart';
import '../Home/Tickets/TicketInfo/TicketInfo.dart';

class TicketPdfViewer extends StatefulWidget {
  final Ticket ticket;
  final Function onClickEdit;

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
  String? pdfPath;

  bool _loading = false;

  String pageString = '';

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void dispose() {
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
          title: Row(
            children: [
              Text("${widget.ticket.mo ?? widget.ticket.oe ?? ""} ${widget.ticket.mo != null ? "(${widget.ticket.oe})" : ""}  ", style: const TextStyle(color: Colors.white)),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(pageString, textScaleFactor: 0.8),
              )
            ],
          ),
          actions: <Widget>[
            if (!widget.ticket.isStandard)
              PopupMenuButton<ActionMenuItems>(
                onSelected: (ActionMenuItems s) async {
                  if (s == ActionMenuItems.CS) {
                    widget.ticket.openInCS(context);
                  } else if (s == ActionMenuItems.ShippingSystem) {
                    widget.ticket.openInShippingSystem(context);
                  } else if (s == ActionMenuItems.BlueBook) {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => BlueBook(ticket: widget.ticket)));
                  } else if (s == ActionMenuItems.Share) {
                    await Ticket.sharePdf(context, widget.ticket);
                  } else if (s == ActionMenuItems.Finish) {
                    var done = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return FinishCheckList(widget.ticket);
                        });
                    if (done != null && mounted) {
                      int count = 0;
                      Navigator.popUntil(context, (route) {
                        return count++ == 2;
                      });
                      //   await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ProductionPool()), (Route<dynamic> route) => route.isFirst);
                    }
                  } else if (s == ActionMenuItems.Info) {
                    TicketInfo(widget.ticket).show(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {
                    {'action': ActionMenuItems.Share, 'icon': Icons.share, 'text': "Share", "color": Colors.redAccent},
                    {'action': ActionMenuItems.BlueBook, 'icon': Icons.menu_book_rounded, 'text': "Blue Book", "color": Colors.blueAccent},
                    {'action': ActionMenuItems.ShippingSystem, 'icon': Icons.directions_boat_rounded, 'text': "Shipping System", "color": Colors.brown},
                    {'action': ActionMenuItems.CS, 'icon': Icons.pivot_table_chart_rounded, 'text': "CS", "color": Colors.green},
                    if (widget.ticket.isStarted && widget.ticket.isNotHold && (widget.ticket.nowAt == AppUser.getSelectedSection()?.id) && (!kIsWeb))
                      {'action': ActionMenuItems.Finish, 'icon': Icons.check_circle_outline_outlined, 'text': "Finish", "color": Colors.green},
                    {'action': ActionMenuItems.Info, 'icon': Icons.info_rounded, 'text': "Product Report", "color": Colors.deepOrange}
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
          // if (!_loading) pdfView(),

          PDFView(
            filePath: widget.ticket.ticketFile!.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            fitPolicy: FitPolicy.BOTH,
            fitEachPage: true,
            pageSnap: true,
            onRender: (_pages) {
              setState(() {
                pages = _pages!;
                isReady = true;
              });
            },
            onError: (error) {
              print(error.toString());
            },
            onPageError: (page, error) {
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {},
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              pageString = '${((page ?? 0) + 1)}/$total';
              setState(() {});
            },
          ),

          if (_loading) const Center(child: CircularProgressIndicator()),
          errorMessage.isEmpty ? ((!isReady) ? Container() : Container()) : Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
        ]),
        floatingActionButton: ((!widget.ticket.isStandard) &&
                    (widget.ticket.isNotCompleted &&
                        (AppUser.havePermissionFor(NsPermissions.TICKET_EDIT_ANY_PDF) || (widget.ticket.isStarted && widget.ticket.nowAt == AppUser.getSelectedSection()?.id)))) ||
                (widget.ticket.isStandard && AppUser.havePermissionFor(NsPermissions.STANDARD_FILES_EDIT_STANDARD_FILES))
            ? FloatingActionButton.extended(
                icon: const Icon(Icons.edit_outlined),
                label: const Text("Edit"),
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
    // pdfController = PdfController(document: PdfDocument.openFile(pdfPath));
    // pdfPinchController = PdfControllerPinch(document: PdfDocument.openFile(pdfPath));
    setLoading(false);
  }

  void close() {
    Navigator.of(context).pop();
  }
}
