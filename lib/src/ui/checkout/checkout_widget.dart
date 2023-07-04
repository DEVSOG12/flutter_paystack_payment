// ignore_for_file: library_private_types_in_public_api, no_logic_in_create_state

import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_paystack_payment/src/api/service/contracts/banks_service_contract.dart';
import 'package:flutter_paystack_payment/src/api/service/contracts/cards_service_contract.dart';
import 'package:flutter_paystack_payment/src/common/paystack.dart';
import 'package:flutter_paystack_payment/src/common/utils.dart';
import 'package:flutter_paystack_payment/src/models/card.dart';
import 'package:flutter_paystack_payment/src/models/charge.dart';
import 'package:flutter_paystack_payment/src/models/checkout_response.dart';
import 'package:flutter_paystack_payment/src/ui/base_widget.dart';
import 'package:flutter_paystack_payment/src/ui/checkout/bank_checkout.dart';
import 'package:flutter_paystack_payment/src/ui/checkout/card_checkout.dart';
import 'package:flutter_paystack_payment/src/ui/checkout/checkout_method.dart';
import 'package:flutter_paystack_payment/src/ui/custom_dialog.dart';
import 'package:flutter_paystack_payment/src/ui/error_widget.dart';
import 'package:flutter_paystack_payment/src/ui/sucessful_widget.dart';

const kFullTabHeight = 74.0;

class CheckoutWidget extends StatefulWidget {
  final CheckoutMethod method;
  final Charge charge;
  final bool fullscreen;
  final Widget? logo;
  final bool hideEmail;
  final bool hideAmount;
  final bool scanCard;
  final BankServiceContract bankService;
  final CardServiceContract cardsService;
  final String publicKey;

  const CheckoutWidget({
    Key? key,
    required this.method,
    required this.charge,
    required this.bankService,
    required this.scanCard,
    required this.cardsService,
    required this.publicKey,
    this.fullscreen = false,
    this.logo,
    this.hideEmail = false,
    this.hideAmount = false,
  }) : super(key: key);

  @override
  _CheckoutWidgetState createState() => _CheckoutWidgetState(charge);
}

class _CheckoutWidgetState extends BaseState<CheckoutWidget>
    with TickerProviderStateMixin {
  static const tabBorderRadius = BorderRadius.all(Radius.circular(4.0));
  final Charge _charge;
  int? _currentIndex = 0;
  var _showTabs = true;
  String? _paymentError;
  bool _paymentSuccessful = false;
  TabController? _tabController;
  late List<MethodItem> _methodWidgets;
  double _tabHeight = kFullTabHeight;
  late AnimationController _animationController;
  CheckoutResponse? _response;

  _CheckoutWidgetState(this._charge);

  @override
  void initState() {
    super.initState();
    _init();
    _initPaymentMethods();
    _currentIndex = _getCurrentTab();
    _showTabs = widget.method == CheckoutMethod.selectable ? true : false;
    _tabController = TabController(
        vsync: this,
        length: _methodWidgets.length,
        initialIndex: _currentIndex!);
    _tabController!.addListener(_indexChange);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _charge.card ??= PaymentCard.empty();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget buildChild(BuildContext context) {
    var securedWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.lock, size: 10),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 3),
              child: Text(
                "Secured by",
                key: Key("SecuredBy"),
                style: TextStyle(fontSize: 10),
              ),
            )
          ],
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.logo != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 3),
                child: Image.asset(
                  'assets/images/paystack_icon.png',
                  key: const Key("PaystackBottomIcon"),
                  package: 'flutter_paystack_payment',
                  height: 16,
                ),
              ),
            Image.asset(
              'assets/images/paystack.png',
              key: const Key("PaystackLogo"),
              package: 'flutter_paystack_payment',
              height: 15,
            )
          ],
        )
      ],
    );
    return CustomAlertDialog(
      expanded: true,
      fullscreen: widget.fullscreen,
      titlePadding: const EdgeInsets.all(0.0),
      onCancelPress: onCancelPress,
      title: _buildTitle(),
      content: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: Column(
                children: <Widget>[
                  _showProcessingError()
                      ? _buildErrorWidget()
                      : _paymentSuccessful
                          ? _buildSuccessfulWidget()
                          : _methodWidgets[_currentIndex!].child,
                  const SizedBox(height: 20),
                  securedWidget
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final accentColor = Theme.of(context).colorScheme.secondary;
    var emailAndAmount = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (!widget.hideEmail && _charge.email != null)
          Text(
            _charge.email!,
            key: const Key("ChargeEmail"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
        if (!widget.hideAmount && !_charge.amount.isNegative)
          Row(
            key: const Key("DisplayAmount"),
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Pay',
                style: TextStyle(fontSize: 14.0, color: Colors.black54),
              ),
              const SizedBox(
                width: 5.0,
              ),
              Flexible(
                  child: Text(Utils.formatAmount(_charge.amount),
                      style: TextStyle(
                          fontSize: 15.0,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontWeight: FontWeight.w500)))
            ],
          )
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (widget.logo == null)
                Image.asset(
                  'assets/images/paystack_icon.png',
                  key: const Key("PaystackIcon"),
                  package: 'flutter_paystack_payment',
                  width: 25,
                )
              else
                SizedBox(
                  key: const Key("Logo"),
                  child: widget.logo,
                ),
              const SizedBox(
                width: 50,
              ),
              Expanded(child: emailAndAmount),
            ],
          ),
        ),
        if (_showTabs) buildCheckoutMethods(accentColor)
      ],
    );
  }

  Widget buildCheckoutMethods(Color accentColor) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      // vsync: this,
      curve: Curves.fastOutSlowIn,
      child: Container(
        color: Colors.grey.withOpacity(0.1),
        height: _tabHeight,
        alignment: Alignment.center,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          unselectedLabelColor: Colors.black54,
          labelColor: accentColor,
          labelStyle:
              const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          indicator: ShapeDecoration(
            shape: RoundedRectangleBorder(
                  borderRadius: tabBorderRadius,
                  side: BorderSide(
                    color: accentColor,
                    width: 1.0,
                  ),
                ) +
                const RoundedRectangleBorder(
                  borderRadius: tabBorderRadius,
                  side: BorderSide(
                    color: Colors.transparent,
                    width: 6.0,
                  ),
                ),
          ),
          tabs: _methodWidgets.map<Tab>((MethodItem m) {
            return Tab(
              text: m.text,
              icon: Icon(
                m.icon,
                size: 24.0,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _indexChange() {
    setState(() {
      _currentIndex = _tabController!.index;
      // Update the checkout here just in case the user terminates the transaction
      // forcefully by tapping the close icon
    });
  }

  void _initPaymentMethods() {
    _methodWidgets = [
      MethodItem(
          text: 'Card',
          icon: Icons.credit_card,
          child: CardCheckout(
            key: const Key("CardCheckout"),
            publicKey: widget.publicKey,
            service: widget.cardsService,
            charge: _charge,
            scanCard: widget.scanCard,
            onProcessingChange: _onProcessingChange,
            onResponse: _onPaymentResponse,
            hideAmount: widget.hideAmount,
            onCardChange: (PaymentCard? card) {
              if (card == null) return;
              _charge.card!.number = card.number;
              _charge.card!.cvc = card.cvc;
              _charge.card!.expiryMonth = card.expiryMonth;
              _charge.card!.expiryYear = card.expiryYear;
            },
          )),
      MethodItem(
        text: 'Bank',
        icon: Icons.account_balance,
        child: BankCheckout(
          publicKey: widget.publicKey,
          charge: _charge,
          service: widget.bankService,
          onResponse: _onPaymentResponse,
          onProcessingChange: _onProcessingChange,
        ),
      )
    ];
  }

  void _onProcessingChange(bool processing) {
    setState(() {
      _tabHeight = processing || _paymentSuccessful || _showProcessingError()
          ? 0.0
          : kFullTabHeight;
      processing = processing;
    });
  }

  _showProcessingError() {
    return !(_paymentError == null || _paymentError!.isEmpty);
  }

  void _onPaymentResponse(CheckoutResponse response) {
    _response = response;
    if (!mounted) return;
    if (response.status == true) {
      _onPaymentSuccess();
    } else {
      _onPaymentError(response.message);
    }
  }

  void _onPaymentSuccess() {
    setState(() {
      _paymentSuccessful = true;
      _paymentError = null;
      _onProcessingChange(false);
    });
  }

  void _onPaymentError(String? value) {
    setState(() {
      _paymentError = value;
      _paymentSuccessful = false;
      _onProcessingChange(false);
    });
  }

  int? _getCurrentTab() {
    int? checkedTab;
    switch (widget.method) {
      case CheckoutMethod.selectable:
      case CheckoutMethod.card:
        checkedTab = 0;
        break;
      case CheckoutMethod.bank:
        checkedTab = 1;
        break;
    }
    return checkedTab;
  }

  Widget _buildErrorWidget() {
    _initPaymentMethods();
    // ignore: no_leading_underscores_for_local_identifiers
    void _resetShowTabs() {
      _response = null; // Reset the response
      _showTabs = widget.method == CheckoutMethod.selectable ? true : false;
    }

    return ErrorWidget(
      text: _paymentError,
      method: widget.method,
      isCardPayment: _charge.card!.isValid(),
      vSync: this,
      payWithBank: () {
        setState(() {
          _resetShowTabs();
          _onPaymentError(null);
          _charge.card = PaymentCard.empty();
          _tabController!.index = 1;
          _paymentError = null;
        });
      },
      tryAnotherCard: () {
        setState(() {
          _resetShowTabs();
          _onPaymentError(null);
          _charge.card = PaymentCard.empty();
          _tabController!.index = 0;
        });
      },
      startOverWithCard: () {
        _resetShowTabs();
        _onPaymentError(null);
        _tabController!.index = 0;
      },
    );
  }

  Widget _buildSuccessfulWidget() => SuccessfulWidget(
        amount: _charge.amount,
        onCountdownComplete: () {
          if (_response!.card != null) {
            _response!.card!.nullifyNumber();
          }
          Navigator.of(context).pop(_response);
        },
      );

  @override
  getPopReturnValue() {
    return _getResponse();
  }

  CheckoutResponse _getResponse() {
    CheckoutResponse? response = _response;
    if (response == null) {
      response = CheckoutResponse.defaults();
      response.method = _tabController!.index == 0
          ? CheckoutMethod.card
          : CheckoutMethod.bank;
    }
    if (response.card != null) {
      response.card!.nullifyNumber();
    }
    return response;
  }

  _init() {
    Utils.setCurrencyFormatter(_charge.currency, _charge.locale);
  }
}

typedef OnResponse<CheckoutResponse> = void Function(CheckoutResponse response);
