import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/QC.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QCView extends StatefulWidget {
  final QC qc;

  const QCView(this.qc, {super.key});

  @override
  _QCViewState createState() => _QCViewState();

  Future? show(context) async {
    return kIsWeb ? await showDialog(context: context, builder: (_) => this) : await Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _QCViewState extends State<QCView> {
  String? idToken;

  @override
  void initState() {
    super.initState();
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
            // ? WebView(
            //     onWebViewCreated: (WebViewController webViewController) {
            //       Map<String, String> headers = {"authorization": "$idToken"};
            //       webViewController.loadUrl(uRL, headers: headers);
            //     },
            //   )

            ? WebViewWidget(
                controller: WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..setNavigationDelegate(
                    NavigationDelegate(
                      onProgress: (int progress) {
                        // Update loading bar.
                      },
                      onPageStarted: (String url) {},
                      onPageFinished: (String url) {},
                      onWebResourceError: (WebResourceError error) {},
                      onNavigationRequest: (NavigationRequest request) {
                        return NavigationDecision.navigate;
                      },
                    ),
                  )
                  ..loadRequest(Uri.parse(uRL), headers: {"authorization": "$idToken"}))
            : const Center(child: CircularProgressIndicator()));
  }
}
