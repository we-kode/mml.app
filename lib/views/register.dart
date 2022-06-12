import 'package:flutter/material.dart';
import 'package:mml_app/view_models/register.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

/// Register screen.
class RegisterScreen extends StatelessWidget {
  /// Initializes the instance.
  const RegisterScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ChangeNotifierProvider<RegisterViewModel>(
          create: (context) => RegisterViewModel(),
          builder: (context, _) {
            var vm = Provider.of<RegisterViewModel>(context, listen: false);

            return FutureBuilder(
              future: vm.init(context),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (!snapshot.hasData || !snapshot.data!) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        vm.locales.registrationTitle,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Consumer<RegisterViewModel>(
                        builder: (context, vm, _) {
                          return Text(
                            vm.infoMessage,
                            style: Theme.of(context).textTheme.headlineSmall,
                            maxLines: 5,
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: Container(
                        height: 256,
                        width: 256,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 6.0,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Consumer<RegisterViewModel>(
                          builder: (context, vm, _) {
                            switch (vm.state) {
                              case RegistrationState.scan:
                                return MobileScanner(
                                  allowDuplicates: false,
                                  onDetect: vm.register,
                                );
                              case RegistrationState.register:
                                return const CircularProgressIndicator();
                              case RegistrationState.error:
                                return const Icon(
                                  Icons.error_outline_outlined,
                                );
                              case RegistrationState.success:
                                return const Icon(
                                  Icons.check_circle_outline_outlined,
                                );
                            }
                          },
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
