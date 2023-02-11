import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';
import 'package:universal_html/html.dart' as html;

import '../../../M/QC.dart';

class webQView extends StatefulWidget {
  final QC qc;

  const webQView(this.qc, {Key? key}) : super(key: key);

  @override
  State<webQView> createState() => _webQViewState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _webQViewState extends State<webQView> {
  bool _pdfLoading = true;
  // PdfControllerPinch pdfPinchController = PdfControllerPinch(document: PdfDocument.openAsset('x.pdf'));
  var _data;

  @override
  void initState() {
    widget.qc.getFile(context).then((value) async {
      _data = value;
      _pdfLoading = false;
      setState(() {});
      // final document = PdfDocument.openData(value);
      // pdfPinchController.loadDocument(document);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getUi()));
  }

  // getWebUi() {
  //   return Scaffold(
  //       appBar: AppBar(),
  //       body: PdfViewPinch(
  //         controller: pdfPinchController,
  //         onDocumentError: (err) {
  //           print(err);
  //         },
  //         onDocumentLoaded: (document) {
  //           setState(() {
  //             // _allPagesCount = document.pagesCount;
  //           });
  //         },
  //         onPageChanged: (page) {
  //           setState(() {
  //             // _actualPageNumber = page;
  //           });
  //         },
  //       ));
  // }

  getUi() {
    return Scaffold(
        appBar: AppBar(title: ListTile(title: Text("${widget.qc.ticket?.mo}"), subtitle: Wrap(children: [Text("${widget.qc.ticket?.oe}")]), textColor: Colors.white), actions: [
          if (!_pdfLoading)
            IconButton(
                onPressed: () {
                  final blob = html.Blob([_data], 'application/pdf');
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  html.window.open(url, 'new tab');
                },
                icon: const Icon(Icons.open_in_new))
        ]),
        backgroundColor: Colors.white,
        body: _pdfLoading
            ? const Center(child: CircularProgressIndicator())
            : PdfViewer.openData(
                _data,
                params: const PdfViewerParams(),
              ));
  }
}
