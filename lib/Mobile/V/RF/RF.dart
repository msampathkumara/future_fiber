import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';
import 'package:smartwind/res.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

class RF extends StatefulWidget {
  const RF({Key? key}) : super(key: key);

  @override
  State<RF> createState() => _RFState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _RFState extends State<RF> {
  late final WebViewController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            controller.runJavaScript("document.querySelector(\"#txt[type='text']\").value = \"Hello\"");
            controller.runJavaScript("document.querySelector(\"#txt[type='password']\").value = \"1\"");
            // controller.runJavaScript("\$('#txt[type='text']').val('dddxxxxxxxxxxxxx');");
            // controller.runJavaScript("\$('#txt[type='password']').val('1');");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      // ..loadRequest(Uri.parse('https://flutter.dev'));
      ..loadFlutterAsset(Res.RF_SMARTLogin1);

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  getWebUi() {
    return Scaffold(appBar: AppBar(title: Text('')), body: WebViewWidget(controller: _controller));
  }

  getUi() {
    return getWebUi();
  }
}
