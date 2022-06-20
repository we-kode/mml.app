import 'package:flutter/material.dart';
import 'package:mml_app/services/client.dart';

//TODO
class SettingsScreen extends StatelessWidget {
  /// Initializes the instance.
  const SettingsScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: const Text("Remove Registration"),
        onPressed: () {
          ClientService.getInstance().removeRegistration();
        },
      ),
    );
  }
}
