import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/constants/mml_media_constants.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/services/player/mml_audio_handler.dart';

void main() {
  Future<MMLAudioHandler> createHandler(WidgetTester tester) async {
    late MMLAudioHandler handler;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            handler = MMLAudioHandler(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return handler;
  }

  testWidgets('getChildren publishes an error instead of throwing when not '
      'registered', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final handler = await createHandler(tester);

    final items = await tester.runAsync(
      () => handler.getChildren(AudioService.browsableRootId),
    );

    expect(items, isEmpty);
    final state = handler.playbackState.value;
    expect(state.processingState, AudioProcessingState.error);
    expect(
      state.errorCode,
      int.parse(MMLMediaConstants.errorCodeAuthenticationExpired),
    );
    expect(state.errorMessage, isNotEmpty);
  });

  testWidgets('search publishes an error instead of throwing when not '
      'registered', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final handler = await createHandler(tester);

    final items = await tester.runAsync(() => handler.search('test'));

    expect(items, isEmpty);
    expect(
      handler.playbackState.value.processingState,
      AudioProcessingState.error,
    );
  });
}
