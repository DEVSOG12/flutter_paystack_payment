import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack_payment/src/common/card_utils.dart';
import 'package:flutter_paystack_payment/src/common/my_strings.dart';
import 'package:flutter_paystack_payment/src/models/card.dart';
import 'package:flutter_paystack_payment/src/ui/common/input_formatters.dart';
import 'package:flutter_paystack_payment/src/ui/input/base_field.dart';

class DateField extends BaseTextField {
  DateField({
    Key? key,
    required PaymentCard? card,
    required FormFieldSetter<String> onSaved,
  }) : super(
          key: key,
          labelText: 'CARD EXPIRY',
          hintText: 'MM/YY',
          validator: validateDate,
          initialValue: _getInitialExpiryMonth(card),
          onSaved: onSaved,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
            CardMonthInputFormatter()
          ],
        );

  static String? _getInitialExpiryMonth(PaymentCard? card) {
    if (card == null) {
      return null;
    }
    if (card.expiryYear == null ||
        card.expiryMonth == null ||
        card.expiryYear == 0 ||
        card.expiryMonth == 0) {
      return null;
    } else {
      return '${card.expiryMonth}/${card.expiryYear}';
    }
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.invalidExpiry;
    }

    int year;
    int month;
    // The value contains a forward slash if the month and year has been
    // entered.
    if (value.contains(RegExp(r'(/)'))) {
      final date = CardUtils.getExpiryDate(value);
      month = date[0];
      year = date[1];
    } else {
      // Only the month was entered
      month = int.parse(value.substring(0, (value.length)));
      year = -1; // Lets use an invalid year intentionally
    }

    if (!CardUtils.isNotExpired(year, month)) {
      return Strings.invalidExpiry;
    }
    return null;
  }
}
