import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mml_app/view_models/notes/note.dart';
import 'package:provider/provider.dart';

/// Shows the content of one note.
class NoteScreen extends StatelessWidget {
  final String path;

  /// Initializes the instance.
  const NoteScreen({
    Key? key,
    required this.path,
  }) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NoteViewModel>(
      create: (context) => NoteViewModel(),
      builder: (context, _) {
        var vm = Provider.of<NoteViewModel>(context, listen: false);

        return FutureBuilder(
          future: vm.init(context, path),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: MarkdownBody(data: vm.data),
              ),
            );
          },
        );
      },
    );
  }
}
