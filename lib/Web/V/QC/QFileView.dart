import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:smartwind/M/QC.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

class QFileView extends StatefulWidget {
  final QC qc;

  const QFileView(this.qc, {Key? key}) : super(key: key);

  @override
  State<QFileView> createState() => _QFileViewState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _QFileViewState extends State<QFileView> {
  List<QC> qcList = [];
  late QC selectedQc;
  bool _pdfLoading = true;

  var _data;

  @override
  void initState() {
    selectedQc = widget.qc;

    selectedQc.getFile(context).then((value) async {
      _pdfLoading = false;
      _data = value;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  getWebUi() {
    return getUi();
  }

  getUi() {
    return Scaffold(
        appBar: AppBar(title: Text("${selectedQc.ticket?.mo}")),
        body: _pdfLoading
            ? const Center(child: CircularProgressIndicator())
            : _data == null
                ? const Text("No Data")
                : PdfViewer.openData(_data, params: const PdfViewerParams()));
  }
}
