import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as view;

String? response = "nulll";
Future<String?> value() async {
  // if (response!.isEmpty) {
  //   return "";
  // }
  // response
  if (response!.isNotEmpty) {
    return response;
  }
  return "nulll";
}

// /*  */
class WebView extends StatefulWidget {
  final String url;

  // const WebView(Key? key) : super(key: key);

  const WebView({required this.url, Key? key}) : super(key: key);

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  @override
  Widget build(BuildContext context) {
    view.WebViewController? controller;

    void readResponse() async {
      try {
        controller!
            .runJavascriptReturningResult(
                "document.getElementById('return').innerText")
            .catchError((e) {
          return Future<String>.value("");
        }).then((value) async {
          log("Value: $value");
          response = response!.length > 7 ? response : value;
          log("Response: $response");
        });
      } catch (e) {
        log("error: $e");
      }
    }
// value contains the html data of page as string

    // );
    // WebView(    )
    return view.WebView(
      initialUrl: widget.url,
      onWebViewCreated: (view.WebViewController webViewController) {
        controller = webViewController;
      },
      javascriptMode: view.JavascriptMode.unrestricted,
      gestureNavigationEnabled: true,
      onPageFinished: (String url) {
        readResponse();
      },
    );
  }
}
