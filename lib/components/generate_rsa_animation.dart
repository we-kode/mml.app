import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mml_app/gen/assets.gen.dart';

/// Animation for the rsa key generation.
class GenerateRSAAnimation extends StatelessWidget {
  /// Initializes the animation.
  const GenerateRSAAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      Assets.animations.lock,
      repeat: true,
      animate: true,
      fit: BoxFit.contain,
    );
  }
}
