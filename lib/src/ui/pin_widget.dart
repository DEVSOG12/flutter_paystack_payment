import 'package:flutter/material.dart';
import 'package:flutter_paystack_payment/src/ui/base_widget.dart';
import 'package:flutter_paystack_payment/src/ui/custom_dialog.dart';
import 'package:flutter_paystack_payment/src/ui/input/pin_field.dart';

import 'buttons.dart';

class PinWidget extends StatefulWidget {
  @override
  _PinWidgetState createState() => _PinWidgetState();
}

class _PinWidgetState extends BaseState<PinWidget> {
  var heightBox = const SizedBox(height: 20.0);

  @override
  void initState() {
    confirmationMessage = 'Do you want to cancel PIN input?';
    super.initState();
  }

  @override
  Widget buildChild(BuildContext context) {
    return CustomAlertDialog(
      content: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildStar(),
              heightBox,
              const Text(
                'To confirm you\'re the owner of this card, please '
                'enter your card pin.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontSize: 15.0,
                ),
              ),
              heightBox,
              PinField(onSaved: (String pin) => Navigator.of(context).pop(pin)),
              heightBox,
              WhiteButton(
                onPressed: onCancelPress,
                text: 'Cancel',
                flat: true,
                bold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStar() {
    Icon star(Color color) => Icon(
          Icons.star,
          color: color,
          size: 12.0,
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(6.0, 15.0, 6.0, 6.0),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: const BorderRadius.all(Radius.circular(5.0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
            _startCount,
            (i) => star(i == (_startCount - 1)
                ? Theme.of(context).accentColor
                : Theme.of(context).primaryColorLight)),
      ),
    );
  }
}

const _startCount = 4;
