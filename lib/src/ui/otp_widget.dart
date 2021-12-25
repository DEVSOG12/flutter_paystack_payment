import 'package:flutter/material.dart';
import 'package:flutter_paystack_payment/src/ui/base_widget.dart';
import 'package:flutter_paystack_payment/src/ui/custom_dialog.dart';
import 'package:flutter_paystack_payment/src/ui/input/otp_field.dart';

import 'buttons.dart';

class OtpWidget extends StatefulWidget {
  final String? message;

  const OtpWidget({Key? key, required this.message}) : super(key: key);

  @override
  _OtpWidgetState createState() => _OtpWidgetState();
}

class _OtpWidgetState extends BaseState<OtpWidget> {
  final _formKey = GlobalKey<FormState>();
  var _autoValidate = AutovalidateMode.disabled;
  String? _otp;
  var heightBox = const SizedBox(height: 20.0);

  @override
  Widget buildChild(BuildContext context) {
    return CustomAlertDialog(
      content: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidate,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/otp.png',
                    width: 30.0, package: 'flutter_paystack_payment'),
                heightBox,
                Text(
                  widget.message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontSize: 15.0,
                  ),
                ),
                heightBox,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: OtpField(
                    onSaved: (String? value) => _otp = value,
                    borderColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                heightBox,
                AccentButton(
                  onPressed: _validateInputs,
                  text: 'Authorize',
                ),
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
      ),
    );
  }

  void _validateInputs() {
    FocusScope.of(context).requestFocus(FocusNode());
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      Navigator.of(context).pop(_otp);
    } else {
      setState(() {
        _autoValidate = AutovalidateMode.disabled;
      });
    }
  }
}
