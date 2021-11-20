import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/Tickets/ProductionPool/Finish/PDFViewWidget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShippingSystem extends StatefulWidget {
  final Ticket ticket;

  ShippingSystem(this.ticket);

  @override
  _ShippingSystemState createState() => _ShippingSystemState();
}

class _ShippingSystemState extends State<ShippingSystem>
    with TickerProviderStateMixin {
  var tabs = ["All", "Cross Production"];
  TabController? _tabBarController;
  late Ticket ticket;

  var _webView;
  WebViewController? _controller;

  @override
  initState() {
    ticket = widget.ticket;
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _tabBarController = TabController(length: tabs.length, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: " + _tabBarController!.index.toString());
      });
    });

    _webView = WebView(
      // initialUrl: 'https://www.w3schools.com/howto/howto_css_register_form.asp',
      initialUrl: "http://dev.nsgshipping.com/userHome",
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
        // _controller.complete(webViewController);
      },
      onProgress: (int progress) {
        print("WebView is loading (progress : $progress%)");
      },
      javascriptChannels: <JavascriptChannel>{
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
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(ticket.mo ?? ""),
        ),
        body: Column(
          children: [
            // Expanded(child: PDFViewWidget(ticket.ticketFile!.path)),
            Expanded(
              child: DefaultTabController(
                  length: tabs.length,
                  child: Scaffold(
                      appBar: AppBar(
                        toolbarHeight: 0,
                        automaticallyImplyLeading: false,
                        elevation: 4.0,
                      ),
                      body: Scaffold(
                          body: PDFViewWidget(ticket.ticketFile!.path)))),
            ),
            Divider(),
            if (_webView != null)
              Expanded(
                child: _webView!,
              ),
          ],
        ));
  }
}
