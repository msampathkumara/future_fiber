import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import 'package:pdfx/pdfx.dart';
import 'package:smartwind/M/QC.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/Web/V/QC/QFileView.dart';
import 'package:universal_html/html.dart' as html;

// import 'package:webview_flutter/webview_flutter.dart';

import '../../../C/Api.dart';
import '../../../V/Widgets/UserImage.dart';
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

  @override
  void initState() {
    ticket = widget.ticket;
    apiGetData();
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

  editUserUi() {
    return Scaffold(
        appBar: AppBar(actions: [
          if (!_pdfLoading && selectedQc != null)
            IconButton(
                onPressed: () {
                  final blob = html.Blob([_data], 'application/pdf');
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  html.window.open(url, 'new tab');
                },
                icon: const Icon(Icons.open_in_new))
        ]),
        body: err_msg != null
            ? Text(err_msg!)
            : Row(children: [
                SizedBox(
                  width: 300,
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
                            // final WebViewController controller = await _controller.future;

                            qc.getFile(context).then((value) async {
                              _pdfLoading = false;
                              setState(() {});
                              // pdfPinchController = PdfControllerPinch(document: PdfDocument.openData(Future.value(Uint8List.fromList(value))));
                              // final document = PdfDocument.openData(value);
                              // pdfPinchController.loadDocument(document);

                              _data = value;

                              // final blob = html.Blob([value], 'application/pdf');
                              // final url = html.Url.createObjectUrlFromBlob(blob);
                            });
                          },
                          leading: UserImage(nsUser: qc.user, radius: 16, padding: 2),
                          title: Row(children: [
                            const SizedBox(width: 4),
                            Wrap(
                                direction: Axis.vertical, children: [Text("${qc.user?.name}"), Text("${qc.user?.uname}", style: const TextStyle(color: Colors.blue, fontSize: 12))])
                          ]),
                          subtitle: Text(qc.getDateTime(), style: const TextStyle(fontSize: 12)));
                    },
                    itemCount: qcList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                  ),
                ),
                if (kIsWeb) const VerticalDivider(),
                if (kIsWeb)
                  Expanded(
                      child: selectedQc == null
                          ? const Center(child: Text('Select Qc'))
                          : _pdfLoading
                              ? const Center(child: CircularProgressIndicator())
                              : QFileView(selectedQc!)
                      // : PdfViewer.openData(_data, params: const PdfViewerParams())

                      // : PdfViewPinch(
                      //     controller: pdfPinchController,
                      //     onDocumentError: (err) {
                      //       print(err);
                      //     },
                      //     onDocumentLoaded: (document) {
                      //       setState(() {
                      //         // _allPagesCount = document.pagesCount;
                      //       });
                      //     },
                      //     onPageChanged: (page) {
                      //       setState(() {
                      //         // _actualPageNumber = page;
                      //       });
                      //     },
                      //   )
                      )
              ]));
  }

  // PdfControllerPinch pdfPinchController = PdfControllerPinch(document: PdfDocument.openAsset('x.pdf'));
  String? err_msg;

  Future apiGetData() {
    return Api.get("tickets/qc/getTicketQcList", {'ticketId': ticket.id}).then((res) {
      err_msg = null;
      Map data = res.data;
      print(data);

      if (data["error"] == true) {
        if (data["msg"] != null) {
          err_msg = "No Data Found";
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

// Future<void> _onDoPostRequest(WebViewController controller, BuildContext context) async {
//   final WebViewRequest request = WebViewRequest(
//     uri: Uri.parse('https://httpbin.org/post'),
//     method: WebViewRequestMethod.post,
//     headers: <String, String>{'foo': 'bar', 'Content-Type': 'text/plain'},
//     body: Uint8List.fromList('Test Body'.codeUnits),
//   );
//   await controller.loadRequest(request);
// }
}
