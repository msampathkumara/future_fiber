import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/QC.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QCView extends StatefulWidget {
  final QC qc;

  const QCView(this.qc);

  @override
  _QCViewState createState() => _QCViewState();
}

class _QCViewState extends State<QCView> {
  var idToken;

  @override
  void initState() {
    var user = FirebaseAuth.instance.currentUser;
    user!.getIdToken().then((value) {
      setState(() {
        idToken = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var uRL = Server.getServerApiPath("tickets/qc/qcImageView?id=${widget.qc.id}");

    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.qc.ticket!.getName()}"),
        ),
        body: idToken != null
            ? WebView(
                onWebViewCreated: (WebViewController webViewController) {
                  Map<String, String> headers = {"authorization": "" + idToken};
                  webViewController.loadUrl(uRL, headers: headers);
                },
              )
            : const Center(child: CircularProgressIndicator()));
  }
}
