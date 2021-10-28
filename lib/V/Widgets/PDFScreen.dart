import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/BlueBook/BlueBook.dart';
import 'package:smartwind/V/Home/Tickets/ProductionPool/Finish/FinishCheckList.dart';

class PDFScreen extends StatefulWidget {
  // String pathPDF = "";
  // int fileID = 0;
  final Ticket ticket;

  PDFScreen(this.ticket);

  @override
  _PDFScreenState createState() {
    return _PDFScreenState();
  }
}

class _PDFScreenState extends State<PDFScreen> {
  var pdfPath;

  var pdfView;

  @override
  void initState() {
    super.initState();
    pdfPath = widget.ticket.ticketFile!.path;

    pdfView=   new PDFView(
      filePath: pdfPath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      defaultPage: currentPage,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (_pages) {
        setState(() {
          pages = _pages!;
          isReady = true;
          print('READYYYY');
        });
      },
      onError: (error) {
        setState(() {
          errorMessage = error.toString();
        });
        print(error.toString());
      },
      onPageError: (page, error) {
        setState(() {
          errorMessage = '$page: ${error.toString()}';
        });
        print('$page: ${error.toString()}');
      },
      onViewCreated: (PDFViewController pdfViewController) {
        _controller.complete(pdfViewController);
      },
      onLinkHandler: (String? uri) {
        print('goto uri: $uri');
      },
      onPageChanged: (int? page, int? total) {
        print('page change: $page/$total');
        setState(() {
          currentPage = page!;
        });
      },
    );
  }


  @override
  void dispose() {
    super.dispose();
  }

  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.ticket.mo ?? widget.ticket.oe ?? "") + " ${widget.ticket.mo != null ? "(${widget.ticket.oe})" : ""}  ", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.share),
          //   onPressed: () async {
          //     await widget.ticket.sharePdf(context);
          //   },
          // ),
          PopupMenuButton<ActionMenuItems>(
            onSelected: (ActionMenuItems s) async {
              if (s == ActionMenuItems.CS) {
                widget.ticket.openInCS(context);
              } else if (s == ActionMenuItems.ShippingSystem) {
                widget.ticket.openInShippingSystem(context);
              } else if (s == ActionMenuItems.BlueBook) {
                var data = await Navigator.push(context, MaterialPageRoute(builder: (context) => BlueBook(ticket: widget.ticket)));
              } else if (s == ActionMenuItems.Share) {

                await widget.ticket.sharePdf(context);

              } else if (s == ActionMenuItems.Finish) {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return FinishCheckList(widget.ticket);
                    });
              }
            },
            itemBuilder: (BuildContext context) {
              return {
                {'action': ActionMenuItems.Share, 'icon': Icons.share, 'text': "Share", "color": Colors.redAccent},
                {'action': ActionMenuItems.BlueBook, 'icon': Icons.menu_book_rounded, 'text': "Blue Book", "color": Colors.blueAccent},
                {'action': ActionMenuItems.ShippingSystem, 'icon': Icons.directions_boat_rounded, 'text': "Shipping System", "color": Colors.brown},
                {'action': ActionMenuItems.CS, 'icon': Icons.pivot_table_chart_rounded, 'text': "CS", "color": Colors.green},
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
      body: Container(
        child: Stack(
          children: <Widget>[
            pdfView,
            // if (errorMessage.isEmpty)Center(
            //   child: Text(errorMessage),
            // ),
            // if(!isReady)

            errorMessage.isEmpty
                ? ((!isReady)
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container())
                : Center(
                    child: Text(errorMessage),
                  )
          ],
        ),
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            // return FloatingActionButton.extended(
            //   label: Text("Go to ${pages ~/ 2}"),
            //   onPressed: () async {
            //     await snapshot.data.setPage(pages ~/ 2);
            //   },
            // );

            return FloatingActionButton.extended(
              icon: Icon(Icons.edit_outlined),
              label: Text("Edit"),
              onPressed: () async {
                print('EDIT CLICK');

                await widget.ticket.openEditor();
                await DB.updateDatabase(context, showLoadingDialog: true);
                Navigator.pop(context, true);
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
