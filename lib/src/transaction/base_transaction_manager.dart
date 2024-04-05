import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import "package:universal_html/html.dart" as html;
// import 'package:flutter_web_auth/flutter_web_auth.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_payment/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack_payment/src/common/exceptions.dart';
import 'package:flutter_paystack_payment/src/common/paystack.dart';
// import 'package:flutter_paystack_payment/src/common/utils.dart';
import 'package:flutter_paystack_payment/src/models/card.dart';
import 'package:flutter_paystack_payment/src/models/charge.dart';
import 'package:flutter_paystack_payment/src/models/checkout_response.dart';
import 'package:flutter_paystack_payment/src/models/transaction.dart';
import 'package:flutter_paystack_payment/src/ui/birthday_widget.dart';
import 'package:flutter_paystack_payment/src/ui/card_widget.dart';
import 'package:flutter_paystack_payment/src/ui/otp_widget.dart';
import 'package:flutter_paystack_payment/src/ui/pin_widget.dart';
import 'package:flutter_paystack_payment/src/ui/webview.dart';

abstract class BaseTransactionManager {
  bool processing = false;
  final Charge charge;
  final BuildContext context;
  final Transaction transaction = Transaction();
  final String publicKey;
  final bool scanCard;

  BaseTransactionManager({
    required this.charge,
    required this.scanCard,
    required this.context,
    required this.publicKey,
  });

  initiate() async {
    if (processing) throw ProcessingException();

    setProcessingOn();
    await postInitiate();
  }

  Future<CheckoutResponse> sendCharge() async {
    try {
      return sendChargeOnServer();
    } catch (e) {
      return notifyProcessingError(e);
    }
  }

  Future<CheckoutResponse> handleApiResponse(
      TransactionApiResponse apiResponse);

  Future<CheckoutResponse> _initApiResponse(
      TransactionApiResponse? apiResponse) {
    apiResponse ??= TransactionApiResponse.unknownServerResponse();

    transaction.loadFromResponse(apiResponse);

    return handleApiResponse(apiResponse);
  }

  Future<CheckoutResponse> handleServerResponse(
      Future<TransactionApiResponse> future) async {
    try {
      final apiResponse = await future;
      return _initApiResponse(apiResponse);
    } catch (e) {
      return notifyProcessingError(e);
    }
  }

  CheckoutResponse notifyProcessingError(Object e) {
    setProcessingOff();

    if (e is TimeoutException || e is SocketException) {
      e = 'Please  check your internet connection or try again later';
    }
    return CheckoutResponse(
        message: e.toString(),
        reference: transaction.reference,
        status: false,
        card: charge.card?..nullifyNumber(),
        account: charge.account,
        method: checkoutMethod(),
        verify: e is! PaystackException);
  }

  setProcessingOff() => processing = false;

  setProcessingOn() => processing = true;

  Future<CheckoutResponse> getCardInfoFrmUI(
      PaymentCard? currentCard, bool scanCard) async {
    PaymentCard? newCard = await showDialog<PaymentCard>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CardInputWidget(
              currentCard,
              scanCard: scanCard,
            ));

    if (newCard == null || !newCard.isValid()) {
      return notifyProcessingError(CardException('Invalid card parameters'));
    } else {
      charge.card = newCard;
      return handleCardInput();
    }
  }

  Future<CheckoutResponse> getOtpFrmUI(
      {String? message, TransactionApiResponse? response}) async {
    assert(message != null || response != null);
    String? otp = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => OtpWidget(
            // ignore: unnecessary_null_comparison
            message: message! != null
                ? message
                : response!.displayText == null || response.displayText!.isEmpty
                    ? response.message
                    : response.displayText));

    if (otp != null && otp.isNotEmpty) {
      return handleOtpInput(otp, response);
    } else {
      return notifyProcessingError(
          PaystackException("You did not provide an OTP"));
    }
  }

  Future<CheckoutResponse> getAuthfromUIWeb(String? url) async {
    Map<String, dynamic> resulm = {};
    TransactionApiResponse? apiResponse;
    Future<bool> openpage() async {
      html.window.open(url!, 'new window');

      html.window.onMessage.listen((event) async {
        log(event.data.toString().substring(13).toString());
        resulm = json.decode(event.data.toString().substring(13).toString());

        // _initApiResponse(ans);
      }).asFuture((x) => log(x));
      return Future.value(html.window.closed);
    }

    // Future<bool> open() async {

    // final int res = 1 + 1;
    // return resulm != {};
    // }

    // TransactionApiResponse? apiResponse;
    // Future<TransactionApiResponse> doitm({Map<String, dynamic>? result}) async {
    try {
      await openpage();
      await Future.delayed(const Duration(seconds: 5), () {
        if (apiResponse == null) {
          Future.delayed(const Duration(seconds: 30), () {
            if (apiResponse == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Error. Retrying for the last time")));
              Future.delayed(const Duration(seconds: 30), () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error. Failed")));
              });
            }
          });
        }
      });

      apiResponse = TransactionApiResponse.fromMap(resulm);
      return _initApiResponse(apiResponse);
    } catch (e) {
      log(e.toString());
      apiResponse = TransactionApiResponse.unknownServerResponse();
      return _initApiResponse(apiResponse);
    }

    // log("api Res $apiResponse");
  }

  // Future<CheckoutResponse> getAuthDesktopFrmUI(String? url) async {
  //   // String? result = "";
  //   TransactionApiResponse? apiResponse;

  //   Future<void> doit({String? result}) async {
  //     try {
  //       log(result!);
  //       log(json.decode(result));

  //       Map<String, dynamic> responseMap = json.decode(json.decode(result));
  //       apiResponse = TransactionApiResponse.fromMap(responseMap);
  //     } catch (e) {
  //       log(e.toString());
  //     }
  //   }

  //   // final res = await FlutterWebAuth.authenticate(
  //   //     url: url!, callbackUrlScheme: "return");

  //   // log(res);

  //   return _initApiResponse(apiResponse);
  // }

  Future<CheckoutResponse> getAuthFrmUI(String? url) async {
    String? result = "";
    TransactionApiResponse? apiResponse;

    Future<void> doit({String? result}) async {
      try {
        // Sample: result =  "{\"status\":\"0\",\"bank\":\"Kuda Bank\",\"message\":\"Invalid Amount\",\"fallback\":false}"
        result = result!.replaceAll("\\", "");
        result = result.replaceAll("\"{", "{");
        result = result.replaceAll("}\"", "}");
        result = result.replaceAll("\"[", "[");
        result = result.replaceAll("]\"", "]");
        Map<String, dynamic> responseMap = json.decode(result);

        apiResponse = TransactionApiResponse.fromMap(responseMap);
      } catch (e) {
        log(e.toString());
      }
    }

    await showDialog(
        context: context,
        builder: (_) {
          // Future
          return Dialog(
            child: Builder(builder: (context) {
              return WebView(
                url: url!,
              );
            }),
          );
        }).then((values) async {
      result = await value();
      if (result != "") {
        // await doit(result: result);
      }
    }).then((value) async {
      await doit(result: result);
      return _initApiResponse(apiResponse);
    });

    // if (apiResponse == TransactionApiResponse.unknownServerResponse()) {
    //   await doitm(result: resulm);
    // }
    // apiResponse == null
    return _initApiResponse(apiResponse);
  }

  Future<CheckoutResponse> getPinFrmUI() async {
    String? pin = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => const PinWidget());

    if (pin != null && pin.length == 4) {
      return handlePinInput(pin);
    } else {
      return notifyProcessingError(
          PaystackException("PIN must be exactly 4 digits"));
    }
  }

  Future<CheckoutResponse> getBirthdayFrmUI(
      TransactionApiResponse response) async {
    String? birthday = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          var messageText =
              response.displayText == null || response.displayText!.isEmpty
                  ? response.message!
                  : response.displayText!;
          return BirthdayWidget(message: messageText);
        });

    if (birthday != null && birthday.isNotEmpty) {
      return handleBirthdayInput(birthday, response);
    } else {
      return notifyProcessingError(
          PaystackException("Date of birth not supplied"));
    }
  }

  CheckoutResponse onSuccess(Transaction transaction) {
    return CheckoutResponse(
        message: transaction.message,
        reference: transaction.reference,
        status: true,
        card: charge.card?..nullifyNumber(),
        account: charge.account,
        method: checkoutMethod(),
        verify: true);
  }

  Future<CheckoutResponse> handleCardInput() {
    throw UnsupportedError(
        "Handling of card input not supported for Bank payment method");
  }

  Future<CheckoutResponse> handleOtpInput(
      String otp, TransactionApiResponse? response);

  Future<CheckoutResponse> handlePinInput(String pin) {
    throw UnsupportedError("Pin Input not supported for ${checkoutMethod()}");
  }

  postInitiate();

  Future<CheckoutResponse> handleBirthdayInput(
      String birthday, TransactionApiResponse response) {
    throw UnsupportedError(
        "Birthday Input not supported for ${checkoutMethod()}");
  }

  CheckoutMethod checkoutMethod();

  Future<CheckoutResponse> sendChargeOnServer();
}
