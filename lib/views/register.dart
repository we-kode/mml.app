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
                      child: Consumer<RegisterViewModel>(
                        builder: (context, vm, _) {
                          Widget? child;
                          switch (vm.state) {
                            case RegistrationState.scan:
                              child = MobileScanner(
                                allowDuplicates: false,
                                onDetect: vm.register,
                              );
                              break;
                            case RegistrationState.register:
                              child = const CircularProgressIndicator();
                              break;
                            case RegistrationState.error:
                              child = const Icon(
                                Icons.error_outline_outlined,
                              );
                              break;
                            case RegistrationState.success:
                              child = const Icon(
                                Icons.check_circle_outline_outlined,
                              );
                              break;
                          }

                          return Container(
                            height: 256,
                            width: 256,
                            decoration: vm.state == RegistrationState.scan
                                ? BoxDecoration(
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 6.0,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  )
                                : null,
                            child: child,
                          );
                        },
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
