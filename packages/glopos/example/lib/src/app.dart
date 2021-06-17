import 'package:flutter/material.dart';

import 'pages/home.dart';
import 'theme.dart';

class GloposExampleApp extends StatelessWidget {
  const GloposExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme(context),
        darkTheme: darkTheme(context),
        home: const HomePage(),
      );
}
