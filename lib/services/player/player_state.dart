import 'package:flutter/material.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/player/mml_audio_handler.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';

/// State of the player used to display changes on the [PlayerSheet].
class PlayerState extends ChangeNotifier {
  /// [MMLAudioHandler] that handles the play state.
  final MMLAudioHandler _audioHandler;

  /// Initializes the player state.
  PlayerState(this._audioHandler);

  /// The current played record.
  Record? get currentRecord => _audioHandler.currentRecord;

  /// The current sekk position of the played record.
  double get currentSeekPosition => _audioHandler.currentSeekPosition;

  /// Bool, that indicates, whether the record is playing or not.
  bool get isPlaying => _audioHandler.isPlaying;

  /// Repeat mode that is currently set.
  PlayerRepeatMode get repeat => _audioHandler.repeat;

  /// Bool, that indicates, whether shuffle is enabled or not.
  bool get shuffle => _audioHandler.shuffle;

  /// Indicates, that the source to be played is loading.
  bool get isLoading => _audioHandler.isLoading;

  /// Notifies for changes the listeners.
  ///
  /// Should be used if the state changes.
  void update() {
    notifyListeners();
  }
}
