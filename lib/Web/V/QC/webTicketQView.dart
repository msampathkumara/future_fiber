import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/M/QC.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';
import 'package:smartwind_future_fibers/Web/V/QC/QFileView.dart';
import 'package:smartwind_future_fibers/res.dart';
import 'package:universal_html/html.dart' as html;

import '../../../C/Api.dart';
import '../../../Mobile/V/Widgets/UserImage.dart';
import 'package:deebugee_plugin/DialogView.dart';
import '../../Widgets/DialogView.dart';

class WebTicketQView extends StatefulWidget {
  final Ticket ticket;
  final bool isQc;

  const WebTicketQView(this.ticket, this.isQc, {Key? key}) : super(key: key);

  @override
  State<WebTicketQView> createState() => _WebTicketQViewState();

  void show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _WebTicketQViewState extends State<WebTicketQView> {
  late Ticket ticket;

  File? qcFile;

  var _data;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool isPass = false;

  @override
  void initState() {
    ticket = widget.ticket;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? DialogView(child: editUserUi()) : editUserUi();
  }

  List<QC> qcList = [];
  QC? selectedQc;

  bool _pdfLoading = false;

  // final Completer<WebViewController> _controller = Completer<WebViewController>();

  Scaffold editUserUi() {
    return Scaffold(
        appBar: AppBar(title: Text(ticket.mo ?? ticket.oe ?? ''), actions: [
          if (!_pdfLoading && selectedQc != null)
            IconButton(
                onPressed: () {
                  final blob = html.Blob([_data], 'application/pdf');
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  html.window.open(url, 'new tab');
                },
                icon: const Icon(Icons.open_in_new))
        ]),
        body: errMsg != null
            ? Text(errMsg!)
            : kIsWeb
                ? Row(children: [
                    SizedBox(
                      width: 300,
                      child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: () async {
                          return await apiGetData();
                        },
                        child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            QC qc = qcList[index];
                            return ListTile(
                                onTap: () async {
                                  if (!kIsWeb) {
                                    QFileView(qc).show(context);
                                    return;
                                  }

                                  _pdfLoading = true;
                                  selectedQc = qc;
                                  isPass = selectedQc?.quality?.toLowerCase() == 'qc pass';
                                  setState(() {});
                                  if (isPass) {
                                    return;
                                  }

                                  qc.getFile(context).then((value) async {
                                    _pdfLoading = false;
                                    setState(() {});
                                    _data = value;
                                  });
                                },
                                leading: UserImage(nsUser: qc.user, radius: 16, padding: 2),
                                title: Row(children: [
                                  const SizedBox(width: 4),
                                  Wrap(direction: Axis.vertical, children: [
                                    Text("${qc.user?.name}"),
                                    Text("${qc.user?.uname}", style: const TextStyle(color: Colors.blue, fontSize: 12)),
                                    Column(
                                      children: [
                                        Text(qc.quality ?? ''),
                                        Text(
                                          "${qc.getSection()?.sectionTitle}@${qc.getSection()?.factory}",
                                          style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                                        ),
                                      ],
                                    )
                                  ])
                                ]),
                                subtitle: Text(qc.getDateTime(), style: const TextStyle(fontSize: 12)));
                          },
                          itemCount: qcList.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                        ),
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                        child: selectedQc == null
                            ? Center(child: Text(widget.isQc ? 'Select QC' : 'Select QA'))
                            : isPass
                                ? Center(child: Image.asset(Res.qc_passed_sticket))
                                : _pdfLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : getView())
                  ])
                : RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () async {
                      return await apiGetData();
                    },
                    child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        QC qc = qcList[index];
                        return ListTile(
                            onTap: () async {
                              if (!kIsWeb) {
                                QFileView(qc).show(context);
                                return;
                              }
                              _pdfLoading = true;
                              selectedQc = qc;
                              setState(() {});
                              qc.getFile(context).then((value) async {
                                _pdfLoading = false;
                                setState(() {});
                                _data = value;
                              });
                            },
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(qc.quality ?? '', style: TextStyle(color: (qc.quality ?? '').getColor())),
                                Text("${qc.getSection()?.sectionTitle} @ ${qc.getSection()?.factory}", style: const TextStyle(color: Colors.redAccent)),
                              ],
                            ),
                            leading: UserImage(nsUser: qc.user, radius: 16, padding: 2),
                            title: Row(children: [
                              const SizedBox(width: 4),
                              Wrap(
                                  direction: Axis.vertical,
                                  children: [Text("${qc.user?.name}"), Text("${qc.user?.uname}", style: const TextStyle(color: Colors.blue, fontSize: 12))]),
                              const Spacer(),
                              Text(qc.isQc() ? 'QC' : 'QA'),
                              const Spacer()
                            ]),
                            subtitle: Text(qc.getDateTime(), style: const TextStyle(fontSize: 12)));
                      },
                      itemCount: qcList.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider();
                      },
                    ),
                  ));
  }

  // PdfControllerPinch pdfPinchController = PdfControllerPinch(document: PdfDocument.openAsset('x.pdf'));
  String? errMsg;

  Future apiGetData() {
    print('ticketId ${ticket.id}');
    return Api.get(EndPoints.tickets_qc_getTicketQcList, {'ticketId': ticket.id, 'isQc': widget.isQc ? 1 : 0}).then((res) {
      errMsg = null;
      Map data = res.data;
      print(data);

      if (data["error"] == true) {
        if (data["msg"] != null) {
          errMsg = "No Data Found";
        }
      } else {
        qcList = QC.fromJsonArray(data['qcs']);
      }

      setState(() {});
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                apiGetData();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  Widget getView() {
    return _pdfLoading
        ? const Center(child: CircularProgressIndicator())
        : _data == null
            ? Center(
                child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: Axis.vertical,
                children: [SizedBox(width: 200, child: Image.asset(Res.fileNotFound)), const Text("File Not Found")],
              ))
            : PdfViewer.openData(_data, params: const PdfViewerParams());
  }

  loadQc() {
    _pdfLoading = true;
    setState(() {});
    selectedQc?.getFile(context).then((value) async {
      _pdfLoading = false;
      _data = value;
      setState(() {});
    });
  }
}
