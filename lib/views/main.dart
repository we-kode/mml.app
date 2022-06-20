import 'package:flutter/material.dart';
import 'package:mml_app/services/client.dart';

/// Main screen.
class MainScreen extends StatelessWidget {
  /// Initializes the instance.
  const MainScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Text('test'),
            TextButton(
              child: const Text("Remove Registration"),
              onPressed: () {
                ClientService.getInstance().removeRegistration();
              },
            ),
          ],
        ),
      ),
    );
  }
}
