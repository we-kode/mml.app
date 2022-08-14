import 'package:flutter/material.dart';
import 'package:mml_app/extensions/duration_double.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';
import 'package:provider/provider.dart';

class PlayerSheet extends StatefulWidget {
  PlayerSheet({Key? key}) : super(key: key);

  @override
  PlayerSheetState createState() => PlayerSheetState();
}

class PlayerSheetState extends State<PlayerSheet>
    with TickerProviderStateMixin {
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
      create: (_) => PlayerService.getInstance(),
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
                      Provider.of<PlayerService>(
                        context,
                        listen: false,
                      ).closePlayer();
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
                    Consumer<PlayerService>(
                      builder: (context, service, child) {
                        return Text(
                          service.currentReocrd?.title ?? "Unbekannt",
                          style: Theme.of(context).textTheme.subtitle1,
                        );
                      },
                    ),
                    const Spacer(),
                    Consumer<PlayerService>(
                      builder: (context, service, child) {
                        return Text(
                          "${service.currentSeekPosition.asFormattedDuration()}/${service.currentReocrd?.duration.asFormattedDuration()}",
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
                    Consumer<PlayerService>(
                      builder: (context, service, child) {
                        return Text(
                          service.currentReocrd?.artist ?? "Unbekannt",
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
                      child: Consumer<PlayerService>(
                        builder: (context, service, child) {
                          return Slider(
                            value: service.currentSeekPosition,
                            min: 0,
                            max: service.currentReocrd?.duration ?? 0,
                            onChanged: (value) {
                              service.seek(value.asDuration());
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
                    Consumer<PlayerService>(
                      builder: (context, service, child) {
                        return IconButton(
                          constraints: const BoxConstraints.tightFor(
                            width: 24,
                            height: 24,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            service.shuffle = !service.shuffle;
                          },
                          icon: Icon(
                            service.shuffle
                                ? Icons.shuffle_on_rounded
                                : Icons.shuffle_rounded,
                          ),
                        );
                      },
                    ),
                    const Spacer(
                      flex: 6,
                    ),
                    Consumer<PlayerService>(
                      builder: (context, service, child) {
                        return IconButton(
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: service.shuffle
                              ? null
                              : () => service.playPrevious(),
                          iconSize: 32,
                          icon: const Icon(Icons.skip_previous_rounded),
                        );
                      },
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Consumer<PlayerService>(
                      builder: (context, service, child) {
                        return IconButton(
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                          iconSize: 36,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (service.isPlaying) {
                              _controller.forward();
                              service.pause();
                            } else {
                              _controller.reverse();
                              service.resume();
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
                    IconButton(
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      iconSize: 32,
                      padding: EdgeInsets.zero,
                      onPressed: () => Provider.of<PlayerService>(
                        context,
                        listen: false,
                      ).playNext(),
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                    const Spacer(
                      flex: 6,
                    ),
                    Consumer<PlayerService>(
                      builder: (context, service, child) {
                        return IconButton(
                          constraints: const BoxConstraints.tightFor(
                            width: 24,
                            height: 24,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: service.shuffle
                              ? null
                              : () {
                                  var nextModeIndex =
                                      (service.repeat.index + 1) %
                                          PlayerRepeatMode.values.length;
                                  service.repeat =
                                      PlayerRepeatMode.values[nextModeIndex];
                                },
                          icon: Icon(
                            service.repeat == PlayerRepeatMode.all
                                ? Icons.repeat_on_rounded
                                : (service.repeat == PlayerRepeatMode.one
                                    ? Icons.repeat_one_on_rounded
                                    : Icons.repeat_rounded),
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
