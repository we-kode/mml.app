// Overview screen of the uploaded records to the music lib.
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mml_app/view_models/intro.dart';
import 'package:provider/provider.dart';

/// Intro screen to describe the app for one user.
class IntroScreen extends StatelessWidget {
  /// Initializes the instance.
  const IntroScreen({super.key});

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<IntroViewModel>(
        create: (context) => IntroViewModel(),
        builder: (context, _) {
          var vm = Provider.of<IntroViewModel>(context, listen: false);

          return FutureBuilder(
            future: vm.init(context),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData || !snapshot.data!) {
                return const Center(child: CircularProgressIndicator());
              }

              return IntroductionScreen(
                pages: vm.pages,
                showNextButton: false,
                showSkipButton: true,
                done: Text(vm.locales.done),
                skip: Text(vm.locales.skip),
                onDone: vm.finish,
                onSkip: vm.finish,
                safeAreaList: const [true, true, true, true],
              );
            },
          );
        },
      ),
    );
  }
}
