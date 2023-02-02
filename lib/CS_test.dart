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
      // initialUrl: "http://api.smartupwind.nsslsupportservices.com/",
      // initialUrl: "https://ps.uci.edu/~franklin/doc/file_upload.html",
      javascriptMode: JavascriptMode.unrestricted,
      onCustomWebViewCreated: (CustomWebViewController webViewController) {
        _webViewController = webViewController;
        print('llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll');
        // _webViewController.evaluateJavascript(" setTimeout(function(){  console.log('Hello World');  }, 2000);");
        // webViewController.loadUrl("http://bluebook.northsails.com:8088/nsbb/app/blueBook.html", headers: {"Authorization": "Basic c3VtaXRyYUBsazpZeFpGZThIeA=="});
        // webViewController.loadUrl("https://cs.northsails.com", headers: {
        //   "Cookie":
        //       "cebs=1; _ce.s=v~b361319716790f77f7ab50d33e89dd2e808b4d93~vpv~0; _CEFT=Q%3D%3D%3D; __exponea_etc__=fe6f47cd-8083-49f0-a5ca-9086ffbdb063; cebsp=1; _tracking_consent=%7B%22con%22%3A%7B%22CCPA%22%3A%22%22%2C%22GDPR%22%3A%22%22%7D%2C%22v%22%3A%222.0%22%2C%22lim%22%3A%5B%22CCPA%22%2C%22GDPR%22%5D%2C%22reg%22%3A%22%22%7D; _y=caad7a2d-7c36-49d2-800a-6120ae313c29; _shopify_y=caad7a2d-7c36-49d2-800a-6120ae313c29; _shopify_m=persistent; _ga_DGJMN10HS6=GS1.1.1666091839.1.1.1666091854.0.0.0; _clck=yydgd8|1|f5t|0; _ga=GA1.2.733851508.1666091840; _uetvid=78201fa04ed611ed92a509d6d36cca00; _ga_VVVXDBS8EH=GS1.1.1666091854.1.1.1666092720.0.0.0; ASP.NET_SessionId=2q4mnorfqysj0u05k3y0nmiq; fingerprint=34cc0e5a2f5397bf02a46aab7bc265f8; .NSUserTicket=3E7AF8CFBCA456AE3387BDC8F6B5BB80BDA1AC4FF3948B183B6EA5FBEACD23F69CC18B7FE17C2E494AE6DA6D413F1C2A33BCD9D0B6AF605D9B500F691A1254C29261EBC3D9D3A20C078F3DEBA34C67214C0CCF4D0CF7F7B3377EDEB939BA38AED5B490D4BA1E0913167A8EDBAA366E52FB85846DAD70EB78A668E7E980F17E6DF492A87EF65313088C6A34F4D36684B49745E53EB8395E8AD4989F7B86F042F266127A932D5DA60D32E5151C6DFB797A2959502D2D3E6FE1DEA83422CA84D212FF301B340DD65C6424F12BE4F1B1A08633B34EB6AA3BDDBECDC610B5B7CAE20F6E96B367D4064D7F951FBA435BDB0146E6CBA6E29AF7123C73553C18D06A4B7C452F85134272CAC99ECC822029195D25521AA550E09E2CEA7143B2CB9B14D1D9DAE090CF5A88F1B1966C6A38C12416B4DB2312BE9A6F3E33155C2665735FAC364DA3D40FB6125B124640E4A77DB5017C3DE4C4EB6CDA119085B4E54C3BE721B7B51C023BA81F1C192538C7C5BA2A362354CBAFB5B1F7E9328DC28E0B6350F79C94F04C5091C49C22AE90EE2DBB12225A; .NSUserRoles=ZjaZeQ85vUA0k0NPwaPvLacFoDmX2KCpuonOS5nd81CFVyAZZaKnYBqpO9PrsolvIywAvWDqhpubJOC4okCxjUa/rvwZtBJcFgWf8VsCvJsHRBlgySeX5JY6x2v9TNgJqEptKXKVJP808COMXOi5cXw4XidrCOkdh5/1boFiFPPvMZMqZGCU0SxpPmrQXQ/bvIuIt5VnuZEuMPpi9mN3qtN8t+X5xd0iLgxgFVFTI3ovNCsoFWjR6hPOntrl1cXVR5YipvQdiBvmbrHnmdTakL9flnKGodj50385BnvJglU="
        // });
        // _controller.complete(webViewController);
        // _webViewController.evaluateJavascript("console.log('sssssssssssssssssssssssss')");
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
