import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_payment/flutter_paystack_payment.dart';
import 'package:flutter_paystack_payment/src/ui/input/card_input.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common/widget_builder.dart';

void main() {
  group("$CardInput", () {
    const buttonText = "Pay NGN 300";
    final paymentCard = PaymentCard.empty();

    final cardInputWidget = buildTestWidget(CardInput(
      buttonText: buttonText,
      card: paymentCard,
      onValidated: (v) {},
    ));

    group("pay button", () {
      testWidgets("isDisplayed", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cardNumberFinder = find.byKey(const Key("PayButton"));
        expect(cardNumberFinder, findsOneWidget);
      });

      testWidgets("callsValidateInputs", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cardNumberFinder = find.byKey(const Key("PayButton"));
        await tester.tap(cardNumberFinder);

        await tester.pump();
        expect(find.text("Invalid card number"), findsOneWidget);
        expect(find.text("Invalid card expiry"), findsOneWidget);
        expect(find.text("Invalid cvv"), findsOneWidget);
      });
    });

    group("card number", () {
      testWidgets("isDisplayed", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cardNumberFinder = find.byKey(const Key("CardNumberKey"));
        expect(cardNumberFinder, findsOneWidget);
      });

      testWidgets("defaultIssuerIconIsDisplayed", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cardNumberFinder = find.byKey(const Key("DefaultIssuerIcon"));
        expect(cardNumberFinder, findsOneWidget);
        expect(find.byKey(const Key("IssuerIcon")), findsNothing);
      });

      testWidgets("displayErrorWithNoInput", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("PayButton")));

        await tester.pump();

        expect(find.text("Invalid card number"), findsOneWidget);
      });

      testWidgets("displayErrorWithInvalidInput", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cardNumberFinder = find.byKey(const Key("CardNumberKey"));
        await tester.enterText(cardNumberFinder, "411111111111111111");

        await tester.tap(find.byKey(const Key("PayButton")));

        await tester.pump();

        expect(find.text("Invalid card number"), findsOneWidget);
      });

      testWidgets("displaysIssuerIconWhenIncompleteNumberIsInputted",
          (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cardNumberFinder = find.byKey(const Key("CardNumberKey"));
        await tester.enterText(cardNumberFinder, "533");

        await tester.pump();

        expect(find.byKey(const Key("IssuerIcon")), findsOneWidget);
        expect(find.byKey(const Key("DefaultIssuerIcon")), findsNothing);
      });

      testWidgets("displaysNoErrorWithValidInput", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cardNumberFinder = find.byKey(const Key("CardNumberKey"));
        await tester.enterText(cardNumberFinder, "3000 0000 0000 04");

        await tester.tap(find.byKey(const Key("PayButton")));

        await tester.pump();

        expect(find.text("Invalid card number"), findsNothing);
      });
    });

    group("card expiry", () {
      testWidgets("isDisplayed", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final expiryFinder = find.byKey(const Key("ExpiryKey"));
        expect(expiryFinder, findsOneWidget);
      });

      testWidgets("displaysErrorWithEmptyInput", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("PayButton")));

        await tester.pump();

        expect(find.text("Invalid card expiry"), findsOneWidget);
      });

      testWidgets("displaysErrorWithInvalidInput", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final expiryFinder = find.byKey(const Key("ExpiryKey"));
        await tester.enterText(expiryFinder, "1365");

        await tester.tap(find.byKey(const Key("PayButton")));

        await tester.pump();

        expect(find.text("Invalid card expiry"), findsOneWidget);
      });

      testWidgets("displaysNoErrorWithValidInput", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final expiryFinder = find.byKey(const Key("ExpiryKey"));
        await tester.enterText(expiryFinder, "12/18");

        await tester.tap(find.byKey(const Key("PayButton")));

        await tester.pump();

        expect(find.text("Invalid card expiry"), findsOneWidget);
      });

      testWidgets("moreThanFourCharactersIsNotAccepted", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final expiryFinder = find.byKey(const Key("ExpiryKey"));
        await tester.enterText(expiryFinder, "12218");

        expect(find.text("12/21"), findsOneWidget);
        expect(find.text("12/218"), findsNothing);
        expect(find.text("12/18"), findsNothing);
        expect(find.text("122/18"), findsNothing);
      });
    });

    group("cvv", () {
      testWidgets("isDisplayed", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cvvFinder = find.byKey(const Key("CVVKey"));
        expect(cvvFinder, findsOneWidget);
      });

      testWidgets("displaysErrorWithEmptyInput", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("PayButton")));

        await tester.pump();

        expect(find.text("Invalid cvv"), findsOneWidget);
      });

      testWidgets("displaysErrorWithInvalidInput", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cvvFinder = find.byKey(const Key("CVVKey"));
        await tester.enterText(cvvFinder, "12");

        await tester.tap(find.byKey(const Key("PayButton")));

        await tester.pump();

        expect(find.text("Invalid cvv"), findsOneWidget);
      });

      testWidgets("displaysNoErrorWithValidInput", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cvvFinder = find.byKey(const Key("CVVKey"));
        await tester.enterText(cvvFinder, "123");

        await tester.tap(find.byKey(const Key("PayButton")));

        await tester.pump();

        expect(find.text("Invalid cvv"), findsNothing);
      });

      testWidgets("moreThanFourCharactersIsNotAccepted", (tester) async {
        await tester.pumpWidget(cardInputWidget);

        await tester.pumpAndSettle();

        final cvvFinder = find.byKey(const Key("CVVKey"));
        await tester.enterText(cvvFinder, "123456");

        expect(find.text("1234"), findsOneWidget);
        expect(find.text("12345"), findsNothing);
        expect(find.text("123456"), findsNothing);
      });
    });
  });
}
