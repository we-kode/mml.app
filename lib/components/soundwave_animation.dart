import 'package:material_ui/material_ui.dart';
import 'package:lottie/lottie.dart';
import 'package:mml_app/gen/assets.gen.dart';

/// Animation for the livestream.
class SoundwaveAnimation extends StatelessWidget {
  /// Whether the animation is running.
  final bool animate;

  /// Initializes the animation.
  const SoundwaveAnimation({super.key, this.animate = true});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      Assets.animations.soundwave,
      repeat: true,
      animate: animate,
      fit: BoxFit.contain,
    );
  }
}
