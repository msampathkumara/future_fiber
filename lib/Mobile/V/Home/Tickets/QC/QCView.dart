import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/QC.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../M/EndPoints.dart';

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
  // String? idToken;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.qc.ticket!.getName()}"),
        ),
        body: FutureBuilder(
            future: f(),
            builder: (context, AsyncSnapshot<Map> d) {
              return d.hasData
                  ? WebViewWidget(
                      controller: WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..setNavigationDelegate(NavigationDelegate(
                            onProgress: (int progress) {
                              // Update loading bar.
                            },
                            onPageStarted: (String url) {},
                            onPageFinished: (String url) {},
                            onWebResourceError: (WebResourceError error) {},
                            onNavigationRequest: (NavigationRequest request) {
                              return NavigationDecision.navigate;
                            }))
                        ..loadRequest(Uri.parse(d.data!["url"]), headers: {"authorization": "${d.data!["idToken"]}"}))
                  : const Center(child: CircularProgressIndicator());
            }));
  }

  f() async {
    var user = FirebaseAuth.instance.currentUser;
    var uRL = await Server.getServerApiPath("${EndPoints.tickets_qc_qcImageView}?id=${widget.qc.id}");
    return {"url": uRL, "idToken": await user!.getIdToken()};
  }
}
