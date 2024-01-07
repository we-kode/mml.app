import 'package:flutter/material.dart';
import 'package:mml_app/components/check_animation.dart';
import 'package:mml_app/components/error_animation.dart';
import 'package:mml_app/view_models/server_connection.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

/// Update server connection screen.
class ServerConnectionScreen extends StatelessWidget {
  /// Initializes the instance.
  const ServerConnectionScreen({super.key});

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ChangeNotifierProvider<ServerConnectionViewModel>(
          create: (context) => ServerConnectionViewModel(),
          builder: (context, _) {
            var vm = Provider.of<ServerConnectionViewModel>(context, listen: false);

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
                        vm.locales.updateConnectionSettingsTitle,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Consumer<ServerConnectionViewModel>(
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
                      child: Consumer<ServerConnectionViewModel>(
                        builder: (context, vm, _) {
                          switch (vm.state) {
                            case UpdateState.scan:
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
                                child:  MobileScanner(
                                  controller: MobileScannerController(
                                    detectionSpeed: DetectionSpeed.noDuplicates,
                                  ),
                                  onDetect: (capture) {
                                    final Barcode barcode = capture.barcodes.first;
                                    vm.updateConnectionSettings(barcode);
                                  },
                                ),
                              );
                            case UpdateState.update:
                              return const CircularProgressIndicator();
                            case UpdateState.error:
                              return SizedBox(
                                height: 256,
                                width: 256,
                                child: ErrorAnimation(
                                  onStop: () async {
                                    vm.state = UpdateState.scan;
                                  },
                                ),
                              );
                            case UpdateState.success:
                              return SizedBox(
                                height: 256,
                                width: 256,
                                child: CheckAnimation(
                                  onStop: () async {
                                    await vm.afterConnectionUpdate();
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
