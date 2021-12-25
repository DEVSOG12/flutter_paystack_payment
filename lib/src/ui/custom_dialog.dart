import 'dart:math' as math;

import 'package:flutter/material.dart';

/// This is a modification of [AlertDialog]. A lot of modifications was made. The goal is
/// to retain the dialog feel and look while adding the close IconButton
class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    Key? key,
    this.title,
    this.titlePadding,
    this.onCancelPress,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 10.0),
    this.expanded = false,
    this.fullscreen = false,
    required this.content,
  }) : super(key: key);

  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final Widget content;
  final EdgeInsetsGeometry contentPadding;
  final VoidCallback? onCancelPress;
  final bool expanded;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    if (title != null && titlePadding != null) {
      children.add(Padding(
        padding: titlePadding!,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.headline6!,
          child: Semantics(child: title, namesRoute: true),
        ),
      ));
    }

    children.add(Flexible(
      child: Padding(
        padding: contentPadding,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.subtitle1!,
          child: content,
        ),
      ),
    ));

    return buildContent(context, children);
  }

  Widget buildContent(context, List<Widget> children) {
    Widget widget;
    if (fullscreen) {
      widget = Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        // ? Colors.white
        // : Colors.grey,
        child: Container(
            child: onCancelPress == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onCancelPress,
                          color: Colors.black54,
                          padding: const EdgeInsets.all(15.0),
                          iconSize: 30.0,
                        ),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: children,
                        ),
                      ))
                    ],
                  )),
      );
    } else {
      var body = Material(
        type: MaterialType.card,
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
      var child = IntrinsicWidth(
        child: onCancelPress == null
            ? body
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: IconButton(
                        highlightColor: Colors.white54,
                        splashColor: Colors.white54,
                        color: Colors.white,
                        iconSize: 30.0,
                        padding: const EdgeInsets.all(3.0),
                        icon: const Icon(
                          Icons.cancel,
                        ),
                        onPressed: onCancelPress),
                  ),
                  Flexible(child: body),
                ],
              ),
      );
      widget = CustomDialog(child: child, expanded: expanded);
    }
    return widget;
  }
}

/// This is a modification of [Dialog]. The only modification is increasing the
/// elevation and changing the Material type.
class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    required this.child,
    required this.expanded,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
  }) : super(key: key);

  final Widget child;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: expanded
                    ? math.min(
                        (MediaQuery.of(context).size.width - 40.0), 332.0)
                    : 280.0),
            child: Material(
              elevation: 50.0,
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
