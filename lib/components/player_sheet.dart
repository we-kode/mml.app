import 'package:flutter/material.dart';

class PlayerSheet extends StatelessWidget {
  const PlayerSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {},
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
                Text(
                  "Titel",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const Spacer(),
                Text(
                  "0:00/0:00",
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
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
                Text(
                  "Author",
                  style: Theme.of(context).textTheme.bodySmall,
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
                  child: Slider(
                    value: 0,
                    onChanged: (value) {},
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
                IconButton(
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(Icons.shuffle_rounded),
                ),
                const Spacer(
                  flex: 6,
                ),
                IconButton(
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  iconSize: 32,
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                const Spacer(
                  flex: 1,
                ),
                IconButton(
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  iconSize: 36,
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded),
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
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next_rounded),
                ),
                const Spacer(
                  flex: 6,
                ),
                IconButton(
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(Icons.repeat),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
