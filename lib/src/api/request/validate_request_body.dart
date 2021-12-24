import 'package:flutter_paystack_payment/src/api/request/base_request_body.dart';

class ValidateRequestBody extends BaseRequestBody {
  final String _fieldTrans = 'trans';
  final String _fieldToken = 'token';
  String? trans;
  String? token;

  @override
  Map<String, String?> paramsMap() {
    Map<String, String?> params = {_fieldTrans: trans, _fieldToken: token};
    if (device != null) {
      params[fieldDevice] = device;
    }
    return params;
  }
}
