import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class MainBar extends StatelessWidget implements PreferredSizeWidget {
  const MainBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  final String title;

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return AppBar(
      title: Text(title),
      actions: [
        ...actions ?? [],
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text('Dark'),
            ),
            Switch(
              value: appState.darkMode,
              onChanged: (darkMode) => appState.darkMode = darkMode,
            ),
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
