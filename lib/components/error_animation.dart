import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mml_app/gen/assets.gen.dart';

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
class ErrorAnimationState extends State<ErrorAnimation>
    with SingleTickerProviderStateMixin {
  /// Controller for playback
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (widget.onStop != null) {
          await widget.onStop!();
        }
        setState(() => {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      Assets.animations.error,
      controller: _controller,
      repeat: false,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        _controller.forward(from: 0);
      },
      fit: BoxFit.contain,
    );
  }
}
