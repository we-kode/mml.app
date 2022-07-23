import 'package:flutter/material.dart';

// TODO
class PlaylistScreen extends StatelessWidget {
  /// Initializes the instance.
  const PlaylistScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    //TODO implement
    return Scaffold(
      appBar: AppBar(
        title: Text("Playlist"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('Playlist'),
      ),
    );
  }
}
