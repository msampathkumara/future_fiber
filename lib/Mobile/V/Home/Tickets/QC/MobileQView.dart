import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';

import '../../../../../M/QC.dart';
import '../../../Widgets/UserImage.dart';

class MobileQView extends StatefulWidget {
  final QC qc;

  const MobileQView(this.qc, {Key? key}) : super(key: key);

  @override
  State<MobileQView> createState() => _MobileQViewState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _MobileQViewState extends State<MobileQView> {
  bool _pdfLoading = true;

  var _data;

  late QC qc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _pdfLoading = true;
    qc = widget.qc;

    setState(() {});
    widget.qc.getFile(context).then((value) async {
      _pdfLoading = false;
      setState(() {});
      _data = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  getWebUi() {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 100,
          title: Row(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.qc.ticket?.mo}'),
                Text('${widget.qc.ticket?.oe}', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              UserImage(nsUser: widget.qc.user, radius: 16, padding: 2),
              Text("${qc.user?.uname}", style: const TextStyle(fontSize: 16)),
              Text("${qc.getSection()?.sectionTitle} @ ${qc.getSection()?.factory}", style: const TextStyle(fontSize: 16)),
              Text(qc.getDateTime(), style: const TextStyle(fontSize: 12))
            ])
          ])),
      body: _pdfLoading ? const Center(child: CircularProgressIndicator()) : PdfViewer.openData(_data, params: const PdfViewerParams()),
    );
  }

  getUi() {
    return getWebUi();
  }
}
