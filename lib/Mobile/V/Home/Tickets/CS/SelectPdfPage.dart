import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:smartwind/M/Ticket.dart';

class SelectPdfPage extends StatefulWidget {
  final Ticket ticket;

  final onPageSelect;

  const SelectPdfPage(this.ticket, this.onPageSelect);

  @override
  _SelectPdfPageState createState() => _SelectPdfPageState();
}

class _SelectPdfPageState extends State<SelectPdfPage> {
  late Ticket ticket;
  var OnPageSelect;
  String? errorMessage;

  @override
  initState() {
    super.initState();
    ticket = widget.ticket;
    OnPageSelect = widget.onPageSelect;
  }

  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Page"), centerTitle: true),
      floatingActionButton: FutureBuilder(
        future: _controller.future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              icon: const Icon(Icons.touch_app_rounded),
              label: const Text("Select Current Page"),
              onPressed: () async {
                await selectCurrentPage().then((value) {
                  print("ddddddddddddddddddddddddd == $value");
                  OnPageSelect(value);
                });

                setState(() {});
              },
            );
          }

          return Container();
        },
      ),
      body: PDFView(
        filePath: ticket.ticketFile!.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        defaultPage: 0,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
        onRender: (_pages) {},
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
      ),
    );
  }

  static const platform = MethodChannel('editPdf');

  Future selectCurrentPage() async {
    return await platform.invokeMethod('splitPage', {'path': ticket.ticketFile!.path, 'page': currentPage});
  }
}
