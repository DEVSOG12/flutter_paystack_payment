import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    WebViewController? controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..runJavaScriptReturningResult(
              "document.getElementById('return').innerText")
          .catchError((e) {
        return Future<String>.value("");
      }).then((value) async {
        log("Value: $value");
        // response = response!.length > 7 ? response : value;
        log("Response: $response");
      })
      // .onError((error, stackTrace) async => log("error: $error"))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // void readResponse() async {
    //   try {
    //     controller
    //         .runJavaScriptReturningResult(
    //             "document.getElementById('return').innerText")
    //         .catchError((e) {
    //       return Future<String>.value("");
    //     }).then((value) async {
    //       log("Value: $value");
    //       // response = response!.length > 7 ? response : value;
    //       // log("Response: $response");
    //     });
    //   } catch (e) {
    //     log("error: $e");
    //   }
    // }
// value contains the html data of page as string

    // );
    // WebView(    )
    return WebViewWidget(
      controller: controller,
    );
    // return view.WebView(
    //   initialUrl: widget.url,
    //   onWebViewCreated: (view.WebViewController webViewController) {
    //     controller = webViewController;
    //   },
    //   javascriptMode: view.JavaScriptMode.unrestricted,
    //   gestureNavigationEnabled: true,
    //   onPageFinished: (String url) {
    //     readResponse();
    //   },
    // );
  }
}
