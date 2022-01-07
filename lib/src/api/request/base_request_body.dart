import 'package:flutter_paystack_payment/flutter_paystack_payment.dart';

abstract class BaseRequestBody {
  final fieldDevice = 'device';
  String? _device;

  BaseRequestBody() {
    _setDeviceId();
  }

  Map<String, String?> paramsMap();

  String? get device => _device;

  _setDeviceId() {
    String deviceId = PaystackPayment.platformInfo.deviceId;
    _device = deviceId;
  }
}
