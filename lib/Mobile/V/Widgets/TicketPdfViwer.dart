import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

// import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';
import 'package:smartwind_future_fibers/Mobile/V/Home/BlueBook/BlueBook.dart';

import '../../../M/AppUser.dart';
import '../../../M/PermissionsEnum.dart';
import '../Home/Tickets/ProductionPool/Finish/FinishCheckList.dart';
import '../Home/Tickets/TicketInfo/TicketInfo.dart';

class TicketPdfViewer extends StatefulWidget {
  final Ticket ticket;
  final Function onClickEdit;

  final bool isPreCompleted;

  const TicketPdfViewer(this.ticket, {Key? key, required this.onClickEdit, this.isPreCompleted = false}) : super(key: key);

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
            if (!widget.ticket.isStandardFile)
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
        floatingActionButton: getEditButton());
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

  // Widget? getEditButton() {
  //   print('widget. isPreCompleted ===== ${widget.isPreCompleted}');
  //
  //   if (widget.ticket.isStandardFile) {
  //     if ((widget.ticket.isStandardFile && AppUser.havePermissionFor(NsPermissions.STANDARD_FILES_EDIT_STANDARD_FILES))) {
  //       return _editButton;
  //     }
  //     return null;
  //   } else {
  //     if (widget.ticket.isCompleted && (AppUser.havePermissionFor(NsPermissions.TICKET_EDIT_FINISHED_TICKET))) {
  //       return _editButton;
  //     }
  //     if (widget.ticket.isCompleted) {
  //       return null;
  //     }
  //     if (AppUser.havePermissionFor(NsPermissions.TICKET_EDIT_ANY_PDF)) {
  //       return _editButton;
  //     }
  //
  //     if (widget.ticket.isStarted && widget.ticket.nowAt == AppUser.getSelectedSection()?.id) {
  //       return _editButton;
  //     }
  //     if (widget.isPreCompleted) {
  //       return _editButton;
  //     }
  //     return null;
  //   }
  // }

  Widget? getEditButton() {
    print('widget. isPreCompleted ===== ${widget.isPreCompleted}');

    // Check if the ticket is a standard file and the user has permission to edit it
    if (widget.ticket.isStandardFile && AppUser.havePermissionFor(NsPermissions.STANDARD_FILES_EDIT_STANDARD_FILES)) {
      return _editButton;
    }

    // Check if the ticket is completed and the user has permission to edit it
    if (widget.ticket.isCompleted && AppUser.havePermissionFor(NsPermissions.TICKET_EDIT_FINISHED_TICKET)) {
      return _editButton;
    }

    // Check if the user has permission to edit any PDF
    if (AppUser.havePermissionFor(NsPermissions.TICKET_EDIT_ANY_PDF)) {
      return _editButton;
    }

    // Check if the ticket is started and assigned to the user's section or pre-completed
    if ((widget.ticket.isStarted && widget.ticket.nowAt == AppUser.getSelectedSection()?.id) || widget.isPreCompleted) {
      return _editButton;
    }

    // Return null otherwise
    return null;
  }

  get _editButton => FloatingActionButton.extended(
      icon: const Icon(Icons.edit_outlined),
      label: const Text("Edit"),
      onPressed: () async {
        widget.onClickEdit();
      });
}
