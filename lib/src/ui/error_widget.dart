import 'package:flutter/material.dart';
import 'package:flutter_paystack_payment/src/common/paystack.dart';
import 'package:flutter_paystack_payment/src/ui/animated_widget.dart';
import 'package:flutter_paystack_payment/src/ui/buttons.dart';

class ErrorWidget extends StatelessWidget {
  final TickerProvider vSync;
  final AnimationController controller;
  final CheckoutMethod method;
  final String? text;
  final VoidCallback? payWithBank;
  final VoidCallback? tryAnotherCard;
  final VoidCallback? startOverWithCard;
  final bool isCardPayment;

  ErrorWidget({
    Key? key,
    required this.text,
    required this.vSync,
    required this.method,
    required this.isCardPayment,
    this.payWithBank,
    this.tryAnotherCard,
    this.startOverWithCard,
  })  : controller = AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: vSync,
        ),
        super(key: key) {
    controller.forward();
  }

  final emptyContainer = Container();

  @override
  Widget build(BuildContext context) {
    // Remove 'Retry buttons for bank payment because when you retry a transaction it ret
    var buttonMargin =
        isCardPayment ? const SizedBox(height: 5.0) : emptyContainer;
    return CustomAnimatedWidget(
      controller: controller,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.warning,
            size: 50.0,
            color: Color(0xFFf9a831),
          ),
          const SizedBox(height: 10.0),
          Text(
            text!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 25.0),
          isCardPayment
              ? WhiteButton(onPressed: tryAnotherCard, text: 'Try another card')
              : emptyContainer,
          buttonMargin,
          method == CheckoutMethod.selectable || method == CheckoutMethod.bank
              ? WhiteButton(
                  onPressed: payWithBank,
                  text: method == CheckoutMethod.bank || !isCardPayment
                      ? 'Retry'
                      : 'Try paying with your bank account',
                )
              : emptyContainer,
          buttonMargin,
          isCardPayment
              ? WhiteButton(
                  onPressed: startOverWithCard,
                  text: 'Start over with same card',
                  icondata: Icons.refresh,
                  bold: false,
                  flat: true,
                )
              : emptyContainer
        ],
      ),
    );
  }
}
