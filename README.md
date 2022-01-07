#  A Paystack Plugin for Flutter Apps

Flutter plugin for making payments with Paystack Payment System. Fully
supports all platform.


## Features
Current
- Card
- Bank

In Development
- USSD
- QR Code
- Mobile Money


## Installation
To use this plugin, add `flutter_paystack_payment` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

Then initialize the plugin preferably in the `initState` of your widget.

``` dart
import 'package:flutter_paystack_payment/flutter_paystack_payment.dart';

class _ExamplePayementPageState extends State<ExamplePayementPage> {
  var publicKey = 'Add your Paystack Public Key Here';
  final plugin = PaystackPayment();

  @override
  void initState() {
    plugin.initialize(publicKey: publicKey);
  }
}
```

## Making Payments
There are two ways of making payment with the plugin.
1.  **Checkout**: This is the easy way; as the plugin handles all the
    processes involved in making a payment (except transaction
    initialization and verification which should be done from your
    backend).
2.  **Charge Card**: This is a longer approach; you handle all callbacks
    and UI states.

### 1. Checkout (Recommended)
 You initialize a charge object with an amount, email & accessCode or
 reference. Pass an `accessCode` only when you have
 [initialized the transaction](https://developers.paystack.co/reference#initialize-a-transaction)
 from your backend. Otherwise, pass a `reference`.
 

 ```dart
 Charge charge = Charge()
       ..amount = 10000
       ..reference = _getReference()
        // or ..accessCode = _getAccessCodeFrmInitialization()
       ..email = 'customer@email.com';
     CheckoutResponse response = await plugin.checkout(
       context context,
       method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
       charge: charge,
     );
 ```

Please, note that an `accessCode` is required if the method is
`CheckoutMethod.bank` or `CheckoutMethod.selectable`.

 `plugin.checkout()` returns the state and details of the
 payment in an instance of `CheckoutResponse` .
 
 
 It is recommended that when `plugin.checkout()` returns, the
 payment should be
 [verified](https://developers.paystack.co/v2.0/reference#verify-transaction)
 on your backend.

### 2. Charge Card
You can choose to initialize the payment locally or via your backend.

#### A. Initialize Via Your Backend (Recommended)

1.a. This starts by making a HTTP POST request to
[paystack](https://developers.paystack.co/reference#initialize-a-transaction)
on your backend.

1.b If everything goes well, the initialization request returns a response with an `access_code`.
You can then create a `Charge` object with the access code and card details. The `charge` is in turn passed to the `plugin.chargeCard()` function for payment:

```dart
  PaymentCard _getCardFromUI() {
    // Using just the must-required parameters.
    return PaymentCard(
      number: cardNumber,
      cvc: cvv,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
    );
  }

  _chargeCard(String accessCode) async {
    var charge = Charge()
      ..accessCode = accessCode
      ..card = _getCardFromUI();

    final response = await plugin.chargeCard(context, charge: charge);
    // Use the response
  }
```
The transaction is successful if `response.status` is true.



#### 2. Initialize Locally
Just send the payment details to  `plugin.chargeCard`
```dart
      // Set transaction params directly in app (note that these params
      // are only used if an access_code is not set. In debug mode,
      // setting them after setting an access code would throw an error
      Charge charge = Charge();
      charge.card = _getCardFromUI();
      charge
        ..amount = 2000
        ..email = 'user@email.com'
        ..reference = _getReference()
        ..putCustomField('Charged From', 'Flutter PLUGIN');
      _chargeCard();
```


## Validating Card Details
You are expected but not required to build the UI for your users to enter their payment details.
For easier validation, wrap the **TextFormField**s inside a **Form** widget. Please check this article on
[validating forms on Flutter](https://medium.freecodecamp.org/how-to-validate-forms-and-user-input-the-easy-way-using-flutter-e301a1531165)
if this is new to you.

**NOTE:** You don't have to pass a card object to ``Charge``. The plugin will call-up a UI for the user to input their card.

You can validate the fields with these methods:
#### card.validNumber
This method helps to perform a check if the card number is valid.

#### card.validCVC
Method that checks if the card security code is valid.

#### card.validExpiryDate
Method checks if the expiry date (combination of year and month) is valid.

#### card.isValid
Method to check if the card is valid. Always do this check, before charging the card.


#### card.getType
This method returns an estimate of the string representation of the card type(issuer).


## Verifying Transactions
This is quite easy. Just send a HTTP GET request to `https://api.paystack.co/transaction/verify/$[TRANSACTION_REFERENCE]`.
Please, check the  [official documentaion](https://developers.paystack.co/reference#verifying-transactions) on verifying transactions.

##  Testing your implementation
Paystack provides tons of [payment cards](https://developers.paystack.co/docs/test-cards) for testing.

## Running Example project
For help getting started with Flutter, view the online [documentation](https://flutter.dev).

An [example project](https://github.com/DEVSOG12/flutter_paystack_payment/tree/master/example) has been provided in this plugin.
Clone this repo and navigate to the **example** folder. Open it with a supported IDE or execute `flutter run` from that folder in terminal.

## Contributing, Issues and Bug Reports
The project is open to public contribution. Please feel very free to contribute.
Experienced an issue or want to report a bug? Please, [report it here](https://github.com/DEVSOG12/flutter_paystack/issues). Remember to be as descriptive as possible.

## Credits
Thanks to the author of the initial [Paystack Plugin](https://github.com/wilburt/flutter_paystack) [@wilburt](https://github.com/wilburt), I really build it upon his work.