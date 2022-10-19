import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/Mobile/V/Home/Tickets/ProductionPool/Finish/PDFViewWidget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShippingSystem extends StatefulWidget {
  final Ticket ticket;

  const ShippingSystem(this.ticket, {super.key});

  @override
  _ShippingSystemState createState() => _ShippingSystemState();
}

class _ShippingSystemState extends State<ShippingSystem> with TickerProviderStateMixin {
  var tabs = ["All"];
  TabController? _tabBarController;
  late Ticket ticket;

  WebView? _webView;

  late WebViewController _webViewController;

  @override
  initState() {
    ticket = widget.ticket;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: ${_tabBarController!.index}");
      });
    });

    _webView = WebView(
      // initialUrl: "https://smartwind.nsslsupportservices.com",
      initialUrl: "https://dev.nsgshipping.com/userHome",
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) async {
        // _controller.complete(webViewController);
        _webViewController = webViewController;
        _webViewController.runJavascriptReturningResult("document.getElementById(\"userName\").value = \"My value\";");
      },
      onProgress: (int progress) {
        print("WebView is loading (progress : $progress%)");
      },
      javascriptChannels: const <JavascriptChannel>{
        // _toasterJavascriptChannel(context),
      },
      navigationDelegate: (NavigationRequest request) {
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
      },
      gestureNavigationEnabled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(ticket.mo ?? ""),
        ),
        body: Column(
          children: [
            // Expanded(child: PDFViewWidget(ticket.ticketFile!.path)),
            if (isPortrait)
              Expanded(
                  child: DefaultTabController(
                      length: tabs.length,
                      child: Scaffold(
                          appBar: AppBar(
                            toolbarHeight: 0,
                            automaticallyImplyLeading: false,
                            elevation: 4.0,
                          ),
                          body: Scaffold(body: PDFViewWidget(ticket.ticketFile!.path))))),
            if (isPortrait) const Divider(),
            if (_webView != null) Expanded(child: _webView!),
          ],
        ));
  }
}
