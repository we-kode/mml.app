import 'package:flutter/material.dart';
import 'package:mml_app/components/soundwave_animation.dart';
import 'package:mml_app/extensions/duration_double.dart';
import 'package:mml_app/models/livestream.dart';
import 'package:mml_app/models/local_record.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';
import 'package:mml_app/services/player/player_state.dart';
import 'package:mml_app/services/playlist.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:text_scroll/text_scroll.dart';

/// Player sheet shown in the bottom sheet bar.
class PlayerSheet extends StatefulWidget {
  /// Initializes the player sheet.
  const PlayerSheet({Key? key}) : super(key: key);

  @override
  PlayerSheetState createState() => PlayerSheetState();
}

/// State of the player sheet.
class PlayerSheetState extends State<PlayerSheet>
    with TickerProviderStateMixin {
  /// Controller used to animate the play/pause button.
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerService.getInstance().playerState,
      builder: (BuildContext context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomAppBarColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: kElevationToShadow[8],
          ),
          constraints: const BoxConstraints(
            maxHeight: 160,
            minHeight: 0.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    constraints: const BoxConstraints.tightFor(
                      width: 24,
                      height: 24,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      PlayerService.getInstance().closePlayer();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 25,
                  right: 25,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return Flexible(
                          fit: FlexFit.tight,
                          flex: 8,
                          child: TextScroll(
                            state.currentRecord?.title ??
                                AppLocalizations.of(context)!.unknown,
                            style: Theme.of(context).textTheme.titleMedium,
                            velocity: const Velocity(
                              pixelsPerSecond: Offset(15, 0),
                            ),
                            mode: TextScrollMode.bouncing,
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return state.currentRecord is Livestream
                            ? const Icon(Icons.sensors)
                            : Text(
                                "${state.currentSeekPosition.asFormattedDuration()}/${state.currentRecord?.duration?.asFormattedDuration()}",
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 25,
                  right: 25,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return state.currentRecord is Livestream
                            ? Container()
                            : Text(
                                state.currentRecord?.artist ??
                                    AppLocalizations.of(context)!.unknown,
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 12.5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Consumer<PlayerState>(
                        builder: (context, state, child) {
                          return state.currentRecord is Livestream
                              ? Center(
                                  child: SizedBox.fromSize(
                                    size: const Size(256, 64),
                                    child: const SoundwaveAnimation(),
                                  ),
                                )
                              : Slider(
                                  value: state.currentSeekPosition,
                                  min: 0,
                                  max: state.currentRecord?.duration ?? 0,
                                  onChanged: (value) {
                                    PlayerService.getInstance().seek(
                                      value,
                                    );
                                  },
                                  onChangeStart: (value) {
                                    PlayerService.getInstance().startSeekDrag();
                                  },
                                  onChangeEnd: (value) {
                                    PlayerService.getInstance().seek(
                                      value,
                                      updatePlayerSeek: true,
                                    );
                                  },
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 25,
                  right: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return state.currentRecord is Livestream
                            ? Container()
                            : IconButton(
                                constraints: const BoxConstraints.tightFor(
                                  width: 24,
                                  height: 24,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  PlayerService.getInstance().shuffle =
                                      !state.shuffle;
                                },
                                icon: Icon(
                                  state.shuffle
                                      ? Icons.shuffle_on_rounded
                                      : Icons.shuffle_rounded,
                                ),
                              );
                      },
                    ),
                    const Spacer(
                      flex: 16,
                    ),
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return state.currentRecord is Livestream
                            ? Container()
                            : IconButton(
                                constraints: const BoxConstraints.tightFor(
                                  width: 32,
                                  height: 32,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: state.shuffle || state.isLoading
                                    ? null
                                    : () => PlayerService.getInstance()
                                        .playPrevious(),
                                iconSize: 32,
                                icon: const Icon(Icons.skip_previous_rounded),
                              );
                      },
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return state.currentRecord is Livestream
                            ? Container()
                            : IconButton(
                                constraints: const BoxConstraints.tightFor(
                                  width: 32,
                                  height: 32,
                                ),
                                iconSize: 32,
                                padding: EdgeInsets.zero,
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        PlayerService.getInstance().rewind();
                                      },
                                icon: const Icon(Icons.replay_10),
                              );
                      },
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        if (!state.isPlaying &&
                            _controller.value == _controller.lowerBound) {
                          _controller.forward();
                        } else if (state.isPlaying &&
                            _controller.value == _controller.upperBound) {
                          _controller.reverse();
                        }

                        return state.currentRecord is Livestream
                            ? Container()
                            : IconButton(
                                constraints: const BoxConstraints.tightFor(
                                  width: 36,
                                  height: 36,
                                ),
                                iconSize: 36,
                                padding: EdgeInsets.zero,
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        if (state.isPlaying) {
                                          PlayerService.getInstance().pause();
                                        } else {
                                          PlayerService.getInstance().resume();
                                        }
                                      },
                                icon: AnimatedIcon(
                                  icon: AnimatedIcons.pause_play,
                                  progress: _controller,
                                  size: 36,
                                ),
                              );
                      },
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return state.currentRecord is Livestream
                            ? Container()
                            : IconButton(
                                constraints: const BoxConstraints.tightFor(
                                  width: 32,
                                  height: 32,
                                ),
                                iconSize: 32,
                                padding: EdgeInsets.zero,
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        PlayerService.getInstance()
                                            .fastForward();
                                      },
                                icon: const Icon(Icons.forward_10),
                              );
                      },
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return state.currentRecord is Livestream
                            ? Container()
                            : IconButton(
                                constraints: const BoxConstraints.tightFor(
                                  width: 32,
                                  height: 32,
                                ),
                                iconSize: 32,
                                padding: EdgeInsets.zero,
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        PlayerService.getInstance().playNext();
                                      },
                                icon: const Icon(Icons.skip_next_rounded),
                              );
                      },
                    ),
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return PlayerService.getInstance()
                                .playerState
                                ?.currentRecord is LocalRecord
                            ? const Spacer(
                                flex: 18,
                              )
                            : const Spacer(
                                flex: 6,
                              );
                      },
                    ),
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return state.currentRecord is Livestream
                            ? Container()
                            : IconButton(
                                constraints: const BoxConstraints.tightFor(
                                  width: 24,
                                  height: 24,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: state.shuffle
                                    ? null
                                    : () {
                                        var nextModeIndex =
                                            (state.repeat.index + 1) %
                                                PlayerRepeatMode.values.length;
                                        PlayerService.getInstance().repeat =
                                            PlayerRepeatMode
                                                .values[nextModeIndex];
                                      },
                                icon: Icon(
                                  state.repeat == PlayerRepeatMode.all
                                      ? Icons.repeat_on_rounded
                                      : (state.repeat == PlayerRepeatMode.one
                                          ? Icons.repeat_one_on_rounded
                                          : Icons.repeat_rounded),
                                ),
                              );
                      },
                    ),
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return PlayerService.getInstance()
                                    .playerState
                                    ?.currentRecord is LocalRecord ||
                                state.currentRecord is Livestream
                            ? Container()
                            : const Spacer(
                                flex: 4,
                              );
                      },
                    ),
                    Consumer<PlayerState>(
                      builder: (context, state, child) {
                        return PlayerService.getInstance()
                                    .playerState
                                    ?.currentRecord is LocalRecord ||
                                state.currentRecord is Livestream
                            ? Container()
                            : IconButton(
                                constraints: const BoxConstraints.tightFor(
                                  width: 32,
                                  height: 32,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  PlaylistService.getInstance()
                                      .downloadRecords([
                                    PlayerService.getInstance()
                                        .playerState
                                        ?.currentRecord,
                                  ], context);
                                },
                                icon: FutureBuilder<bool>(
                                  future:
                                      PlaylistService.getInstance().isFavorite(
                                    PlayerService.getInstance()
                                        .playerState
                                        ?.currentRecord
                                        ?.recordId,
                                  ),
                                  builder: (context, snapshot) {
                                    return snapshot.hasData &&
                                            (snapshot.data ?? false)
                                        ? const Icon(Icons.star)
                                        : const Icon(Icons.star_outline);
                                  },
                                ),
                              );
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
