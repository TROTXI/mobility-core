import 'package:flutter/material.dart';

/// The data credit, rendered over the map's bottom edge.
///
/// Not optional and not a tooltip. ODbL requires the credit to be visible
/// wherever the data is shown, and the OpenMapTiles schema grant carries the
/// same condition — so this ships with the map rather than being something a
/// screen remembers to add.
///
/// Deliberately small and low-contrast: it has to be legible, not prominent.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        // A scrim rather than a solid chip: the credit has to stay readable
        // over whatever the map draws underneath it, which is not predictable.
        color: (dark ? Colors.black : Colors.white).withValues(alpha: 0.7),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 9,
            height: 1.3,
            color: dark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
