import 'package:deebugee_plugin/IfWeb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:smartwind_future_fibers/M/QC.dart';
import 'package:deebugee_plugin/DialogView.dart';

import '../../../res.dart';

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

  Uint8List? _data;

  bool isPass = false;

  @override
  void initState() {
    selectedQc = widget.qc;
    isPass = selectedQc.quality?.toLowerCase() == 'qc pass';

    if (selectedQc.quality?.toLowerCase() != 'qc pass') {
      selectedQc.getFile(context).then((value) async {
        _pdfLoading = false;
        _data = value;
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  dynamic getWebUi() {
    return getUi();
  }

  Scaffold getUi() {
    return Scaffold(
        appBar: AppBar(title: Text("${selectedQc.ticket?.mo}")),
        body: isPass
            ? Center(child: Image.asset(Res.qc_passed_sticket))
            : _pdfLoading
                ? const Center(child: CircularProgressIndicator())
                : _data == null
                    ? const Text("No Data")
                    : PdfViewer.openData(_data!, params: const PdfViewerParams()));
  }
}
