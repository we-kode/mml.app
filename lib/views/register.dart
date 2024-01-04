import 'package:flutter/material.dart';
import 'package:mml_app/components/check_animation.dart';
import 'package:mml_app/components/error_animation.dart';
import 'package:mml_app/components/generate_rsa_animation.dart';
import 'package:mml_app/components/vertical_spacer.dart';
import 'package:mml_app/view_models/register.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

/// Register screen.
class RegisterScreen extends StatelessWidget {
  /// Initializes the instance.
  const RegisterScreen({super.key});

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
                          switch (vm.state) {
                            case RegistrationState.rsa:
                              return const SizedBox(
                                height: 256,
                                width: 256,
                                child: GenerateRSAAnimation(),
                              );
                            case RegistrationState.init:
                              return SizedBox(
                                width: 256,
                                child: Form(
                                  key: vm.formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextFormField(
                                        initialValue: vm.firstName,
                                        decoration: InputDecoration(
                                          labelText: vm.locales.firstName,
                                          errorMaxLines: 5,
                                        ),
                                        onSaved: (String? name) {
                                          vm.firstName = name!;
                                        },
                                        onChanged: (String? name) {
                                          vm.firstName = name;
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: vm.validateFirstName,
                                      ),
                                      verticalSpacer,
                                      TextFormField(
                                        initialValue: vm.lastName,
                                        decoration: InputDecoration(
                                          labelText: vm.locales.lastName,
                                          errorMaxLines: 5,
                                        ),
                                        onSaved: (String? name) {
                                          vm.lastName = name!;
                                        },
                                        onChanged: (String? name) {
                                          vm.lastName = name;
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: vm.validateLastName,
                                      ),
                                      verticalSpacer,
                                      ElevatedButton(
                                        onPressed: vm.saveName,
                                        child: Text(vm.locales.next),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            case RegistrationState.scan:
                              return Container(
                                height: 256,
                                width: 256,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 6.0,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: MobileScanner(
                                  controller: MobileScannerController(
                                    detectionSpeed: DetectionSpeed.noDuplicates,
                                  ),
                                  onDetect: (capture) {
                                    final Barcode barcode = capture.barcodes.first;
                                    vm.register(barcode);
                                  },
                                ),
                              );
                            case RegistrationState.register:
                              return const CircularProgressIndicator();
                            case RegistrationState.error:
                              return SizedBox(
                                height: 256,
                                width: 256,
                                child: ErrorAnimation(
                                  onStop: () async {
                                    vm.state = RegistrationState.scan;
                                  },
                                ),
                              );
                            case RegistrationState.success:
                              return SizedBox(
                                height: 256,
                                width: 256,
                                child: CheckAnimation(
                                  onStop: () async {
                                    await vm.afterRegistration();
                                  },
                                ),
                              );
                          }
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
