import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';
import 'package:pdfx/pdfx.dart';

import '../../../M/Ticket.dart';
import 'SavePageAsPdf.dart';

class TicketPageSelector extends StatefulWidget {
  final Ticket ticket;

  const TicketPageSelector(this.ticket, {Key? key}) : super(key: key);

  @override
  State<TicketPageSelector> createState() => _TicketPageSelectorState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _TicketPageSelectorState extends State<TicketPageSelector> {
  late Ticket ticket;

  bool _pdfLoading = true;

  var _data;
  late PdfController pdfController;

  var page = 1;

  @override
  void initState() {
    ticket = widget.ticket;

    Ticket.getFileAsData(ticket, context).then((value) async {
      _data = value;
      _pdfLoading = false;
      // PdfDocument.openData(_data);
      pdfController = PdfController(document: PdfDocument.openData(_data));
      setState(() {});
    });
    // pdfController = PdfController(
    //   document: PdfDocument.openAsset('assets/sample.pdf'),
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  getWebUi() {
    return Scaffold(
        appBar: AppBar(title: ListTile(title: Text("${ticket.mo}"), subtitle: Wrap(children: [Text("${ticket.oe}")]), textColor: Colors.white), actions: [
          if (!_pdfLoading)
            PdfPageNumber(
                controller: pdfController,
                builder: (_, state, loadingState, pagesCount) => Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text('$page/${pagesCount ?? 0}'),
                    )))
        ]),
        backgroundColor: Colors.white,
        body: _pdfLoading
            ? const Center(child: CircularProgressIndicator())
            // : PdfViewer.openData(
            //     _data,
            //     params: const PdfViewerParams(),
            //   )
            : Column(
                children: [
                  Expanded(
                    child: PdfView(
                        renderer: (PdfPage page) => page.render(
                              width: page.width * 1,
                              height: page.height * 1,
                              format: PdfPageImageFormat.jpeg,
                              backgroundColor: '#FFFFFF',
                            ),
                        pageSnapping: false,
                        scrollDirection: Axis.vertical,
                        controller: pdfController,
                        onPageChanged: (p) {
                          print('xxxxxxxxxxxxxxxxxxxxxxx ${p}');
                          page = p;
                          setState(() {});
                        },
                        onDocumentLoaded: (document) {
                          print('xxxxxxxxxxxxxxxxxxxxxxx ${document.pagesCount}');
                          setState(() {});
                        }),
                  )
                ],
              ),
        bottomNavigationBar: BottomAppBar(
            elevation: 2,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 4),
                  child: ElevatedButton.icon(
                      onPressed: () {
                        pdfController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
                      },
                      icon: const Icon(Icons.navigate_before_rounded),
                      label: const Text("Previous Page")),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 4),
                  child: ElevatedButton.icon(
                      onPressed: () {
                        pdfController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
                      },
                      icon: const Icon(Icons.navigate_next_rounded),
                      label: const Text("Next Page")),
                )
              ],
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.pink,
            onPressed: () async {
              SavePageAsPdf.save(_data, page, (ticket.mo ?? ticket.oe));
            },
            label: Text("Select Page $page")));
  }

  getUi() {
    return getWebUi();
  }

// File createFileFromBytes(Uint8List bytes) => File.fromRawPath(bytes);
}
