import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mml_app/components/soundwave_animation.dart';
import 'package:mml_app/extensions/duration_double.dart';
import 'package:mml_app/models/livestream.dart';
import 'package:mml_app/models/local_record.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';
import 'package:mml_app/services/player/player_state.dart';
import 'package:mml_app/services/playlist.dart';
import 'package:mml_app/services/share.dart';
import 'package:mml_app/services/share_link.dart';
import 'package:provider/provider.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';

/// Player sheet shown in the bottom sheet bar.
class PlayerSheet extends StatefulWidget {
  /// Initializes the player sheet.
  const PlayerSheet({super.key});

  @override
  PlayerSheetState createState() => PlayerSheetState();
}

/// State of the player sheet.
class PlayerSheetState extends State<PlayerSheet>
    with TickerProviderStateMixin {
  /// Controller used to animate the play/pause button.
  late AnimationController _controller;

  final TapGestureRecognizer _speedRecognizer = TapGestureRecognizer()
    ..onTap = () => PlayerService.getInstance().speedUp();

  String? _favoriteRecordId;

  Future<bool>? _favoriteFuture;

  Future<bool> _isFavorite(String? recordId) {
    if (_favoriteFuture == null || _favoriteRecordId != recordId) {
      _favoriteRecordId = recordId;
      _favoriteFuture = PlaylistService.getInstance().isFavorite(recordId);
    }

    return _favoriteFuture!;
  }

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
    _speedRecognizer.dispose();
    super.dispose();
  }

  /// Height below which the compact layout is used, e.g. phones in landscape.
  static const double _compactHeight = 500;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerService.getInstance().playerState,
      builder: (BuildContext context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: kElevationToShadow[10],
          ),
          constraints: const BoxConstraints(maxHeight: 200, minHeight: 0.0),
          child: MediaQuery.sizeOf(context).height < _compactHeight
              ? _compactLayout()
              : _defaultLayout(),
        );
      },
    );
  }

  Widget _defaultLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: _actions(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(fit: FlexFit.tight, flex: 8, child: _title()),
              const Spacer(),
              _time(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [_artist(), const Spacer(), _speed()],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [Expanded(child: _slider())],
          ),
        ),
        Row(mainAxisSize: MainAxisSize.min, children: _controls()),
      ],
    );
  }

  Widget _compactLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [_title(), _artist()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [_time(), _speed()],
                ),
              ),
              ..._actions(),
            ],
          ),
        ),
        Row(
          children: [
            ..._controls(),
            Expanded(child: _slider()),
          ],
        ),
      ],
    );
  }

  List<Widget> _actions() {
    return [
      Consumer<PlayerState>(
        builder: (context, state, child) {
          return state.currentRecord is LocalRecord ||
                  state.currentRecord is Livestream
              ? Container()
              : ValueListenableBuilder<bool>(
                  valueListenable: ShareService.getInstance().supported,
                  builder: (context, supported, _) => supported
                      ? IconButton(
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          tooltip: AppLocalizations.of(context)!.sharePlayLink,
                          onPressed: () => ShareLinkService.getInstance()
                              .shareRecord(context),
                          icon: const Icon(Symbols.dataset_linked),
                        )
                      : const SizedBox.shrink(),
                );
        },
      ),
      Consumer<PlayerState>(
        builder: (context, state, child) {
          return PlayerService.getInstance().playerState?.currentRecord
                      is LocalRecord ||
                  state.currentRecord is Livestream
              ? Container()
              : IconButton(
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    await PlaylistService.getInstance().downloadRecords([
                      PlayerService.getInstance().playerState?.currentRecord,
                    ], context);
                    if (mounted) {
                      setState(() => _favoriteFuture = null);
                    }
                  },
                  icon: FutureBuilder<bool>(
                    future: _isFavorite(
                      PlayerService.getInstance()
                          .playerState
                          ?.currentRecord
                          ?.recordId,
                    ),
                    builder: (context, snapshot) {
                      return snapshot.hasData && (snapshot.data ?? false)
                          ? const Icon(Symbols.star, fill: 1)
                          : const Icon(Symbols.star);
                    },
                  ),
                );
        },
      ),
      IconButton(
        constraints: const BoxConstraints.tightFor(width: 24, height: 24),
        padding: EdgeInsets.zero,
        onPressed: () {
          PlayerService.getInstance().closePlayer();
        },
        icon: const Icon(Symbols.close),
      ),
    ];
  }

  Widget _title() {
    return Consumer<PlayerState>(
      builder: (context, state, child) {
        return Tooltip(
          message:
              state.currentRecord?.title ??
              AppLocalizations.of(context)!.unknown,
          triggerMode: TooltipTriggerMode.tap,
          child: Text(
            state.currentRecord?.title ?? AppLocalizations.of(context)!.unknown,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _time() {
    return Consumer<PlayerState>(
      builder: (context, state, child) {
        return state.currentRecord is Livestream
            ? const Icon(Symbols.sensors)
            : ValueListenableBuilder<double>(
                valueListenable: state.position,
                builder: (context, position, _) => Text(
                  "${position.asFormattedDuration()}/${state.currentRecord?.duration?.asFormattedDuration()}",
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
      },
    );
  }

  Widget _artist() {
    return Consumer<PlayerState>(
      builder: (context, state, child) {
        return state.currentRecord is Livestream
            ? Container()
            : Text(
                state.currentRecord?.artist ??
                    AppLocalizations.of(context)!.unknown,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
      },
    );
  }

  Widget _speed() {
    return Consumer<PlayerState>(
      builder: (context, state, child) {
        return state.currentRecord is Livestream
            ? Container()
            : RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  text: "${state.speed}x",
                  style: Theme.of(context).textTheme.bodySmall,
                  recognizer: _speedRecognizer,
                ),
              );
      },
    );
  }

  Widget _slider() {
    return Consumer<PlayerState>(
      builder: (context, state, child) {
        return state.currentRecord is Livestream
            ? Center(
                child: SizedBox.fromSize(
                  size: const Size(256, 64),
                  child: SoundwaveAnimation(animate: state.isPlaying),
                ),
              )
            : ValueListenableBuilder<double>(
                valueListenable: state.position,
                builder: (context, position, _) => Slider(
                  inactiveColor: Theme.of(context).colorScheme.outline,
                  value: position,
                  min: 0,
                  max: state.currentRecord?.duration ?? 0,
                  onChanged: (value) {
                    PlayerService.getInstance().seek(value);
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
                ),
              );
      },
    );
  }

  List<Widget> _controls() {
    return [
      Consumer<PlayerState>(
        builder: (context, state, child) {
          return state.currentRecord is Livestream
              ? Container()
              : IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    PlayerService.getInstance().shuffle = !state.shuffle;
                  },
                  iconSize: 24,
                  icon: Icon(
                    state.shuffle
                        ? Symbols.shuffle_on_rounded
                        : Symbols.shuffle_rounded,
                  ),
                );
        },
      ),
      Consumer<PlayerState>(
        builder: (context, state, child) {
          return state.currentRecord is Livestream
              ? Container()
              : IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: state.shuffle || state.isLoading
                      ? null
                      : () => PlayerService.getInstance().playPrevious(),
                  iconSize: 32,
                  icon: const Icon(Symbols.skip_previous_rounded),
                );
        },
      ),
      Consumer<PlayerState>(
        builder: (context, state, child) {
          return state.currentRecord is Livestream
              ? Container()
              : IconButton(
                  iconSize: 32,
                  padding: EdgeInsets.zero,
                  onPressed: state.isLoading
                      ? null
                      : () {
                          PlayerService.getInstance().rewind();
                        },
                  icon: const Icon(Symbols.replay_10),
                );
        },
      ),
      Consumer<PlayerState>(
        builder: (context, state, child) {
          if (state.isPlaying == _controller.status.isForwardOrCompleted) {
            state.isPlaying ? _controller.reverse() : _controller.forward();
          }

          return state.currentRecord is Livestream
              ? Container()
              : IconButton(
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
      Consumer<PlayerState>(
        builder: (context, state, child) {
          return state.currentRecord is Livestream
              ? Container()
              : IconButton(
                  iconSize: 32,
                  padding: EdgeInsets.zero,
                  onPressed: state.isLoading
                      ? null
                      : () {
                          PlayerService.getInstance().fastForward();
                        },
                  icon: const Icon(Symbols.forward_10),
                );
        },
      ),
      Consumer<PlayerState>(
        builder: (context, state, child) {
          return state.currentRecord is Livestream
              ? Container()
              : IconButton(
                  iconSize: 32,
                  padding: EdgeInsets.zero,
                  onPressed: state.isLoading
                      ? null
                      : () {
                          PlayerService.getInstance().playNext();
                        },
                  icon: const Icon(Symbols.skip_next_rounded),
                );
        },
      ),
      Consumer<PlayerState>(
        builder: (context, state, child) {
          return state.currentRecord is Livestream
              ? Container()
              : IconButton(
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  onPressed: state.shuffle
                      ? null
                      : () {
                          var nextModeIndex =
                              (state.repeat.index + 1) %
                              PlayerRepeatMode.values.length;
                          PlayerService.getInstance().repeat =
                              PlayerRepeatMode.values[nextModeIndex];
                        },
                  icon: Icon(
                    state.repeat == PlayerRepeatMode.all
                        ? Symbols.repeat_on_rounded
                        : (state.repeat == PlayerRepeatMode.one
                              ? Symbols.repeat_one_on_rounded
                              : Symbols.repeat_rounded),
                  ),
                );
        },
      ),
    ];
  }
}
