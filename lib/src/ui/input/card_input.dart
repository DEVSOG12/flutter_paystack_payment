// ignore_for_file: no_logic_in_create_state

import 'package:credit_card_scanner/models/card_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_payment/src/common/card_utils.dart';
import 'package:flutter_paystack_payment/src/common/scan_util.dart';
import 'package:flutter_paystack_payment/src/common/utils.dart';
import 'package:flutter_paystack_payment/src/models/card.dart';
import 'package:flutter_paystack_payment/src/ui/buttons.dart';
import 'package:flutter_paystack_payment/src/ui/input/cvc_field.dart';
import 'package:flutter_paystack_payment/src/ui/input/date_field.dart';
import 'package:flutter_paystack_payment/src/ui/input/number_field.dart';

class CardInput extends StatefulWidget {
  final String buttonText;
  final PaymentCard? card;
  final ValueChanged<PaymentCard?> onValidated;

  const CardInput({
    Key? key,
    required this.buttonText,
    required this.card,
    required this.onValidated,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CardInputState createState() => _CardInputState(card);
}

class _CardInputState extends State<CardInput> {
  final _formKey = GlobalKey<FormState>();
  final PaymentCard? _card;
  var _autoValidate = AutovalidateMode.disabled;
  late TextEditingController numberController;
  bool _validated = false;

  _CardInputState(this._card);

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController();
    numberController.addListener(_getCardTypeFrmNumber);
    if (_card?.number != null) {
      numberController.text = Utils.addSpaces(_card!.number!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: _autoValidate,
      key: _formKey,
      child: Column(
        children: <Widget>[
          NumberField(
            key: const Key("CardNumberKey"),
            controller: numberController,
            card: _card,
            onSaved: (String? value) =>
                _card!.number = CardUtils.getCleanedNumber(value),
            suffix: GestureDetector(
                onTap: () async {
                  ScanCard scanCard = ScanCard();
                  CardDetails cardDetails = await scanCard.scanCard();
                  setState(() {
                    numberController.text = cardDetails.cardNumber;
                    _card!.number =
                        CardUtils.getCleanedNumber(cardDetails.cardNumber);
                    // _card!.expiryMonth =
                    //     int.parse(cardDetails.expiryDate.split('/')[0]);
                    // _card!.expiryYear =
                    //     int.parse(cardDetails.expiryDate.split('/')[1]);
                    // _card!.cvc = cardDetail;
                  });
                },
                child: getCardIcon()),
          ),
          const SizedBox(
            height: 15.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: DateField(
                  key: const ValueKey("ExpiryKey"),
                  card: _card,
                  onSaved: (value) {
                    List<int> expiryDate = CardUtils.getExpiryDate(value);
                    _card!.expiryMonth = expiryDate[0];
                    _card!.expiryYear = expiryDate[1];
                  },
                ),
              ),
              const SizedBox(width: 15.0),
              Flexible(
                  child: CVCField(
                key: const Key("CVVKey"),
                card: _card,
                onSaved: (value) {
                  _card!.cvc = CardUtils.getCleanedNumber(value);
                },
              )),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          AccentButton(
              key: const Key("PayButton"),
              onPressed: _validateInputs,
              text: widget.buttonText,
              showProgress: _validated),
        ],
      ),
    );
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    String cardType = _card!.getTypeForIIN(input);
    setState(() {
      _card!.type = cardType;
    });
  }

  void _validateInputs() {
    FocusScope.of(context).requestFocus(FocusNode());
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      widget.onValidated(_card);
      if (mounted) {
        setState(() => _validated = true);
      }
    } else {
      setState(() => _autoValidate = AutovalidateMode.always);
    }
  }

  Widget getCardIcon() {
    String img = "";
    var defaultIcon = Icon(
      Icons.camera_alt_outlined,
      key: const Key("DefaultIssuerIcon"),
      size: 15.0,
      color: Colors.grey[600],
    );
    if (_card != null) {
      switch (_card!.type) {
        case CardType.masterCard:
          img = 'mastercard.png';
          break;
        case CardType.visa:
          img = 'visa.png';
          break;
        case CardType.verve:
          img = 'verve.png';
          break;
        case CardType.americanExpress:
          img = 'american_express.png';
          break;
        case CardType.discover:
          img = 'discover.png';
          break;
        case CardType.dinersClub:
          img = 'dinners_club.png';
          break;
        case CardType.jcb:
          img = 'jcb.png';
          break;
      }
    }
    Widget widget;
    if (img.isNotEmpty) {
      widget = Image.asset(
        'assets/images/$img',
        key: const Key("IssuerIcon"),
        height: 15,
        width: 30,
        package: 'flutter_paystack_payment',
      );
    } else {
      widget = defaultIcon;
    }
    return widget;
  }
}
