import 'package:custom_webview/webview_flutter.dart';
import 'package:flutter/material.dart';

class CsTest extends StatefulWidget {
  const CsTest({Key? key}) : super(key: key);

  @override
  State<CsTest> createState() => _CsTestState();
}

class _CsTestState extends State<CsTest> {
  late CustomWebView _webView;
  late CustomWebViewController _webViewController;

  var selectedPage;

  bool _loading = true;

  @override
  void initState() {
    _webView = CustomWebView(
      initialUrl: "https://cs.northsails.com",
      javascriptMode: JavascriptMode.unrestricted,
      onCustomWebViewCreated: (CustomWebViewController webViewController) {
        _webViewController = webViewController;
      },
      onShowFileChooser: () {
        print("------------------------------------------------------------------x $selectedPage");
        return "$selectedPage";
      },
      onProgress: (int progress) {
        print("WebView is loading (progress : $progress%)");
      },
      javascriptChannels: const <JavascriptChannel>{},
      navigationDelegate: (NavigationRequest request) {
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
        // _controller!.evaluateJavascript(jsString);
        _webViewController.evaluateJavascript("var el = document.getElementById('InputUserName');el.value = 'sisil mahinda';"
            "el.dispatchEvent(new Event('focus'));  el.dispatchEvent(new KeyboardEvent('keypress',{'key':'a'}));"
            "console.log('sssssssssssssssssssssssssxx'); ");
        _webViewController.evaluateJavascript("document.getElementById('InputPassword').value = 'Upwind@123';console.log('sssssssssssssssssssssssssxx'); ");
        _webViewController.evaluateJavascript("var form =document.forms[0]; ");

        setState(() {
          _loading = false;
        });
      },
      gestureNavigationEnabled: true,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [_webView, if (_loading) const Center(child: CircularProgressIndicator())],
    ));
  }
}
