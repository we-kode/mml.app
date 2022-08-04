import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mml_app/components/player_sheet.dart';
import 'package:mml_app/models/record.dart';

class PlayerService extends ChangeNotifier {
  static late PlayerService? _instance;
  late Record currentRecord;
  late AudioPlayer? player;

  PlayerService._() {
    player ??= AudioPlayer();
  }

  static PlayerService getInstance() {
    _instance ??= PlayerService._();

    return _instance!;
  }

  Future closePlayer() async {
    // TODO close bottom sheet
    await _dispose();
  }

  void openPlayer(BuildContext context, Record record) {
    currentRecord = record;

    showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const PlayerSheet();
      },
    );
  }

  void playOther(Record otherRecord) {
    // TODO: Check player is playing!

    currentRecord = otherRecord;

    // player!.setUrl("TODO");
  }

  void pause() {
    // TODO: Check player is playing!
  }

  void resume() {
    // TODO: Check player is playing / pausing!
  }

  void playNext() {
    // TODO: Check player is playing!
  }

  void playPrevious() {
    // TODO: Check player is playing!
  }

  void seek() {
    // TODO: Check player is playing!
  }

  set shuffle(bool value) {
    // TODO: Check player is playing!
  }

  set repeat(bool value) {
    // TODO: Check player is playing!
  }

  bool get shuffle => false;

  bool get repeat => false;

  Future _dispose() async {
    await player!.dispose();
    _instance = null;
  }
}
