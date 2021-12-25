import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack_payment/src/common/my_strings.dart';
import 'package:flutter_paystack_payment/src/ui/input/base_field.dart';

class AccountField extends BaseTextField {
  AccountField({Key? key, required FormFieldSetter<String> onSaved})
      : super(
          key: key,
          labelText: 'Bank Account Number(10 digits)',
          validator: _validate,
          onSaved: onSaved,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        );

  static String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) return Strings.invalidAcc;
    return value.length == 10 ? null : Strings.invalidAcc;
  }
}
