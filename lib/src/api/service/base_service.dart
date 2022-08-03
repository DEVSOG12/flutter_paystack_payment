import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_paystack_payment/flutter_paystack_payment.dart';

mixin BaseApiService {
  final Map<String, String> headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Credentials":
        'true', // Required for cookies, authorization headers with HTTPS
    "Access-Control-Allow-Headers":
        "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
    HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    HttpHeaders.userAgentHeader: PaystackPayment.platformInfo.userAgent,
    HttpHeaders.acceptHeader: 'application/json',
    'Content-Type': 'text/plain',

    'X-Paystack-Build': PaystackPayment.platformInfo.paystackBuild,
    'X-PAYSTACK-USER-AGENT': jsonEncode({
      'lang': kIsWeb
          ? 'flutter_web'
          : Platform.isIOS
              ? 'objective-c'
              : 'kotlin'
    }),
    'bindings_version': PaystackPayment.platformInfo.paystackBuild,
    'X-FLUTTER-USER-AGENT': PaystackPayment.platformInfo.userAgent
  };

  final Map<String, String> webheaders = {
    HttpHeaders.acceptHeader: 'application/json',
  };

  final String baseUrl = 'https://standard.paystack.co';
}
