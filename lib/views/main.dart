import 'package:flutter/material.dart';

/// Main screen.
class MainScreen extends StatelessWidget {
  /// Initializes the instance.
  const MainScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Text('test'),
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: false,
          currentIndex: 1,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.music_note_outlined,
              ),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.audio_file_outlined,
              ),
              label: 'Playlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
