import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Function called when animation ends.
typedef StopFunction = Future Function();

/// Animation for a check symbol.
class CheckAnimation extends StatefulWidget {
  /// [StopFunction] called, when animation ends.
  final StopFunction? onStop;

  /// Initializes the animation.
  const CheckAnimation({
    super.key,
    this.onStop,
  });

  @override
  CheckAnimationState createState() => CheckAnimationState();
}

/// State of the [CheckAnimation].
class CheckAnimationState extends State<CheckAnimation> {
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
      'assets/animations/check.riv',
      controllers: [_controller],
    );
  }
}
