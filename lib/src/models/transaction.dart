import 'package:flutter_paystack_payment/src/api/model/transaction_api_response.dart';

class Transaction {
  String? _id;
  String? _reference;
  String? _message;

  loadFromResponse(TransactionApiResponse t) {
    if (t.hasValidReferenceAndTrans()) {
      _reference = t.reference;
      _id = t.trans;
      _message = t.message;
    }
  }

  String? get reference => _reference;

  String? get id => _id;

  String get message => _message ?? "";

  bool hasStartedOnServer() {
    return (reference != null) && (id != null);
  }
}
