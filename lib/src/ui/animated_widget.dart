import 'package:flutter/material.dart';
import 'package:flutter_paystack_payment/src/ui/base_widget.dart';

class CustomAnimatedWidget extends StatelessWidget {
  final CurvedAnimation _animation;
  final Widget child;

  CustomAnimatedWidget(
      {Key? key, required this.child, required AnimationController controller})
      : _animation = CurvedAnimation(
          parent: controller,
          curve: Curves.fastOutSlowIn,
        ),
        super(key: key);

  final Tween<Offset> slideTween =
      Tween(begin: const Offset(0.0, 0.02), end: Offset.zero);
  final Tween<double> scaleTween = Tween(begin: 1.04, end: 1.0);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: slideTween.animate(_animation),
        child: ScaleTransition(
          scale: scaleTween.animate(_animation),
          child: Container(
            margin: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
            child: SafeArea(top: false, bottom: false, child: child),
          ),
        ),
      ),
    );
  }
}

abstract class BaseAnimatedState<T extends StatefulWidget> extends BaseState<T>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    alwaysPop = true;
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget buildChild(BuildContext context) {
    return CustomAnimatedWidget(
      controller: controller,
      child: buildAnimatedChild(),
    );
  }

  Widget buildAnimatedChild();
}
