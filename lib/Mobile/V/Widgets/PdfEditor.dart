import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:smartwind/M/Ticket.dart';

class PdfEditor extends StatefulWidget {
  final Ticket ticket;

  const PdfEditor(this.ticket, {super.key});

  @override
  _PdfEditorState createState() {
    return _PdfEditorState();
  }
}

class _PdfEditorState extends State<PdfEditor> {
  late PDFView ppp;

  @override
  void initState() {
    super.initState();

    ppp = PDFView(
      filePath: widget.ticket.ticketFile!.path,
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
          title: Text("${widget.ticket.mo ?? widget.ticket.oe ?? ""} ${widget.ticket.mo != null ? "(${widget.ticket.oe})" : ""}  ", style: const TextStyle(color: Colors.white)),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                await Ticket.sharePdf(context, widget.ticket);
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            ppp,
            // if (errorMessage.isEmpty)Center(
            //   child: Text(errorMessage),
            // ),
            // if(!isReady)

            errorMessage.isEmpty
                ? ((!isReady)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container())
                : Center(
                    child: Text(errorMessage),
                  )
          ],
        )
        // ,
        // floatingActionButton: FutureBuilder<PDFViewController>(
        //   future: _controller.future,
        //   builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
        //     if (snapshot.hasData) {
        //       // return FloatingActionButton.extended(
        //       //   label: Text("Go to ${pages ~/ 2}"),
        //       //   onPressed: () async {
        //       //     await snapshot.data.setPage(pages ~/ 2);
        //       //   },
        //       // );
        //
        //       return FloatingActionButton.extended(
        //         icon: Icon(Icons.edit_outlined),
        //         label: Text("Edit"),
        //         onPressed: () async {
        //           await widget.ticket.openEditor();
        //           await DB.updateDatabase(  context, showLoadingDialog: true);
        //           Navigator.pop(context, true);
        //         },
        //       );
        //     }
        //
        //     return Container();
        //   },
        // )
        );
  }
}
