import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack_payment/src/api/service/bank_service.dart';
import 'package:flutter_paystack_payment/src/api/service/card_service.dart';
import 'package:flutter_paystack_payment/src/common/exceptions.dart';
import 'package:flutter_paystack_payment/src/common/my_strings.dart';
import 'package:flutter_paystack_payment/src/common/platform_info.dart';
// import 'package:flutter_paystack_payment/src/common/platform_info.dart';
import 'package:flutter_paystack_payment/src/common/string_utils.dart';
import 'package:flutter_paystack_payment/src/common/utils.dart';
import 'package:flutter_paystack_payment/src/models/card.dart';
import 'package:flutter_paystack_payment/src/models/charge.dart';
import 'package:flutter_paystack_payment/src/models/checkout_response.dart';
import 'package:flutter_paystack_payment/src/transaction/card_transaction_manager.dart';
import 'package:flutter_paystack_payment/src/ui/checkout/checkout_widget.dart';
// import 'package:platform_info/platform_info.dart';

class PaystackPayment {
  bool _sdkInitialized = false;
  String _publicKey = "";
  static late PlatformInfo platformInfo;

  /// Initialize the Paystack object. It should be called as early as possible
  /// (preferably in initState() of the Widget.
  ///
  /// [publicKey] - your paystack public key. This is mandatory
  ///
  /// use [checkout] and you want this plugin to initialize the transaction for you.
  /// Please check [checkout] for more information
  ///
  initialize({required String publicKey}) async {
    assert(() {
      if (publicKey.isEmpty) {
        throw PaystackException('publicKey cannot be null or empty');
      }
      return true;
    }());

    if (sdkInitialized) return;

    publicKey = publicKey;

    // Using cascade notation to build the platform specific info
    try {
      platformInfo = (Platform.environment.containsKey('FLUTTER_TEST')
          ? (await PlatformInfo.test())!
          : (await PlatformInfo.getinfo()))!;
      _publicKey = publicKey;
      _sdkInitialized = true;
    } on PlatformException {
      rethrow;
    }
  }

  dispose() {
    _publicKey = "";
    _sdkInitialized = false;
  }

  bool get sdkInitialized => _sdkInitialized;

  String get publicKey {
    // Validate that the sdk has been initialized
    _validateSdkInitialized();
    return _publicKey;
  }

  void _performChecks() {
    //validate that sdk has been initialized
    _validateSdkInitialized();
    //check for null value, and length and starts with pk_
    if (_publicKey.isEmpty || !_publicKey.startsWith("pk_")) {
      throw AuthenticationException(Utils.getKeyErrorMsg('public'));
    }
  }

  /// Make payment by charging the user's card
  ///
  /// [context] - the ui BuildContext
  ///
  /// [charge] - the charge object.

  Future<CheckoutResponse> chargeCard(BuildContext context,
      {required Charge charge, required bool scanCard}) {
    _performChecks();

    return _Paystack(publicKey).chargeCard(context: context, charge: charge, scanCard: scanCard);
  }

  /// Make payment using Paystack's checkout form. The plugin will handle the whole
  /// processes involved.
  ///
  /// [context] - the widget's BuildContext
  ///
  /// [charge] - the charge object.
  ///
  /// [method] - The payment method to use(card, bank). It defaults to
  /// [CheckoutMethod.selectable] to allow the user to select. For [CheckoutMethod.bank]
  ///  or [CheckoutMethod.selectable], it is
  /// required that you supply an access code to the [Charge] object passed to [charge].
  /// For [CheckoutMethod.card], though not recommended, passing a reference to the
  /// [Charge] object will do just fine.
  ///
  /// Notes:
  ///
  /// * You can also pass the [PaymentCard] object and we'll use it to prepopulate the
  /// card  fields if card payment is being used
  ///
  /// [fullscreen] - Whether to display the payment in a full screen dialog or not
  ///
  /// [logo] - The widget to display at the top left of the payment prompt.
  /// Defaults to an Image widget with Paystack's logo.
  ///
  /// [hideEmail] - Whether to hide the email from the user. When
  /// `false` and an email is passed to the [charge] object, the email
  /// will be displayed at the top right edge of the UI prompt. Defaults to
  /// `false`
  ///
  /// [hideAmount]  - Whether to hide the amount from the  payment prompt.
  /// When `false` the payment amount and currency is displayed at the
  /// top of payment prompt, just under the email. Also the payment
  /// call-to-action will display the amount, otherwise it will display
  /// "Continue". Defaults to `false`
  Future<CheckoutResponse> checkout(
    BuildContext context, {
    required Charge charge,
    CheckoutMethod method = CheckoutMethod.selectable,
    bool scanCard = false,
    bool fullscreen = false,
    Widget? logo,
    bool hideEmail = false,
    bool hideAmount = false,
  }) async {
    return _Paystack(publicKey).checkout(
      context,
      charge: charge,
      method: method,
      fullscreen: fullscreen,
      scanCard: scanCard,
      logo: logo,
      hideAmount: hideAmount,
      hideEmail: hideEmail,
    );
  }

  _validateSdkInitialized() {
    if (!sdkInitialized) {
      throw PaystackSdkNotInitializedException(
          'Paystack SDK has not been initialized. The SDK has'
          ' to be initialized before use');
    }
  }
}

class _Paystack {
  final String publicKey;

  _Paystack(this.publicKey);

  Future<CheckoutResponse> chargeCard(
      {required BuildContext context, required Charge charge, required bool scanCard}) {
    return CardTransactionManager(
            service: CardService(),
            charge: charge,
            context: context,
            scanCard: scanCard,
            publicKey: publicKey)
        .chargeCard();
  }

  Future<CheckoutResponse> checkout(
    BuildContext context, {
    required Charge charge,
    required CheckoutMethod method,
    required bool fullscreen,
    bool scanCard = false,
    bool hideEmail = false,
    bool hideAmount = false,
    Widget? logo,
  }) async {
    assert(() {
      _validateChargeAndKey(charge);
      switch (method) {
        case CheckoutMethod.card:
          if (charge.accessCode == null && charge.reference == null) {
            throw ChargeException(Strings.noAccessCodeReference);
          }
          break;
        case CheckoutMethod.bank:
        case CheckoutMethod.selectable:
          if (charge.accessCode == null) {
            throw ChargeException('Pass an accesscode');
          }
          break;
      }
      return true;
    }());

    CheckoutResponse? response = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CheckoutWidget(
        publicKey: publicKey,
        bankService: BankService(),
        cardsService: CardService(),
        method: method,
        scanCard: scanCard,
        charge: charge,
        fullscreen: fullscreen,
        logo: logo,
        hideAmount: hideAmount,
        hideEmail: hideEmail,
      ),
    );
    return response!;
  }

  _validateChargeAndKey(Charge charge) {
    if (charge.amount.isNegative) {
      throw InvalidAmountException(charge.amount);
    }
    if (!StringUtils.isValidEmail(charge.email)) {
      throw InvalidEmailException(charge.email);
    }
  }
}

typedef OnTransactionChange<Transaction> = void Function(
    Transaction transaction);
typedef OnTransactionError<Object, Transaction> = void Function(
    Object e, Transaction transaction);

enum CheckoutMethod { card, bank, selectable }
