import 'package:deebugee_plugin/IfWeb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:universal_html/html.dart' as html;

import '../../../M/QC.dart';
import '../../../Mobile/V/Home/Tickets/QC/TimeCardView.dart';
import '../../../res.dart';

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

  var isPass;

  @override
  void initState() {
    isPass = widget.qc.quality?.toLowerCase() == 'qc pass';

    if (widget.qc.quality?.toLowerCase() != 'qc pass') {
      widget.qc.getFile(context).then((value) async {
        _data = value;
        _pdfLoading = false;
        setState(() {});
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getUi()));
  }

  Scaffold getUi() {
    return Scaffold(
        floatingActionButton: FloatingActionButton.small(
            onPressed: () {
              TimeCardView(widget.qc.id).show(context);
            },
            child: const Icon(Icons.av_timer_rounded)),
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
        body: isPass
            ? Center(child: Image.asset(Res.qc_passed_sticket))
            : _pdfLoading
                ? const Center(child: CircularProgressIndicator())
                : PdfViewer.openData(
                    _data,
                    params: const PdfViewerParams(),
                  ));
  }
}
