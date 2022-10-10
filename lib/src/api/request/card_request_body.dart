import 'dart:async';

import 'package:flutter_paystack_payment/flutter_paystack_payment.dart';
import 'package:flutter_paystack_payment/src/api/request/base_request_body.dart';
import 'package:flutter_paystack_payment/src/common/card_utils.dart';
import 'package:flutter_paystack_payment/src/common/crypto.dart';
import 'package:flutter_paystack_payment/src/models/charge.dart';

class CardRequestBody extends BaseRequestBody {
  static const String fieldClientData = "clientdata";
  static const String fieldLast4 = "last4";
  static const String fieldAccessCode = "access_code";
  static const String fieldPublicKey = "public_key";
  static const String fieldEmail = "email";
  static const String fieldAmount = "amount";
  static const String fieldReference = "reference";
  static const String fieldSubAccount = "subaccount";
  static const String fieldTransactionCharge = "transaction_charge";
  static const String fieldBearer = "bearer";
  static const String fieldHandle = "handle";
  static const String fieldMetadata = "metadata";
  static const String fieldCurrency = "currency";
  static const String fieldPlan = "plan";

  final String _clientData;
  final String? _last4;
  final String? _publicKey;
  final String? _accessCode;
  final String? _email;
  final String _amount;
  final String? _reference;
  final String? _subAccount;
  final String? _transactionCharge;
  final String? _bearer;
  String? _handle;
  final String? _metadata;
  final String? _currency;
  final String? _plan;
  final Map<String, String?>? _additionalParameters;

  CardRequestBody._(this._publicKey, Charge charge, String clientData)
      : _clientData = clientData,
        // _handle = "",
        _last4 = charge.card!.last4Digits,
        _email = charge.email,
        _amount = charge.amount.toString(),
        _reference = charge.reference,
        _subAccount = charge.subAccount,
        _transactionCharge =
            charge.transactionCharge != null && charge.transactionCharge! > 0
                ? charge.transactionCharge.toString()
                : null,
        _bearer = charge.bearer != null ? getBearer(charge.bearer) : null,
        _metadata = charge.metadata,
        _plan = charge.plan,
        _currency = charge.currency,
        _accessCode = charge.accessCode,
        _additionalParameters = charge.additionalParameters;

  static Future<CardRequestBody> getChargeRequestBody(
      String publicKey, Charge charge) async {
    return Crypto.encrypt(CardUtils.concatenateCardFields(charge.card!))
        .then((clientData) => CardRequestBody._(publicKey, charge, clientData));
  }

  addPin(String pin) async {
    _handle = await Crypto.encrypt(pin);
  }

  static String? getBearer(Bearer? bearer) {
    if (bearer == null) return null;
    String? bearerStr;
    switch (bearer) {
      case Bearer.subAccount:
        bearerStr = "subaccount";
        break;
      case Bearer.account:
        bearerStr = "account";
        break;
    }
    return bearerStr;
  }

  @override
  Map<String, String?> paramsMap() {
    // set values will override additional params provided
    Map<String, String?> params = _additionalParameters!;
    params[fieldPublicKey] = _publicKey;
    params[fieldClientData] = _clientData;
    params[fieldLast4] = _last4;
    params[fieldAccessCode] = _accessCode;
    params[fieldEmail] = _email;
    params[fieldAmount] = _amount;
    params[fieldHandle] = _handle;
    params[fieldReference] = _reference;
    params[fieldSubAccount] = _subAccount;
    params[fieldTransactionCharge] = _transactionCharge;
    params[fieldBearer] = _bearer;
    params[fieldMetadata] = _metadata;
    params[fieldPlan] = _plan;
    params[fieldCurrency] = _currency;
    params[fieldDevice] = device;
    return params..removeWhere((key, value) => value == null || value.isEmpty);
  }
}
