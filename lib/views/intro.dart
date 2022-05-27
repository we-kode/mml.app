// Overview screen of the uploaded records to the music lib.
import 'package:flutter/material.dart';

/// Intro screen to describe the app for one user.
class IntroScreen extends StatelessWidget {
  /// Initializes the instance.
  const IntroScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text("Intro comes here"),
        ),
      ),
    );
  }
}
