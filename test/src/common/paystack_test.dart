import 'dart:io';

import 'package:flutter_paystack_payment/src/common/paystack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("$PaystackPayment", () {
    test('is properly initialized with passed key', () async {
      var publicKey = Platform.environment["PAYSTACK_TEST_PUBLIC_KEY"] ??
          "pk_test_fbb50baa301b6d403f5c13b678a638c57e652061";
      final plugin = PaystackPayment();
      await plugin.initialize(publicKey: publicKey);
      expect(publicKey, plugin.publicKey);
    });
  });
}
