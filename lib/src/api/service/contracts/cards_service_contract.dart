import 'package:flutter_paystack_payment/src/api/model/transaction_api_response.dart';

abstract class CardServiceContract {
  Future<TransactionApiResponse> chargeCard(Map<String, String?> fields);

  Future<TransactionApiResponse> validateCharge(Map<String, String?> fields);

  Future<TransactionApiResponse> reQueryTransaction(String? trans);
}
