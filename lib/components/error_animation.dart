import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Function called when animation ends.
typedef StopFunction = Future Function();

/// Animation for a error symbol.
class ErrorAnimation extends StatefulWidget {
  /// [StopFunction] called, when animation ends.
  final StopFunction? onStop;

  /// Initializes the animation.
  const ErrorAnimation({
    super.key,
    this.onStop,
  });

  @override
  ErrorAnimationState createState() => ErrorAnimationState();
}

/// State of the [ErrorAnimation].
class ErrorAnimationState extends State<ErrorAnimation> {
  /// Controller for playback
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OneShotAnimation('show', onStop: () async {
      if (widget.onStop != null) {
        await widget.onStop!();
      }
      setState(() => {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      'assets/animations/error.riv',
      controllers: [_controller],
    );
  }
}
