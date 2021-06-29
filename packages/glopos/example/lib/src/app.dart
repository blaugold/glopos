import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'pages/home.dart';
import 'theme.dart';

class GloposExampleApp extends StatelessWidget {
  const GloposExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ListenableProvider(
        create: (_) => AppState(),
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme(context),
          darkTheme: darkTheme(context),
          themeMode: context.watch<AppState>().themeMode,
          builder: (context, child) {
            context.read<AppState>().platformBrightness =
                MediaQuery.of(context).platformBrightness;

            return child!;
          },
          home: const HomePage(),
        ),
      );
}
