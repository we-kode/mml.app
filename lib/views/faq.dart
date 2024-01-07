import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';

/// FAQ detail screen.
class FAQScreen extends StatelessWidget {
  /// Initializes the instance.
  const FAQScreen({super.key});

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    final locales = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            ExpansionTile(
              title: Text(locales.faqAddFavorites),
              children: [
                ListTile(title: Text(locales.faqAddFavoritesDescription)),
              ],
            ),
            ExpansionTile(
              title: Text(locales.faqRemoveFavorites),
              children: [
                ListTile(title: Text(locales.faqRemoveFavoritesDescription)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
